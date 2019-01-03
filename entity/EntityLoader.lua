----------------
--Entity Loader:
----------------
--[[
	How does this work?
	scene -> components -> entity = {{template, id, x, y, and other stuff}, ...}
	build entity via template + scene object (can build a generic one with just the template)
	modify entities via db
	get some entities in the cache if you want
	distribute to other systems
	
	initializer ex: {id = 2, template = 1, x = 0, y = 0}
	
	TODO: initialize individual entities by request
		get from cache/create | modify by db | index into db
]]

local EntityLoader = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
require '/entity/EntityDatabase'
require '/entity/EntityStack'
require '/persistent/GameDatabaseQuery'
require '/event/EventObjectPool'
EntityLoader.SCENE = require '/scene/SCENE'
EntityLoader.EVENT_TYPES = require '/event/EVENT_TYPE'
EntityLoader.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityLoader.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityLoader.ENTITY_TEMPLATE_TYPE = require '/entity/ENTITY_TEMPLATE_TYPE'
EntityLoader.DATABASE_TABLES = require '/persistent/DATABASE_TABLE'
EntityLoader.DATABASE_QUERY = require '/persistent/DATABASE_QUERY'

function EntityLoader:databaseQueryDefaultCallbackMethod() return function () end end
EntityLoader.databaseSystemRequestPool = EventObjectPool.new(EntityLoader.EVENT_TYPES.DATABASE_REQUEST, 10)
EntityLoader.databaseQueryPool = DatabaseQueryPool.new(10, EntityLoader.DATABASE_QUERY.GENERIC, 
	DatabaseQueryBuilder.new(), EntityLoader:databaseQueryDefaultCallbackMethod())

EntityLoader.initEntityRequestPool = EventObjectPool.new(EntityLoader.EVENT_TYPES.INIT_ENTITY, 10)

-------------------
--System Variables:
-------------------

EntityLoader.id = SYSTEM_ID.ENTITY_LOADER
EntityLoader.entityFactory = GameEntityBuilder.new()

EntityLoader.assetsFolderPath = '/entity/assets/'

EntityLoader.entityTemplateTable = {}		--[template_id] = template obj
EntityLoader.entityCache = {}				--[template_id] = obj list

EntityLoader.entityDatabaseStack = EntityDatabaseStack.new(4)

EntityLoader.eventDispatcher = nil
EntityLoader.eventListenerList = {}

----------------
--Event Methods:
----------------

EntityLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			--scene init request
			--INFO_STR = 'ENTITY LOADER ACTIVATED'
			EntityLoader:initScene(request.sceneObj)
		end,
		
		--...
	}
}

---------------
--Init Methods:
---------------

function EntityLoader:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function EntityLoader:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function EntityLoader:createEntityTemplateTable()
	self.entityTemplateTable = {}
	local templates = require '/entity/ENTITY_TEMPLATE'
	self.entityTemplateTable = templates
end

function EntityLoader:createEntityCache()
	self.entityCache = {}
	for templateName, templateId in pairs(self.ENTITY_TEMPLATE_TYPE) do
		self.entityCache[templateId] = {}
	end
end

function EntityLoader:init()
	self:createEntityTemplateTable()
	self:createEntityCache()
end

---------------
--Exec Methods:
---------------

function EntityLoader:initScene(scene)
	--used during the scene load state (do not use during the simulation!)
	
	local database = self:getEntityDatabaseFromStack(scene.components.main.id)
	
	if not database then
		database = EntityDatabase.new(scene.components.main.id, 
			self.ENTITY_TYPE, self.ENTITY_COMPONENT)
		
		local finalEntityLists = self:createEntitiesByScene(scene)
		for i=1, #finalEntityLists do
			self:indexEntityList(database, finalEntityLists[i])
		end
	end
	
	self:requestAllEntityListsModifier(database)
	self:pushDatabase(database)
	self:setEntityDbOnAllSystems()
end

function EntityLoader:initEntity(entityType, entityAsset)
	--this is used during the simulation
	local database = self.entityDatabaseStack:getCurrent()
	local entity = self:createEntityByInitializer(entityType, entityAsset)
	self:requestEntityModifier(entity)
	self:indexEntity(database, entityType, entity)
	self:setEntityOnAllSystems(entity)
end

function EntityLoader:getEntityDatabaseFromStack(databaseId)
	return self.entityDatabaseStack:getEntity(databaseId)
end

function EntityLoader:pushDatabase(entityDb)
	self.entityDatabaseStack:pushEntity(entityDb)
end

function EntityLoader:indexEntityList(entityDb, entityList)
	--{entityType=nil, global={}, component={}}
	
	entityDb:indexGlobalTable(entityList.entityType, entityList.global)
	
	for componentType, componentId in pairs(self.ENTITY_COMPONENT) do
		entityDb:indexComponentTable(entityList.entityType, componentId, 
			entityList.component[componentId])
	end
end

function EntityLoader:indexEntity(entityDb, entityType, entity)
	table.insert(entityDb.globalTables[entityType], entity)
	for componentType, componentId in pairs(self.ENTITY_COMPONENT) do
		self:indexEntityComponent(componentId, entity, entityDb)
	end
end

function EntityLoader:createEntityByInitializer(entityType, entityAsset)
	--creates a single entity (componens become out of order)
	--asset: {id = 2, template = 1, x = 0, y = 0, ...}
	
	local sortedComponents = self:getComponentsSortedByDependency()
	local newEntity = self.entityFactory:createEntity()
	local template = self:getEntityTemplate(entityAsset.template)
	
	for _, key in ipairs(sortedComponents) do
		local componentId = self.ENTITY_COMPONENT[key]
		
		if template.components[componentId] then
			self:createEntityComponent(componentId, template, entityAsset, newEntity)
		end
	end
	
	return newEntity
end

function EntityLoader:createEntitiesByScene(scene)
	local entityList = scene.components.entity.entityList
	local finalLists = {}
	
	for entityType, listAsset in pairs(entityList) do
		--listAsset: {{id = 2, template = 1, x = 0, y = 0}, ...}
		table.insert(finalLists, self:createEntityListByComponent(entityType, listAsset))
	end
	
	return finalLists
end

function EntityLoader:createEmptyEntityList()
	return {entityType=nil, global={}, component={}}
end

function EntityLoader:createEntityListByComponent(entityType, entityListAsset)
	--this sucks
	
	local sortedComponents = self:getComponentsSortedByDependency()
	local entityList = self:createEmptyEntityList()
	entityList.entityType = entityType
	
	for i=1, #entityListAsset do
		table.insert(entityList.global, self.entityFactory:createEntity())
	end
	
	for _, key in ipairs(sortedComponents) do
		local componentId = self.ENTITY_COMPONENT[key]
		entityList.component[componentId] = {}
		
		for i=1, #entityListAsset do
			local template = self:getEntityTemplate(entityListAsset[i].template)
			
			if template.components[componentId] then
				local component = self:createEntityComponent(componentId, template, 
					entityListAsset[i], entityList.global[i])
				table.insert(entityList.component[componentId], component)
			end
		end
	end
	
	return entityList
end

function EntityLoader:createEntity(entityAsset)
	local entity = self.entityFactory:createEntity()
	local template = self:getEntityTemplate(entityListAsset[i].template)
	
	for componentId, componentStruct in pairs(template.components) do
		self:createEntityComponent(componentId, template, entityAsset, entity)
	end
	
	return entity
end

function EntityLoader:createEntityComponent(componentId, template, entityAsset, entity)
	local component = self.entityFactory:createComponent(componentId)
	self.entityFactory:addComponentToEntity(entity, componentId, component)
	self.createEntityComponentMethods[componentId](self, template, entityAsset, entity)
	return component
end

EntityLoader.createEntityComponentMethods = {
	--template.components[COMPONENT_ID] || entityAsset || entity.components.compname
	
	[EntityLoader.ENTITY_COMPONENT.MAIN] = function(self, template, entityAsset, entity)
		local component = entity.components.main
		local templateComponent = template.components[self.ENTITY_COMPONENT.MAIN]
		component.id = entityAsset.id
	end,
	
	[EntityLoader.ENTITY_COMPONENT.SCENE] = function(self, template, entityAsset, entity)
		local component = entity.components.scene
		local templateComponent = template.components[self.ENTITY_COMPONENT.SCENE]
		component.defaultRole = entityAsset.role
		component.role = entityAsset.role
	end,
	
	[EntityLoader.ENTITY_COMPONENT.SPRITEBOX] = function(self, template, entityAsset, entity)
		local component = entity.components.spritebox
		local templateComponent = template.components[self.ENTITY_COMPONENT.SPRITEBOX]
		component.x = entityAsset.x
		component.y = entityAsset.y
		component.w = templateComponent.w
		component.h = templateComponent.h
		component.direction = templateComponent.direction
		component.defaultSpritesheetId = templateComponent.defaultSpritesheetId
		component.spritesheetId = templateComponent.spritesheetId
		component.quad = templateComponent.quad
		component.aniRepoId = templateComponent.aniRepoId
		
		--below is just an example, kinda spaghetti but it does the trick:
		if entityAsset.spritesheetId then
			component.defaultSpritesheetId = entityAsset.spritesheetId
			component.spritesheetId = entityAsset.spritesheetId
			component.w = entityAsset.spriteW
			component.h = entityAsset.spriteH
		end
		
		if entityAsset.quad then
			component.quad = entityAsset.quad
		end
	end,
	
	[EntityLoader.ENTITY_COMPONENT.HITBOX] = function(self, template, entityAsset, entity)
		local component = entity.components.hitbox
		local templateComponent = template.components[self.ENTITY_COMPONENT.HITBOX]
		component.xDeviation = templateComponent.xDeviation
		component.yDeviation = templateComponent.yDeviation
		component.x = entityAsset.x + templateComponent.xDeviation
		component.y = entityAsset.y + templateComponent.yDeviation
		component.w = templateComponent.w
		component.h = templateComponent.h
		component.collisionType = templateComponent.collisionType
		component.mapCollisionType = templateComponent.mapCollisionType
		
		if entityAsset.hitboxW and entityAsset.hitboxH then
			component.w = entityAsset.hitboxW
			component.h = entityAsset.hitboxH
		end
		
		if entityAsset.collisionType and entityAsset.mapCollisionType then
			component.collisionType = entityAsset.collisionType
			component.mapCollisionType = entityAsset.mapCollisionType
		end
	end,
	
	[EntityLoader.ENTITY_COMPONENT.TRANSPORT] = function(self, template, entityAsset, entity)
		--TODO
	end,
	
	[EntityLoader.ENTITY_COMPONENT.ACTION_STATE] = function(self, template, entityAsset, entity)
		local component = entity.components.actionState
		local templateComponent = template.components[self.ENTITY_COMPONENT.ACTION_STATE]
		component.state = templateComponent.state
		component.defaultState = templateComponent.defaultState
	end,
	
	[EntityLoader.ENTITY_COMPONENT.INPUT] = function(self, template, entityAsset, entity)
		local component = entity.components.input
		local templateComponent = template.components[self.ENTITY_COMPONENT.INPUT]
		component.state = templateComponent.state
		component.defaultControllerId = templateComponent.defaultControllerId
		component.controllerId = templateComponent.controllerId
		component.playerInputState = templateComponent.playerInputState
		
		if entityAsset.playerInputState then
			component.playerInputState = entityAsset.playerInputState
		end
	end,
	
	[EntityLoader.ENTITY_COMPONENT.IDLE] = function(self, template, entityAsset, entity)
		local component = entity.components.idle
		local templateComponent = template.components[self.ENTITY_COMPONENT.IDLE]
		component.state = templateComponent.state
		component.actionSetId = templateComponent.actionSetId
		component.actionId = templateComponent.actionId
		component.action = templateComponent.action
		component.currentTime = templateComponent.currentTime
		component.updatePoint = templateComponent.updatePoint
		component.frameCounter = templateComponent.frameCounter
		component.currentMethodIndex = templateComponent.currentMethodIndex
		component.methodThreads = templateComponent.methodThreads
	end,
	
	[EntityLoader.ENTITY_COMPONENT.MOVEMENT] = function(self, template, entityAsset, entity)
		local component = entity.components.movement
		local templateComponent = template.components[self.ENTITY_COMPONENT.MOVEMENT]
		component.velocity = templateComponent.velocity
		component.direction = templateComponent.direction
		component.spritesheetId = templateComponent.spritesheetId
		component.defaultQuad = templateComponent.defaultQuad
		component.totalTime = templateComponent.totalTime
		component.currentTime = templateComponent.currentTime
		component.frequency = templateComponent.frequency
		component.updatePoint = templateComponent.updatePoint
		component.movementRepoId = templateComponent.movementRepoId
		component.animationSetId = templateComponent.animationSetId
		component.animationId = templateComponent.animationId
	end,
	
	[EntityLoader.ENTITY_COMPONENT.TARGETING] = function(self, template, entityAsset, entity)
		local component = entity.components.targeting
		local templateComponent = template.components[self.ENTITY_COMPONENT.TARGETING]
		component.state = templateComponent.state
		component.defaultTargetingType = templateComponent.defaultTargetingType
		component.targetingType = templateComponent.targetingType
		component.areaRadius = templateComponent.areaRadius
		component.targetEntityType = templateComponent.targetEntityType
		component.targetEntityRef = templateComponent.targetEntityRef
	end,
	
	[EntityLoader.ENTITY_COMPONENT.ACTION] = function(self, template, entityAsset, entity)
		local component = entity.components.action
		local templateComponent = template.components[self.ENTITY_COMPONENT.ACTION]
		component.state = templateComponent.state
		component.defaultActionSetId = templateComponent.defaultActionSetId
		component.actionPlayer = templateComponent.actionPlayer
	end,
	
	[EntityLoader.ENTITY_COMPONENT.SPAWN] = function(self, template, entityAsset, entity)
		local component = entity.components.spawn
		local templateComponent = template.components[self.ENTITY_COMPONENT.SPAWN]
		component.state = templateComponent.state
		component.scriptId = templateComponent.scriptId
		component.actionSetId = templateComponent.actionSetId
		component.actionId = templateComponent.actionId
		component.action = templateComponent.action
		component.currentTime = templateComponent.currentTime
		component.updatePoint = templateComponent.updatePoint
		component.frameCounter = templateComponent.frameCounter
		component.currentMethodIndex = templateComponent.currentMethodIndex
		component.methodThreads = templateComponent.methodThreads
		component.areaSpawnId = templateComponent.areaSpawnId	--should be asset, change it!
	end,
	
	[EntityLoader.ENTITY_COMPONENT.DESPAWN] = function(self, template, entityAsset, entity)
		local component = entity.components.despawn
		local templateComponent = template.components[self.ENTITY_COMPONENT.DESPAWN]
		component.state = templateComponent.state
		component.scriptId = templateComponent.scriptId
		component.actionSetId = templateComponent.actionSetId
		component.actionId = templateComponent.actionId
		component.action = templateComponent.action
		component.currentTime = templateComponent.currentTime
		component.updatePoint = templateComponent.updatePoint
		component.frameCounter = templateComponent.frameCounter
		component.currentMethodIndex = templateComponent.currentMethodIndex
		component.methodThreads = templateComponent.methodThreads
	end,
	
	[EntityLoader.ENTITY_COMPONENT.SCRIPT] = function(self, template, entityAsset, entity)
		local component = entity.components.script
		local templateComponent = template.components[self.ENTITY_COMPONENT.SCRIPT]
		component.state = templateComponent.state
		component.activeScript = templateComponent.activeScript
		component.currentTime = templateComponent.currentTime
		component.autoScriptId = templateComponent.autoScriptId
		
		if entityAsset.scriptState then
			component.state = entityAsset.scriptState
			component.autoScriptId = entityAsset.autoScriptId
		end
	end,
	
	[EntityLoader.ENTITY_COMPONENT.EVENT] = function(self, template, entityAsset, entity)
		local component = entity.components.event
		local templateComponent = template.components[self.ENTITY_COMPONENT.EVENT]
		component.state = templateComponent.state
		component.active = templateComponent.active		--should be by entityAsset
		component.activatedBy = templateComponent.activatedBy
		component.childRoles = templateComponent.childRoles
		component.actionSetId = templateComponent.actionSetId
		component.actionId = templateComponent.actionId
		component.action = templateComponent.action
		component.currentTime = templateComponent.currentTime
		component.updatePoint = templateComponent.updatePoint
		component.frameCounter = templateComponent.frameCounter
		component.currentMethodIndex = templateComponent.currentMethodIndex
		component.methodThreads = templateComponent.methodThreads
	end,
	
	[EntityLoader.ENTITY_COMPONENT.ITEM] = function(self, template, entityAsset, entity)
		local component = entity.components.item
		local templateComponent = template.components[self.ENTITY_COMPONENT.ITEM]
		component.state = templateComponent.state	--should be asset
		component.itemType = templateComponent.itemType
		component.itemId = templateComponent.itemId
		component.itemQuantity = templateComponent.itemQuantity
	end,
	
	[EntityLoader.ENTITY_COMPONENT.INVENTORY] = function(self, template, entityAsset, entity)
		local component = entity.components.inventory
		local templateComponent = template.components[self.ENTITY_COMPONENT.INVENTORY]
		component.inventoryId = templateComponent.inventoryId
	end,
	
	[EntityLoader.ENTITY_COMPONENT.COMBAT] = function(self, template, entityAsset, entity)
		local component = entity.components.combat
		local templateComponent = template.components[self.ENTITY_COMPONENT.COMBAT]
		component.state = templateComponent.state
		
		component.actionSetId = templateComponent.actionSetId
		component.action = templateComponent.action
		component.currentTime = templateComponent.currentTime
		component.updatePoint = templateComponent.updatePoint
		component.frameCounter = templateComponent.frameCounter
		component.currentMethodIndex = templateComponent.currentMethodIndex
		component.methodThreads = templateComponent.methodThreads
		
		component.attackEquipped = templateComponent.attackEquipped
		component.moveEquipped = templateComponent.moveEquipped
		component.specialEquipped = templateComponent.specialEquipped
		component.lockupEquipped = templateComponent.lockupEquipped
		component.knockbackEquipped = templateComponent.knockbackEquipped
		component.maxAttackEquipped = templateComponent.maxAttackEquipped
		component.maxAttackCombo = templateComponent.maxAttackCombo
		component.attackComboState = templateComponent.attackComboState
		component.comboActivation = templateComponent.comboActivation
		component.currentStamina = templateComponent.currentStamina
		component.maxStamina = templateComponent.maxStamina
		component.staminaRecoveryRate = templateComponent.staminaRecoveryRate
		
		if entityAsset.attackEquipped then
			component.attackEquipped = entityAsset.attackEquipped
		end
	end,
	
	[EntityLoader.ENTITY_COMPONENT.HEALTH] = function(self, template, entityAsset, entity)
		local component = entity.components.health
		local templateComponent = template.components[self.ENTITY_COMPONENT.HEALTH]
		
		component.state = templateComponent.state
		component.healthPoints = templateComponent.healthPoints
		component.maxHealthPoints = templateComponent.maxHealthPoints
		component.healthPointsResistance = templateComponent.healthPointsResistance
		component.healthPointsScript = templateComponent.healthPointsScript
		
		component.effects = templateComponent.effects
		component.activeScripts = templateComponent.activeScripts
		
		component.healthPointsRegen = templateComponent.healthPointsRegen
		component.healthPointsRegenMultiplier = templateComponent.healthPointsRegenMultiplier
		component.healthPointsRegenTime = 0
	end,
	
	[EntityLoader.ENTITY_COMPONENT.DIALOGUE] = function(self, template, entityAsset, entity)
		local component = entity.components.dialogue
		local templateComponent = template.components[self.ENTITY_COMPONENT.HEALTH]
		
		component.dialogueId = template.dialogueId
		
		if entityAsset.dialogueId then
			component.dialogueId = entityAsset.dialogueId
		end
	end,
}

function EntityLoader:getEntityById(entityId, sceneId, entityType)
	--TODO: test this (sceneId and entityType are optional parameters)
	
	local entityDb = nil
	
	if sceneId then entityDb = self.entityDatabaseStack:getEntity(sceneId) end
	if not entityDb then entityDb = self.entityDatabaseStack:getCurrent() end
	
	if entityType then
		local entityList = entityDb:getGlobalTable(entityType)
		for i=1, #entityList do
			if entityList.components.main.id == entityId then
				return entity
			end
		end
	else
		for entityType, entityList in pairs(entityDb.globalTables) do
			for i=1, #entityList do
				if entityList.components.main.id == entityId then
					return entity
				end
			end
		end
	end
end

function EntityLoader:clearEntityCache()
	for templateId, entityList in pairs(self.entityCache) do
		for i=#entityList, 1, -1 do
			self:clearEntity(entityList[i])
			table.remove(entityList)
		end
	end
end

function EntityLoader:clearEntity(entity)
	for componentName, component in pairs(entity.components) do
		component.componentTable = nil
		component = nil
	end
	entity.components = nil
end

function EntityLoader:loadEntitiesToCache(templateTypeList, maxEntities)
	for i=1, #templateTypeList do
		self:loadEntitiesToCacheByTemplate(templateTypeList[i], maxEntities)
	end
end

function EntityLoader:loadEntitiesToCacheByTemplate(templateType, maxEntities)
	for i=1, #maxEntities do
		self:loadEntityToCache(templateType)
	end
end

function EntityLoader:loadEntityToCache(templateType)
	local entity = self:createEntity(templateId, nil)
	table.insert(self.entityCache[templateType], entity)
end

function EntityLoader:getEntityFromCache(templateType)
	if #self.entityCache[templateType] > 0 then
		local entity = self.entityCache[templateType][#self.entityCache[templateType]]
		table.remove(self.entityCache[templateType])
		return entity
	end
	return nil
end

function EntityLoader:getEntityTemplate(templateId)
	return self.entityTemplateTable[templateId]
end

function EntityLoader:getComponentsSortedByDependency()
	return self:sortComponentsByDependency(self.ENTITY_COMPONENT, 
		function(a, b) return a < b end)
end

function EntityLoader:sortComponentsByDependency(tbl, sortFunction)
	local keys = {}
	for key in pairs(tbl) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)
		return sortFunction(tbl[a], tbl[b])
	end)

	return keys
end

function EntityLoader:requestEntityModifier(entity)
	local queryObj = self.databaseQueryPool:getCurrentAvailableObject(self.DATABASE_QUERY.GENERIC)
	self.databaseQueryPool.queryBuilder:setDatabaseQueryParameters(queryObj, 'entity_table')
	self.databaseQueryPool:incrementCurrentIndex()
	queryObj.responseCallback = self:modifyEntityCallback(entity)
	
	local databaseSystemRequest = self.databaseSystemRequestPool:getCurrentAvailableObject()
	databaseSystemRequest.databaseQuery = queryObj
	self.eventDispatcher:postEvent(1, 1, databaseSystemRequest)
	self.databaseSystemRequestPool:incrementCurrentIndex()
end

function EntityLoader:requestAllEntityListsModifier(entityDb)
	for entityType, entityList in pairs(entityDb.globalTables) do
		self:requestEntityListModifier(entityList)
	end
end

function EntityLoader:requestEntityListModifier(entityGlobalList)
	--get mod from ingame db
	
	local queryObj = self.databaseQueryPool:getCurrentAvailableObject(self.DATABASE_QUERY.GENERIC)
	self.databaseQueryPool.queryBuilder:setDatabaseQueryParameters(queryObj, 'entity_table')
	self.databaseQueryPool:incrementCurrentIndex()
	queryObj.responseCallback = self:modifyEntityListCallback(entityGlobalList)
	
	local databaseSystemRequest = self.databaseSystemRequestPool:getCurrentAvailableObject()
	databaseSystemRequest.databaseQuery = queryObj
	self.eventDispatcher:postEvent(1, 1, databaseSystemRequest)
	self.databaseSystemRequestPool:incrementCurrentIndex()
end

function EntityLoader:getEntityModifierById(id, listMod)
	for i=1, #listMod do
		if listMod[i]['id'] == id then
			return listMod[i]
		end
	end
	return nil
end

function EntityLoader:modifyEntityList(list, listMod)
	for i=1, list do
		local entity = list[i]
		local entityModifier = self:getEntityModifierById(entity.components.main.id,
			listMod)
		if entityModifier then
			self:modifyEntity(entity, entityModifier)
		end
	end
end

function EntityLoader:modifyEntityListCallback(list)
	--callback for list modifier method
	return function(results) 
		self:modifyEntityList(list, results)
	end
end

function EntityLoader:modifyEntityCallback(entity)
	--callback for list modifier method
	return function(results) 
		self:modifyEntity(entity, results)
	end
end

function EntityLoader:modifyEntity(entity, entityMod)
	for componentType, componentId in pairs(self.ENTITY_COMPONENT) do
		self:modifyComponent(componentId, entity, entityMod)
	end
end

function EntityLoader:modifyComponent(componentId, entity, entityMod)
	self.modifyEntityComponentMethods[componentId](entity, entityMod)
end

EntityLoader.modifyEntityComponentMethods = {
	--always check if the entity has the chosen component
	
	[EntityLoader.ENTITY_COMPONENT.MAIN] = function(entity, entityMod)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.SCENE] = function(entity, entityMod)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.SPRITEBOX] = function(entity, entityMod)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.IDLE] = function(entity, entityMod)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.HITBOX] = function(entity, entityMod)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.TRANSPORT] = function(entity, entityMod)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.ACTION_STATE] = function(entity, entityMod)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.INPUT] = function(entity, entityMod)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.MOVEMENT] = function(entity, entityMod)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.TARGETING] = function(entity, entityMod)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.ACTION] = function(entity, entityMod)
	
	end
}

function EntityLoader:indexEntityComponent(componentId, entity, entityDb)
	self.indexEntityComponentMethods[componentId](entity, entityDb)
end

EntityLoader.indexEntityComponentMethods = {
	[EntityLoader.ENTITY_COMPONENT.MAIN] = function(entity, entityDb)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.SCENE] = function(entity, entityDb)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.SPRITEBOX] = function(entity, entityDb)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.IDLE] = function(entity, entityDb)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.HITBOX] = function(entity, entityDb)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.TRANSPORT] = function(entity, entityDb)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.ACTION_STATE] = function(entity, entityDb)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.INPUT] = function(entity, entityDb)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.MOVEMENT] = function(entity, entityDb)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.TARGETING] = function(entity, entityDb)
	
	end,
	
	[EntityLoader.ENTITY_COMPONENT.ACTION] = function(entity, entityDb)
	
	end
}

function EntityLoader:setEntityDbOnAllSystems()
	local request = self.initEntityRequestPool:getCurrentAvailableObject()
	request.entityDb = self.entityDatabaseStack:getCurrent()
	self.setEntityDbOnSystemMethods[SYSTEM_ID.CAMERA](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.SPATIAL_PARTITIONING](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.ENTITY_CONTROLLER](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.ENTITY_MOVEMENT](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.ENTITY_ANIMATION](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.IDLE](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.TARGETING](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.ENTITY_SPAWN](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.ENTITY_DESPAWN](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.ENTITY_EVENT](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.ITEM](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.ENTITY_SCRIPT](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.COMBAT](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.HEALTH](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.SOUND](self, request)
	self.setEntityDbOnSystemMethods[SYSTEM_ID.GAME_RENDERER](self, request)
	self.initEntityRequestPool:incrementCurrentIndex()
end

EntityLoader.setEntityDbOnSystemMethods = {
	[SYSTEM_ID.CAMERA] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(2, 1, request)
	end,
	
	[SYSTEM_ID.SPATIAL_PARTITIONING] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(3, 3, request)
	end,
	
	[SYSTEM_ID.ENTITY_CONTROLLER] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(5, 1, request)
	end,
	
	[SYSTEM_ID.ENTITY_MOVEMENT] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(6, 1, request)
	end,
	
	[SYSTEM_ID.ENTITY_ANIMATION] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(7, 1, request)
	end,
	
	[SYSTEM_ID.IDLE] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(8, 1, request)
	end,
	
	[SYSTEM_ID.TARGETING] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(9, 1, request)
	end,
	
	[SYSTEM_ID.ENTITY_SPAWN] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(10, 1, request)
	end,
	
	[SYSTEM_ID.ENTITY_DESPAWN] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(11, 1, request)
	end,
	
	[SYSTEM_ID.ENTITY_EVENT] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(12, 1, request)
	end,
	
	[SYSTEM_ID.ITEM] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(13, 1, request)
	end,
	
	[SYSTEM_ID.ENTITY_SCRIPT] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(14, 1, request)
	end,
	
	[SYSTEM_ID.COMBAT] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(15, 1, request)
	end,
	
	[SYSTEM_ID.HEALTH] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(16, 1, request)
	end,
	
	[SYSTEM_ID.SOUND] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(17, 2, request)
	end,
	
	[SYSTEM_ID.GAME_RENDERER] = function(entityLoader, request)
		entityLoader.eventDispatcher:postEvent(18, 7, request)
	end,
	
	--...
}

function EntityLoader:setEntityOnAllSystems(entity)
	--entity already added to lists, but sometimes it has to be indexed in the system itself
		--ex, spatial indexing ...
	--call setEntityOnSystemMethods
end

EntityLoader.setEntityOnSystemMethods = {
	[SYSTEM_ID.CAMERA] = function(EntityLoader)
		
	end,
	
	--...
}

----------------
--Return module:
----------------

return EntityLoader