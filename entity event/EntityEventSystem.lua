--------------------
--Area Event System:
--------------------

local EntityEventSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
EntityEventSystem.FLAG = require '/flag/FLAG'
EntityEventSystem.EVENT_TYPE = require '/event/EVENT_TYPE'
EntityEventSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityEventSystem.ENTITY_ROLE = require '/entity/ENTITY_ROLE'
EntityEventSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityEventSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
EntityEventSystem.ACTION_METHODS = require '/action/ACTION_METHOD'
EntityEventSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
EntityEventSystem.ENTITY_EVENT_REQUEST = require '/entity event/ENTITY_EVENT_REQUEST'

-------------------
--System Variables:
-------------------

EntityEventSystem.id = SYSTEM_ID.ENTITY_EVENT

EntityEventSystem.areaEntityList = nil
EntityEventSystem.eventComponentTable = nil
EntityEventSystem.flagDb = nil
EntityEventSystem.requestStack = {}

EntityEventSystem.collisionMethods = require '/collision/CollisionMethods'
EntityEventSystem.entityEventUpdater = require '/entity event/EntityEventUpdater'

EntityEventSystem.animationRequestPool = EventObjectPool.new(EntityEventSystem.EVENT_TYPE.ANIMATION, 100)
EntityEventSystem.actionLoaderRequestPool = EventObjectPool.new(EntityEventSystem.EVENT_TYPE.ACTION, 100)
EntityEventSystem.spatialUpdaterRequestPool = EventObjectPool.new(EntityEventSystem.EVENT_TYPE.SPATIAL_UPDATER, 2)
EntityEventSystem.sceneLoaderRequestPool = EventObjectPool.new(EntityEventSystem.EVENT_TYPE.SCENE_CHANGE, 5)
EntityEventSystem.entityInputRequestPool = EventObjectPool.new(EntityEventSystem.EVENT_TYPE.ENTITY_INPUT, 25)

EntityEventSystem.eventListenerList = {}
EntityEventSystem.eventDispatcher = nil

----------------
--Event Methods:
----------------

EntityEventSystem.eventMethods = {

	[1] = {
		[1] = function(request)
			--set entity tables
			EntityEventSystem:setAreaEntityList(request.entityDb)
			EntityEventSystem:setEventComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--set flag db
			EntityEventSystem:setFlagDatabase(request.flagDb)
		end,
		
		[3] = function(request)
			--request into stack
			EntityEventSystem:addRequestToStack(request)
		end,
		
		--...
	}
}

---------------
--Init Methods:
---------------

function EntityEventSystem:setEventComponentTable(entityDb)
	self.eventComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.EVENT)
end

function EntityEventSystem:setAreaEntityList(entityDb)
	self.areaEntityList = nil
	self.areaEntityList = entityDb.globalTables
end

function EntityEventSystem:setFlagDatabase(flagDb)
	self.flagDb = flagDb
end

function EntityEventSystem:init()
	
end

function EntityEventSystem:setUpdaterOnSpatialUpdaterSystem()
	local updaterSystemRequest = self.spatialUpdaterRequestPool:getCurrentAvailableObject()
	updaterSystemRequest.updaterObj = self.entityEventUpdater
	self.eventDispatcher:postEvent(1, 2, updaterSystemRequest)
	self.spatialUpdaterRequestPool:incrementCurrentIndex()
	self.spatialUpdaterRequestPool:resetCurrentIndex()
end

---------------
--Exec Methods:
---------------

function EntityEventSystem:update(dt)
	self:updateCollisions()
	self:resolveRequestStack()
	
	for i=1, #self.eventComponentTable do
		if self.eventComponentTable[i].state then
			self:updateEntity(dt, self.eventComponentTable[i])
		end
	end
	
	self.animationRequestPool:resetCurrentIndex()
	self.actionLoaderRequestPool:resetCurrentIndex()
	self.sceneLoaderRequestPool:resetCurrentIndex()
	self.entityInputRequestPool:resetCurrentIndex()
end

function EntityEventSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function EntityEventSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function EntityEventSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function EntityEventSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

EntityEventSystem.resolveRequestMethods = {
	[EntityEventSystem.ENTITY_EVENT_REQUEST.START_EVENT] = function(self, request)
		self:startEvent(request.eventComponent)
	end
}

function EntityEventSystem:getAction(actionSetId, actionId, eventComponent)
	local eventObj = self.actionLoaderRequestPool:getCurrentAvailableObject()
	
	eventObj.actionSetId = actionSetId
	eventObj.actionId = actionId
	eventObj.component = eventComponent
	eventObj.callback = self:getActionRequestCallbackMethod()
	
	self.eventDispatcher:postEvent(2, 1, eventObj)
	self.actionLoaderRequestPool:incrementCurrentIndex()
end

function EntityEventSystem:getActionRequestCallbackMethod()
	return function (component, actionObject)
		if actionObject then
			self:setActionOnComponent(component, actionObject) 
			self.ACTION_METHODS:resetAction(component)
			self:startAnimation(component)
		else
			self:onActionEnd(component)
		end
	end
end

function EntityEventSystem:setActionOnComponent(component, actionObject)
	component.action = actionObject
end

function EntityEventSystem:setComponentState(eventComponent, state)
	eventComponent.state = state
end

function EntityEventSystem:startEvent(eventComponent)
	if eventComponent.active and not eventComponent.state then
		self:setComponentState(eventComponent, true)
		self:startAction(eventComponent)
	end
end

function EntityEventSystem:startAction(eventComponent)
	if eventComponent.actionId then
		if not eventComponent.action then
			self:getAction(eventComponent.actionSetId, eventComponent.actionId, eventComponent)
		else
			self.ACTION_METHODS:resetAction(eventComponent)
			self:startAnimation(eventComponent)
		end
	else
		self:onActionEnd(eventComponent)
	end
end

function EntityEventSystem:endState(eventComponent)
	self:setComponentState(eventComponent, false)
	--the 'active' variable must be set in the action object itself
end

function EntityEventSystem:onActionEnd(eventComponent)
	self:endState(eventComponent)
end

function EntityEventSystem:updateEntity(dt, eventComponent)
	self.ACTION_METHODS:playAction(dt, self, eventComponent)
	self:resetEventChildEntities(eventComponent)
end

function EntityEventSystem:resetEventChildEntities(eventComponent)
	for k,v in pairs(eventComponent.childEntities) do
		eventComponent.childEntities[k] = nil
	end
end

function EntityEventSystem:startAnimation(eventComponent)
	if eventComponent.action and eventComponent.action.animationId then
		local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
		animationRequest.animationSetId = eventComponent.action.animationSetId
		animationRequest.animationId = eventComponent.action.animationId
		animationRequest.spritebox = eventComponent.componentTable.spritebox
		
		self.eventDispatcher:postEvent(3, 2, animationRequest)
		self.animationRequestPool:incrementCurrentIndex()
	end
end

function EntityEventSystem:stopAnimation(eventComponent)
	--not needed
end

function EntityEventSystem:changeState(sceneId, quickTransition)
	local sceneRequest = self.sceneLoaderRequestPool:getCurrentAvailableObject()
	sceneRequest.sceneId = sceneId
	sceneRequest.quickTransition = quickTransition
	
	self.eventDispatcher:postEvent(4, 1, sceneRequest)
end

function EntityEventSystem:endEventState(eventComponent)
	local eventObj = self.entityInputRequestPool:getCurrentAvailableObject()
	
	eventObj.actionId = self.ENTITY_ACTION.END_EVENT
	eventObj.stateComponent = eventComponent.componentTable.state
	
	if eventComponent.componentTable.playerInput and 
		eventComponent.componentTable.playerInput.state then
		self.eventDispatcher:postEvent(5, 4, eventObj)
	else
		--send to ai controller
	end
	
	self.entityInputRequestPool:incrementCurrentIndex()
end

function EntityEventSystem:getEntityById(entityId, entityType)
	if entityType then
		local entityList = self.areaEntityList[entityType]
		for i=1, #entityList do
			if entityList[i].components.main.id == entityId then
				return entityList[i]
			end
		end
	else
		for entityType, entityList in pairs(self.areaEntityList) do
			for i=1, #entityList do
				if entityList[i].components.main.id == entityId then
					return entityList[i]
				end
			end
		end
	end
end

function EntityEventSystem:updateCollisions()
	for colId, hashTbl in pairs(self.entityEventUpdater.collisonPairsHashtables) do
		self:detectCollisions(hashTbl)
	end
end

function EntityEventSystem:detectCollisions(pairsHashTable)
	if pairsHashTable.hashing then
		local currentHash = pairsHashTable.lastUsedHash
		local collisionPair = nil
		while currentHash > 0 do
			collisionPair = pairsHashTable.pairsTable[currentHash]
			self:detectCollision(collisionPair.entityA.parentEntity, collisionPair.entityB.parentEntity)
			currentHash = collisionPair.chainedPairHash
		end
	else
		--TODO: array iteration (not needed (?) the hash table is pretty fast)
	end
end

function EntityEventSystem:detectCollision(entityA, entityB)
	if self.collisionMethods:rectToRectDetection(entityA.x, entityA.y, entityA.x + entityA.w, 
		entityA.y + entityA.h, entityB.x, entityB.y, entityB.x + entityB.w, entityB.y + entityB.h) then
		
		if entityA.componentTable.scene.role == self.ENTITY_ROLE.ENTITY_EVENT then
			self:resolveCollision(entityA, entityB)
		else
			self:resolveCollision(entityB, entityA)
		end
	end
end

function EntityEventSystem:resolveCollision(eventEntity, entity)
	local eventComponent = eventEntity.componentTable.event
	
	if eventComponent.active then
		if not eventComponent.state then
			self:toggleEventState(eventComponent, entity.componentTable.scene.role)
		end
		
		if eventComponent.state then
			self:addChildEntity(eventComponent, entity, entity.componentTable.scene.role)
		end
	end
end

function EntityEventSystem:toggleEventState(eventComponent, role)
	for i=1, #eventComponent.activatedBy do
		if role == eventComponent.activatedBy[i] then
			self:startEvent(eventComponent)
			break
		end
	end
end

function EntityEventSystem:addChildEntity(eventComponent, hitboxComponent, role)
	for i=1, #eventComponent.childRoles do
		if role == eventComponent.childRoles[i] then
			table.insert(eventComponent.childEntities, hitboxComponent)
			break
		end
	end
end

----------------
--Return Module:
----------------

return EntityEventSystem