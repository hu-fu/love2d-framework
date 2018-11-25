----------------------------------------
--Event system (please kill me edition):
----------------------------------------

local EventSystem = {}

---------------
--Dependencies:
---------------

require '/event/Events'
EventSystem.SYSTEM_ID = require '/system/SYSTEM_ID'
EventSystem.EVENT_LISTENER = require '/event/EVENT_LISTENER'
EventSystem.EVENT_DISPATCHER = require '/event/EVENT_DISPATCHER'
EventSystem.EVENT_ADDRESS = require '/event/EVENT_ADDRESS'

-------------------
--System Variables:
-------------------

EventSystem.id = EventSystem.SYSTEM_ID.EVENT_SYSTEM

EventSystem.listenerList = {}		--[system id] = {listener 1, ...}
EventSystem.dispatcherList = {}		--[system id] = dispatcher

EventSystem.eventDispatcher = nil
EventSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

EventSystem.eventMethods = {
	
	[1] = {
		[1] = function()
			
		end
	}
}

---------------
--Exec Methods:
---------------

function EventSystem:init()
	self:createEventSystem()
end

function EventSystem:createEventSystem()
	--creates all listeners/dispatchers according to the configuration files
	
	self:createAllListeners()
	self:createAllDispatchers()
	self:registerListenersOnDispatcherList()
end

function EventSystem:createListenerList()
	self.listenerList = {}
	
	for systemName, systemId in pairs(self.SYSTEM_ID) do
		self.listenerList[systemId] = {}
	end
end

function EventSystem:createDispatcherList()
	self.dispatcherList = {}
end

function EventSystem:createAllListeners()
	self:createListenerList()
	
	for systemName, systemId in pairs(self.SYSTEM_ID) do
		for indexName, listenerIndex in pairs(self.EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[systemId]) do
			
			local listenerId = self.EVENT_ADDRESS.SYSTEM_LISTENER_INDEX_MAP[systemId][listenerIndex]
			self.listenerList[systemId][listenerIndex] = self:createEventListener(
				listenerId, self.EVENT_ADDRESS.LISTENER_MAP[listenerId])
		end
	end
end

function EventSystem:createAllDispatchers()
	self:createDispatcherList()
	
	for systemName, systemId in pairs(self.SYSTEM_ID) do
		self.dispatcherList[systemId] = self:createEventDispatcher(
			self.EVENT_ADDRESS.SYSTEM_DISPATCHER_MAP[systemId])
	end
end

function EventSystem:createEventListener(id, map)
	return EventListener.new(id, map)
end

function EventSystem:createEventDispatcher(id)
	return EventDispatcher.new(id)
end

function EventSystem:registerListenersOnDispatcherList()
	for index, dispatcher in pairs(self.dispatcherList) do
		self:registerListenersOnDispatcher(dispatcher)
	end
end

function EventSystem:registerListenersOnDispatcher(eventDispatcher)
	for index, listeners in pairs(self.listenerList) do
		for listenerIndex, listener in pairs(listeners) do
			eventDispatcher:registerEventListener(listener)
		end
	end
end

function EventSystem:setEventVariablesOnSystem(systemModule)
	self:setListenerListOnSystem(systemModule)
	self:setDispatcherOnSystem(systemModule)
end

function EventSystem:setListenerListOnSystem(systemModule)
	if systemModule.id == nil then return nil end
	systemModule.eventListenerList = self.listenerList[systemModule.id]
	
	for listenerIndex, listener in pairs(systemModule.eventListenerList) do
		if systemModule.eventMethods[listenerIndex] ~= nil then
			for i=0, #systemModule.eventMethods[listenerIndex] do
				listener:registerFunction(i, systemModule.eventMethods[listenerIndex][i])
			end
		end
	end
end

function EventSystem:setDispatcherOnSystem(systemModule)
	if systemModule.id == nil then return nil end
	systemModule.eventDispatcher = self.dispatcherList[systemModule.id]
end

----------------
--Return Module:
----------------

return EventSystem