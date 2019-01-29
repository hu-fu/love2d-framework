---------------
--Input System:
---------------

local PlayerInputSystem = {}

---------------
--Dependencies:
---------------

require '/event/EventObjectPool'
local SYSTEM_ID = require '/system/SYSTEM_ID'
PlayerInputSystem.EVENT_TYPES = require '/event/EVENT_TYPE'

-------------------
--System Variables:
-------------------

PlayerInputSystem.id = SYSTEM_ID.PLAYER_INPUT

PlayerInputSystem.channels = {
	simulation = require '/input/PlayerSimulationInputChannel',
}

PlayerInputSystem.activeChannel = nil

PlayerInputSystem.eventDispatcher = nil
PlayerInputSystem.eventListenerList = {}

PlayerInputSystem.playerInputRequestPool = EventObjectPool.new(PlayerInputSystem.EVENT_TYPES.PLAYER_INPUT, 10)
PlayerInputSystem.gameStateRequestPool = EventObjectPool.new(PlayerInputSystem.EVENT_TYPES.SET_GAME_STATE, 10)

----------------
--Event Methods:
----------------

PlayerInputSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			
		end
	}
}

---------------
--Init Methods:
---------------

function PlayerInputSystem:init()
	
end

---------------
--Exec Methods:
---------------

function PlayerInputSystem:setActiveChannel(channel)
	self.activeChannel = channel
end

function PlayerInputSystem:handleKeyPress(key)
	if self.activeChannel then
		self.activeChannel:handleKeyPress(self, key)
	end
end

function PlayerInputSystem:handleKeyRelease(key)
	if self.activeChannel then
		self.activeChannel:handleKeyRelease(self, key)
	end
end

function PlayerInputSystem:handleKeyHold()
	if self.activeChannel then
		for key, actions in pairs(self.activeChannel.currentKeyMapping) do
			if love.keyboard.isDown(key) then
				self.activeChannel:handleKeyHold(self, key)
			end
		end
	end
end

function PlayerInputSystem:requestInputMappingFromDatabase()
	self.channels.simulation:requestCustomMappingFromDatabase(self)
end

----------------
--Return module:
----------------

return PlayerInputSystem