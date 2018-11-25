--[[
High level input system (TEST version)
This is missing the 'current game state -> input id' layer
]]

testInputSystem = {}

testInputSystem.eventDispatcher = nil
testInputSystem.eventListenerList = {}

testInputSystem.keyInputIdMapper = require 'keyInputIdMapper'
testInputSystem.currentlyMappedKeys = testInputSystem.keyInputIdMapper:getCurrentlyMappedKeys()

local SYSTEM_ID = require '/system/SYSTEM_ID'
testInputSystem.id = SYSTEM_ID.PLAYER_INPUT

----------------
--Event Methods:
----------------

testInputSystem.eventMethods = {
	
}

---------------
--Init Methods:
---------------

function testInputSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function testInputSystem:setEventDispatcher(eventDispatcher)
	self.testInputSystem = eventDispatcher
end

---------------
--Exec Methods:
---------------

function testInputSystem:handleKeyPress(key)
	if self.keyInputIdMapper:isKeyMapped(key) then
		self.eventDispatcher:postEvent(1, 1, self.keyInputIdMapper:getPressedKeyInputId(key))
	end
end

function testInputSystem:handleKeyHold()
	for i, key in ipairs(self.currentlyMappedKeys) do
		if love.keyboard.isDown(key) then
			self.eventDispatcher:postEvent(1, 1, self.keyInputIdMapper:getHeldKeyInputId(key))
		end
	end
end

function testInputSystem:handleKeyRelease(key)
	if self.keyInputIdMapper:isKeyMapped(key) then
		self.eventDispatcher:postEvent(1, 1, self.keyInputIdMapper:getReleasedKeyInputId(key))
	end
end

----------------
--Return Module:
----------------

return testInputSystem