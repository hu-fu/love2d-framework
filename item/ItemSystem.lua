--------------
--Item System:
--------------

local ItemSystem = {}

---------------
--Dependencies:
---------------

require '/item/ItemObjects'
require '/entity/GameEntity'
local SYSTEM_ID = require '/system/SYSTEM_ID'
ItemSystem.EVENT_TYPE = require '/event/EVENT_TYPE'
ItemSystem.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
ItemSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
ItemSystem.ENTITY_ROLE = require '/entity/ENTITY_ROLE'
ItemSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
ItemSystem.INVENTORY_TABLE = require '/item/INVENTORY_TABLE'
ItemSystem.INVENTORY_METHODS = require '/item/INVENTORY_METHODS'
ItemSystem.INVENTORY = require '/item/INVENTORY'
ItemSystem.ITEM_TYPE = require '/item/ITEM_TYPE'
ItemSystem.ITEM = require '/item/ITEM'
ItemSystem.ITEM_DATABASE = require '/item/ITEM_DATABASE'
ItemSystem.ITEM_ENTITY_TEMPLATE = require '/item/ITEM_ENTITY_TEMPLATE'
ItemSystem.ITEM_REQUEST = require '/item/ITEM_REQUEST'

-------------------
--System Variables:
-------------------

ItemSystem.id = SYSTEM_ID.ITEM

ItemSystem.entityFactory = GameEntityBuilder.new()
ItemSystem.itemObjectPool = ItemObjectPool.new(50)
ItemSystem.itemComponentTable = nil
ItemSystem.requestStack = {}

ItemSystem.collisionMethods = require '/collision/CollisionMethods'
ItemSystem.entityItemUpdater = require '/item/EntityItemUpdater'

ItemSystem.spatialUpdaterRequestPool = EventObjectPool.new(ItemSystem.EVENT_TYPE.SPATIAL_UPDATER, 2)

function ItemSystem:spatialQueryDefaultCallbackMethod() return function () end end
ItemSystem.spatialSystemRequestPool = EventObjectPool.new(ItemSystem.EVENT_TYPE.SPATIAL_REQUEST, 15)
ItemSystem.registerItemSpatialQueryPool = SpatialQueryPool.new(15, ItemSystem.QUERY_TYPES.REINDEX_ENTITY, 
	SpatialQueryBuilder.new(), ItemSystem:spatialQueryDefaultCallbackMethod())
ItemSystem.unregisterItemSpatialQueryPool = SpatialQueryPool.new(15, ItemSystem.QUERY_TYPES.UNREGISTER_ENTITY, 
	SpatialQueryBuilder.new(), ItemSystem:spatialQueryDefaultCallbackMethod())

ItemSystem.eventDispatcher = nil
ItemSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

ItemSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--set entity component table (request.entityDb)
			ItemSystem:setItemComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--request into stack
			ItemSystem:addRequestToStack(request)
		end,
		
	}
}

---------------
--Init Methods:
---------------

function ItemSystem:setItemComponentTable(entityDb)
	self.itemComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.ITEM)
	self:unregisterInactiveItemComponents()
end

function ItemSystem:buildItemObjectPool(maxObjects)
	local itemList = self:createItems(maxObjects)
	
	for i=1, #itemList do
		table.insert(self.itemObjectPool.objectPool, itemList[i].components.item)
	end
end

ItemSystem.itemObjectPool.getCurrentAvailableObject = function()
	for i=1, #ItemSystem.itemObjectPool.objectPool do
		local index = ((i + ItemSystem.itemObjectPool.currentIndex) % 
			#ItemSystem.itemObjectPool.objectPool) + 1
		if not ItemSystem.itemObjectPool.objectPool[index].state then
			ItemSystem.itemObjectPool.currentIndex = index
			return ItemSystem.itemObjectPool.objectPool[index]
		end
	end
	
	return nil
end

function ItemSystem:setUpdaterOnSpatialUpdaterSystem()
	local updaterSystemRequest = self.spatialUpdaterRequestPool:getCurrentAvailableObject()
	updaterSystemRequest.updaterObj = self.entityItemUpdater
	self.eventDispatcher:postEvent(1, 2, updaterSystemRequest)
	self.spatialUpdaterRequestPool:incrementCurrentIndex()
	self.spatialUpdaterRequestPool:resetCurrentIndex()
end

function ItemSystem:unregisterInactiveItemComponents()
	for i=1, #self.itemComponentTable do
		if not self.itemComponentTable[i].state then
			self:unregisterItemInSpatialSystem(self.itemComponentTable[i])
		end
	end
end

function ItemSystem:initScene()
	self:buildItemObjectPool(50)
end

function ItemSystem:init()
	
end

---------------
--Exec Methods:
---------------

function ItemSystem:update()
	--self:debug_activateItem()
	
	self:updateCollisions()
	self:resolveRequestStack()
	
	self.spatialSystemRequestPool:resetCurrentIndex()
	self.registerItemSpatialQueryPool:resetCurrentIndex()
	self.unregisterItemSpatialQueryPool:resetCurrentIndex()
end

function ItemSystem:createItems(maxItems)
	local itemList = {}
	
	for i=1, maxItems do
		table.insert(itemList, self:createItem())
	end
	
	for i=1, #itemList do
		self:createItemComponent(itemList[i])
	end
	
	return itemList
end

function ItemSystem:createItem()
	local entity = self.entityFactory:createEntity()
	local sortedComponents = self:getComponentsSortedByDependency()
	
	for _, key in ipairs(sortedComponents) do
		local componentId = self.ENTITY_COMPONENT[key]
		
		if self.ITEM_ENTITY_TEMPLATE.components[componentId] then
			local component = self.entityFactory:createComponent(componentId)
			self.entityFactory:addComponentToEntity(entity, componentId, component)
		end
	end
	
	entity.components.scene.role = self.ENTITY_ROLE.ITEM
	return entity
end

function ItemSystem:createItemComponent(entity)
	--for better cache coherence (not that it matters)
	local component = self.entityFactory:createComponent(self.ENTITY_COMPONENT.ITEM)
	self.entityFactory:addComponentToEntity(entity, self.ENTITY_COMPONENT.ITEM, component)
end

function ItemSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function ItemSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function ItemSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function ItemSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

ItemSystem.resolveRequestMethods = {
	[ItemSystem.ITEM_REQUEST.ACTIVATE_ITEM] = function(self, request)
		self:activateItem(request.itemType, request.itemId, request.x, request.y, request.quantity)
	end,
	
	[ItemSystem.ITEM_REQUEST.DEACTIVATE_ITEM] = function(self, request)
		self:deactivateItem(request.itemComponent)
	end,
	
	[ItemSystem.ITEM_REQUEST.GET_ITEM] = function(self, request)
		self:getItem(request.inventoryComponent, request.itemComponent)
	end
}

function ItemSystem:activateItem(itemType, itemId, x, y, quantity)
	--set variables using the itemDb and request variables
	local itemComponent = self.itemObjectPool.getCurrentAvailableObject()
	local dbItem = self.ITEM_DATABASE[itemType][itemId]
	
	if itemComponent and dbItem then
		self:initItem(itemType, itemId, dbItem, x, y, quantity, itemComponent)
		self:registerItemInSpatialSystem(itemComponent)
	end
end

function ItemSystem:deactivateItem(itemComponent)
	itemComponent.state = false
	self:unregisterItemInSpatialSystem(itemComponent)
end

function ItemSystem:getItem(inventoryComponent, itemComponent)
	self.INVENTORY_METHODS:addItem(self, self.INVENTORY_TABLE, inventoryComponent.inventoryId, itemComponent, 
		itemComponent.itemType, itemComponent.itemId)
end

function ItemSystem:initItem(itemType, itemId, dbItem, x, y, quantity, itemComponent)
	local spritebox = itemComponent.componentTable.spritebox
	local hitbox = itemComponent.componentTable.hitbox
	
	itemComponent.state = true
	itemComponent.itemType = itemType
	itemComponent.itemId = itemId
	itemComponent.itemQuantity = quantity
	
	spritebox.spritesheetId = dbItem.spritesheetId
	spritebox.quad = dbItem.quad
	spritebox.x = x
	spritebox.y = y
	spritebox.w = dbItem.w
	spritebox.h = dbItem.h
	
	hitbox.x = x
	hitbox.y = y
	hitbox.w = dbItem.w
	hitbox.h = dbItem.h
end

function ItemSystem:registerItemInSpatialSystem(itemComponent)
	local queryObj = self.registerItemSpatialQueryPool:getCurrentAvailableObjectDefault()
	--queryObj.querySubType = 1
	--queryObj.responseCallback = nil
	queryObj.entityType = self.ENTITY_TYPE.GENERIC_ENTITY
	queryObj.entityRole = self.ENTITY_ROLE.ITEM
	queryObj.newRole = self.ENTITY_ROLE.ITEM
	queryObj.entity = itemComponent.componentTable.hitbox
	
	local spatialSystemRequest = self.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = queryObj
	self.eventDispatcher:postEvent(2, 1, spatialSystemRequest)
	
	self.registerItemSpatialQueryPool:incrementCurrentIndex()
	self.spatialSystemRequestPool:incrementCurrentIndex()
end

function ItemSystem:unregisterItemInSpatialSystem(itemComponent)
	local queryObj = self.unregisterItemSpatialQueryPool:getCurrentAvailableObjectDefault()
	--queryObj.querySubType = 1
	--queryObj.responseCallback = nil
	queryObj.entityType = self.ENTITY_TYPE.GENERIC_ENTITY
	queryObj.entityRole = self.ENTITY_ROLE.ITEM
	queryObj.entity = itemComponent.componentTable.hitbox
	
	local spatialSystemRequest = self.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = queryObj
	self.eventDispatcher:postEvent(2, 1, spatialSystemRequest)
	
	self.unregisterItemSpatialQueryPool:incrementCurrentIndex()
	self.spatialSystemRequestPool:incrementCurrentIndex()
end

function ItemSystem:onAddItem(inventoryMethods, added, inventory, itemEntity, itemType, itemId)
	--YOU CAN'T MODIFY IT LIKE THIS ARE YOU CRAZY????
	if added then
		itemEntity.state = false
		self:unregisterItemInSpatialSystem(itemEntity)
		--output: sfx + got (?) item
	else
		--output: sfx + inventory full
	end
end

function ItemSystem:updateCollisions()
	for colId, hashTbl in pairs(self.entityItemUpdater.collisonPairsHashtables) do
		self:detectCollisions(hashTbl)
	end
end

function ItemSystem:detectCollisions(pairsHashTable)
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

function ItemSystem:detectCollision(entityA, entityB)
	if self.collisionMethods:rectToRectDetection(entityA.x, entityA.y, entityA.x + entityA.w, 
		entityA.y + entityA.h, entityB.x, entityB.y, entityB.x + entityB.w, entityB.y + entityB.h) then
		
		if entityA.componentTable.scene.role == self.ENTITY_ROLE.ENTITY_EVENT then
			self:resolveCollision(entityA, entityB)
		else
			self:resolveCollision(entityB, entityA)
		end
	end
end

function ItemSystem:resolveCollision(itemEntity, entity)
	local itemComponent = itemEntity.componentTable.item
	local inventoryComponent = entity.componentTable.inventory
	
	if itemComponent.state and inventoryComponent then
		self:getItem(inventoryComponent, itemComponent)
	end
end

function ItemSystem:getComponentsSortedByDependency()
	return self:sortComponentsByDependency(self.ENTITY_COMPONENT, 
		function(a, b) return a < b end)
end

function ItemSystem:sortComponentsByDependency(tbl, sortFunction)
	local keys = {}
	for key in pairs(tbl) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)
		return sortFunction(tbl[a], tbl[b])
	end)

	return keys
end

--debug:

function ItemSystem:debug_activateItem()
	self:activateItem('generic', 'generic', math.random(0, 800), math.random(0, 600), 1)
end

----------------
--Return Module:
----------------

return ItemSystem