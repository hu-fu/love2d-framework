------------------------
--eventDispatcher class:
------------------------
--[[
General usage:
eventDispatcher:postEvent(eventType, methodIndex, eventData)
The event is routed to all listeners registered with the specified event type
]]

eventDispatcher = {}
eventDispatcher.__index = eventDispatcher

setmetatable(eventDispatcher, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function eventDispatcher.new (id, eventListenerTableLength, eventTypeNames)
	local self = setmetatable ({}, eventDispatcher)

		self.id = id

		self.eventListenerTable = {}
		self.eventTypeNames = eventTypeNames	--dictionary

		self:buildEventListenerTable(eventListenerTableLength)
	return self
end

function eventDispatcher:buildEventListenerTable(eventListenerTableLength)
	for i=1, eventListenerTableLength do
		self.eventListenerTable[i] = {}
	end
end

function eventDispatcher:registerEventListener(eventListener)
	if eventListener.eventDispatcherMap[self.id] then
		local eventTypeList = eventListener.eventDispatcherMap[self.id]
		for i=1, #eventTypeList do
			table.insert(self.eventListenerTable[eventTypeList[i]], eventListener)
		end
	end
end

function eventDispatcher:postEvent(eventType, methodIndex, eventData)
	for i=1, #self.eventListenerTable[eventType] do
		self.eventListenerTable[eventType][i].functionList[methodIndex](eventData)
	end
end

----------------------
--eventListener class:
----------------------
--[[
eventDispatcherMap = {
	[dispatcher ID] = {type1, type2, (...)},
	(...)
}
]]

eventListener = {}
eventListener.__index = eventListener

setmetatable(eventListener, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function eventListener.new (id, eventDispatcherMap)
	local self = setmetatable ({}, eventListener)
		
		self.id = id
		
		self.functionList = {}
		
		self.eventDispatcherMap = eventDispatcherMap	--[dispatcher global id] = {type1, type2, type3, (...)}
		
	return self
end

function eventListener:registerFunction(eventType, func)
	self.functionList[eventType] = func
end