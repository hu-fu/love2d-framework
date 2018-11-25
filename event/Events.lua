------------------------
--eventDispatcher class:
------------------------
--[[
General usage:
eventDispatcher:postEvent(eventType, methodIndex, eventData)
The event is routed to all listeners registered with the specified event type
]]

EventDispatcher = {}
EventDispatcher.__index = EventDispatcher

setmetatable(EventDispatcher, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EventDispatcher.new (id)
	local self = setmetatable ({}, EventDispatcher)

		self.id = id
		self.eventListenerTable = {}
	return self
end

function EventDispatcher:registerEventListener(eventListener)
	if eventListener.eventDispatcherMap[self.id] then
		local eventTypeList = eventListener.eventDispatcherMap[self.id]
		for i=1, #eventTypeList do
			if self.eventListenerTable[eventTypeList[i]] == nil then
				self.eventListenerTable[eventTypeList[i]] = {}
			end
			table.insert(self.eventListenerTable[eventTypeList[i]], eventListener)
		end
	end
end

function EventDispatcher:postEvent(eventType, methodIndex, eventData)
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

EventListener = {}
EventListener.__index = EventListener

setmetatable(EventListener, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EventListener.new (id, eventDispatcherMap)
	local self = setmetatable ({}, EventListener)
		
		self.id = id
		
		self.functionList = {}
		
		self.eventDispatcherMap = eventDispatcherMap	--[dispatcher global id] = {type1, type2, type3, (...)}
		
	return self
end

function EventListener:registerFunction(eventType, func)
	self.functionList[eventType] = func
end