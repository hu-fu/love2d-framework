--------------
--Area Loader:
--------------

local FlagLoader = {}

---------------
--Dependencies:
---------------

require '/flag/FlagObjects'
local SYSTEM_ID = require '/system/SYSTEM_ID'
FlagLoader.FLAG = require '/flag/FLAG'
FlagLoader.EVENT_TYPES = require '/event/EVENT_TYPE'
FlagLoader.DATABASE_TABLES = require '/persistent/DATABASE_TABLE'
FlagLoader.DATABASE_QUERY = require '/persistent/DATABASE_QUERY'

function FlagLoader:databaseQueryDefaultCallbackMethod() return function () end end
FlagLoader.databaseSystemRequestPool = EventObjectPool.new(FlagLoader.EVENT_TYPES.DATABASE_REQUEST, 10)
FlagLoader.databaseQueryPool = DatabaseQueryPool.new(10, FlagLoader.DATABASE_QUERY.GENERIC, 
	DatabaseQueryBuilder.new(), FlagLoader:databaseQueryDefaultCallbackMethod())

FlagLoader.setFlagRequestPool = EventObjectPool.new(FlagLoader.EVENT_TYPES.SET_FLAG, 10)

-------------------
--System Variables:
-------------------

FlagLoader.id = SYSTEM_ID.FLAG_LOADER

FlagLoader.eventDispatcher = nil
FlagLoader.eventListenerList = {}

FlagLoader.flagDatabase = nil

----------------
--Event Methods:
----------------

FlagLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			
		end,
		
		--...
	}
}

---------------
--Init Methods:
---------------

function FlagLoader:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function FlagLoader:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function FlagLoader:init()
	self:createFlagStateMap()
end

---------------
--Exec Methods:
---------------

function FlagLoader:initState()
	self:getFlagModifier()
	self:setFlagsOnAllSystems()
end

function FlagLoader:createFlagStateMap()
	self.flagDatabase = FlagDatabase.new(self.FLAG)
end

function FlagLoader:getFlagModifier()
	--gets flag mod from in game db
	
	local queryObj = self.databaseQueryPool:getCurrentAvailableObject(self.DATABASE_QUERY.GENERIC)
	self.databaseQueryPool.queryBuilder:setDatabaseQueryParameters(queryObj, 'flag_state_table')
	self.databaseQueryPool:incrementCurrentIndex()
	queryObj.responseCallback = self:modifyFlagStateMapCallback()
	
	local databaseSystemRequest = self.databaseSystemRequestPool:getCurrentAvailableObject()
	databaseSystemRequest.databaseQuery = queryObj
	self.eventDispatcher:postEvent(1, 1, databaseSystemRequest)
	self.databaseSystemRequestPool:incrementCurrentIndex()
end

function FlagLoader:modifyFlagStateMap(flagModifier)
	self.flagDatabase:modifyAllFlags(flagModifier)
end

function FlagLoader:modifyFlagStateMapCallback()
	return function(results) 
		self:modifyFlagStateMap(results)
	end
end

function FlagLoader:saveAllFlagsState()
	
end

function FlagLoader:saveFlagState(flagId, flagState)
	--saves flag to in game database
end

function FlagLoader:setFlagState(flagId, state)
	self.flagDatabase:modifyFlag(flagId, state)
end

function FlagLoader:setFlagsOnAllSystems()
	local request = self.setFlagRequestPool:getCurrentAvailableObject()
	request.flagDb = self.flagDatabase
	self.setFlagsOnSystemMethods[SYSTEM_ID.ENTITY_EVENT](self, request)
	self.setFlagsOnSystemMethods[SYSTEM_ID.ENTITY_SCRIPT](self, request)
end

function FlagLoader:setFlagsOnSystem(systemId)
	self.setFlagsOnSystemMethods[systemId](self)
end

FlagLoader.setFlagsOnSystemMethods = {
	[SYSTEM_ID.ENTITY_EVENT] = function(self, request)
		self.eventDispatcher:postEvent(2, 2, request)
	end,
	
	[SYSTEM_ID.ENTITY_SCRIPT] = function(self, request)
		self.eventDispatcher:postEvent(3, 2, request)
	end,
}

----------------
--Return module:
----------------

return FlagLoader