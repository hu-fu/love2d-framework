----------------
--Action Loader:
----------------

local InventoryLoader = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
InventoryLoader.EVENT_TYPES = require '/event/EVENT_TYPE'
InventoryLoader.DATABASE_TABLES = require '/persistent/DATABASE_TABLE'
InventoryLoader.DATABASE_QUERY = require '/persistent/DATABASE_QUERY'

function InventoryLoader:databaseQueryDefaultCallbackMethod() return function () end end
InventoryLoader.databaseSystemRequestPool = EventObjectPool.new(InventoryLoader.EVENT_TYPES.DATABASE_REQUEST, 10)
InventoryLoader.databaseQueryPool = DatabaseQueryPool.new(10, InventoryLoader.DATABASE_QUERY.GENERIC, 
	DatabaseQueryBuilder.new(), InventoryLoader:databaseQueryDefaultCallbackMethod())

InventoryLoader.setInventoryRequestPool = EventObjectPool.new(InventoryLoader.EVENT_TYPES.SET_INVENTORY, 10)

-------------------
--System Variables:
-------------------

InventoryLoader.id = SYSTEM_ID.INVENTORY_SYSTEM

InventoryLoader.inventoryTable = require '/item/INVENTORY_TABLE'

InventoryLoader.requestStack = {}

InventoryLoader.eventDispatcher = nil
InventoryLoader.eventListenerList = {}

----------------
--Event Methods:
----------------

InventoryLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			
		end,
		
	}
}

---------------
--Init Methods:
---------------

function InventoryLoader:initState()
	self:getInventoryModifier()
	self:setInventoryOnAllSystems()
end

function InventoryLoader:init()
	
end

---------------
--Exec Methods:
---------------

function InventoryLoader:getInventoryModifier()
	--gets inventory mod from in game db
	
	local queryObj = self.databaseQueryPool:getCurrentAvailableObject(self.DATABASE_QUERY.GENERIC)
	self.databaseQueryPool.queryBuilder:setDatabaseQueryParameters(queryObj, 'inventory_state_table')
	self.databaseQueryPool:incrementCurrentIndex()
	queryObj.responseCallback = self:modifyInventoryCallback()
	
	local databaseSystemRequest = self.databaseSystemRequestPool:getCurrentAvailableObject()
	databaseSystemRequest.databaseQuery = queryObj
	self.eventDispatcher:postEvent(1, 1, databaseSystemRequest)
	self.databaseSystemRequestPool:incrementCurrentIndex()
end

function InventoryLoader:modifyInventory(modifier)
	--TODO
end

function InventoryLoader:modifyInventoryCallback()
	return function(results) 
		self:modifyInventory(results)
	end
end

function InventoryLoader:saveInventory()
	--saves inventory table to ingame db
end

function InventoryLoader:setInventoryOnAllSystems()
	--this isn't needed, the inventory table comes directly from the file
	local request = self.setInventoryRequestPool:getCurrentAvailableObject()
	request.inventoryTable = self.inventoryTable
	--self.setFlagsOnSystemMethods[SYSTEM_ID.ENTITY_EVENT](self, request)
end

InventoryLoader.setInventoryOnSystemMethods = {
	[SYSTEM_ID.ENTITY_EVENT] = function(self, request)
		--self.eventDispatcher:postEvent(2, 2, request)
	end,
}

---------------
--Init Methods:
---------------

return InventoryLoader