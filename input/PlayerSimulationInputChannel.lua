require '/input/PlayerInputChannel'

local simulationInputChannel = PlayerInputChannel.new(1)

require '/persistent/GameDatabaseQuery'
require '/event/EventObjectPool'
require '/state/StateInitializer'
simulationInputChannel.GAME_STATE = require '/state/GAME_STATE'
simulationInputChannel.EVENT_TYPES = require '/event/EVENT_TYPE'
simulationInputChannel.DATABASE_TABLES = require '/persistent/DATABASE_TABLE'
simulationInputChannel.DATABASE_QUERY = require '/persistent/DATABASE_QUERY'

simulationInputChannel.PAUSE_STATE_INITIALIZER = StateInitializer.new(simulationInputChannel.GAME_STATE.VOID)

function simulationInputChannel:databaseQueryDefaultCallbackMethod() return function () end end
simulationInputChannel.databaseSystemRequestPool = EventObjectPool.new(simulationInputChannel.EVENT_TYPES.DATABASE_REQUEST, 10)
simulationInputChannel.databaseQueryPool = DatabaseQueryPool.new(10, simulationInputChannel.DATABASE_QUERY.GET_TABLE, 
	DatabaseQueryBuilder.new(), simulationInputChannel:databaseQueryDefaultCallbackMethod())

simulationInputChannel.inputAction = require '/input/PLAYER_SIMULATION_INPUT_ACTION'

simulationInputChannel:setDefaultKeyMapping('up', simulationInputChannel.inputAction.MOVE_UP, simulationInputChannel.inputAction.END_MOVE_UP, 
	simulationInputChannel.inputAction.MOVE_UP)
simulationInputChannel:setDefaultKeyMapping('left', simulationInputChannel.inputAction.MOVE_LEFT, simulationInputChannel.inputAction.END_MOVE_LEFT, 
	simulationInputChannel.inputAction.MOVE_LEFT)
simulationInputChannel:setDefaultKeyMapping('down', simulationInputChannel.inputAction.MOVE_DOWN, simulationInputChannel.inputAction.END_MOVE_DOWN, 
	simulationInputChannel.inputAction.MOVE_DOWN)
simulationInputChannel:setDefaultKeyMapping('right', simulationInputChannel.inputAction.MOVE_RIGHT, simulationInputChannel.inputAction.END_MOVE_RIGHT, 
	simulationInputChannel.inputAction.MOVE_RIGHT)
simulationInputChannel:setDefaultKeyMapping('a', simulationInputChannel.inputAction.SET_TARGETING_STATE, simulationInputChannel.inputAction.NONE, 
	simulationInputChannel.inputAction.NONE)
simulationInputChannel:setDefaultKeyMapping('s', simulationInputChannel.inputAction.SEARCH_TARGET, simulationInputChannel.inputAction.NONE, 
	simulationInputChannel.inputAction.NONE)
simulationInputChannel:setDefaultKeyMapping('v', simulationInputChannel.inputAction.INTERACT_REQUEST, simulationInputChannel.inputAction.NONE, 
	simulationInputChannel.inputAction.NONE)
simulationInputChannel:setDefaultKeyMapping('z', simulationInputChannel.inputAction.ATTACK_A, simulationInputChannel.inputAction.END_ATTACK, 
	simulationInputChannel.inputAction.ATTACK_A)
simulationInputChannel:setDefaultKeyMapping('x', simulationInputChannel.inputAction.ATTACK_B, simulationInputChannel.inputAction.END_ATTACK, 
	simulationInputChannel.inputAction.ATTACK_B)
simulationInputChannel:setDefaultKeyMapping('c', simulationInputChannel.inputAction.ATTACK_C, simulationInputChannel.inputAction.END_ATTACK, 
	simulationInputChannel.inputAction.ATTACK_C)
simulationInputChannel:setDefaultKeyMapping('space', simulationInputChannel.inputAction.SPECIAL_MOVE, simulationInputChannel.inputAction.NONE, 
	simulationInputChannel.inputAction.NONE)
simulationInputChannel:setDefaultKeyMapping('escape', simulationInputChannel.inputAction.PAUSE, simulationInputChannel.inputAction.NONE, 
	simulationInputChannel.inputAction.NONE)

simulationInputChannel:revertToDefaultKeyMapping()

simulationInputChannel:setDefaultMappingValue(simulationInputChannel.inputAction.NONE, simulationInputChannel.inputAction.NONE, 
	simulationInputChannel.inputAction.NONE)

function simulationInputChannel:init(inputSystem)
	self:requestCustomMappingFromDatabase(inputSystem)
end

function simulationInputChannel:handleKeyPress(inputSystem, key)
	local input = self:getKeyMapping(key, self.inputType.KEY_PRESS)
	self.sendRequestMethods[input](inputSystem, self, input)
end

function simulationInputChannel:handleKeyRelease(inputSystem, key)
	local input = self:getKeyMapping(key, self.inputType.KEY_RELEASE)
	self.sendRequestMethods[input](inputSystem, self, input)
end

function simulationInputChannel:handleKeyHold(inputSystem, key)
	local input = self:getKeyMapping(key, self.inputType.KEY_HOLD)
	self.sendRequestMethods[input](inputSystem, self, input)
end

function simulationInputChannel:requestCustomMappingFromDatabase(inputSystem)
	local queryObj = self.databaseQueryPool:getCurrentAvailableObject(self.DATABASE_QUERY.GET_TABLE)
	self.databaseQueryPool.queryBuilder:setDatabaseQueryParameters(queryObj, 'input')
	self.databaseQueryPool:incrementCurrentIndex()
	queryObj.responseCallback = self:alterCustomMappingCallback()
	
	local databaseSystemRequest = self.databaseSystemRequestPool:getCurrentAvailableObject()
	databaseSystemRequest.databaseQuery = queryObj
	inputSystem.eventDispatcher:postEvent(1, 1, databaseSystemRequest)
	self.databaseSystemRequestPool:incrementCurrentIndex()
end

function simulationInputChannel:alterCustomMapping(inputMod)
	--TODO, inputMod comes from the in-gamedb
	--just for testing (chage the pause key example):
	--use the setCurrentKeyMapping function not the default one!
	
	self:setCurrentKeyMapping(inputMod['pause'], simulationInputChannel.inputAction.PAUSE, simulationInputChannel.inputAction.NONE, 
	simulationInputChannel.inputAction.NONE)
end

function simulationInputChannel:alterCustomMappingCallback()
	return function(inputMod) 
		self:alterCustomMapping(inputMod)
	end
end

simulationInputChannel.sendRequestMethods = {
	[simulationInputChannel.inputAction.NONE] = function(inputSystem, self, input)
		--do nothing
	end,
	
	[simulationInputChannel.inputAction.MOVE_UP] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.MOVE_LEFT] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.MOVE_DOWN] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.MOVE_RIGHT] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.END_MOVE_UP] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.END_MOVE_LEFT] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.END_MOVE_DOWN] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.END_MOVE_RIGHT] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.SET_TARGETING_STATE] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.SEARCH_TARGET] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.INTERACT_REQUEST] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.ATTACK_A] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.ATTACK_B] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.ATTACK_C] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.CONTINUE_ATTACK_A] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.CONTINUE_ATTACK_B] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.CONTINUE_ATTACK_C] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.END_ATTACK] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.SPECIAL_MOVE] = function(inputSystem, self, input)
		self:sendEntityControlRequest(inputSystem, input)
	end,
	
	[simulationInputChannel.inputAction.PAUSE] = function(inputSystem, self, input)
		self:sendPauseRequest(inputSystem, input)
	end,
}

function simulationInputChannel:sendEntityControlRequest(inputSystem, input)
	local request = inputSystem.playerInputRequestPool:getCurrentAvailableObject()
	request.inputId = input
	inputSystem.eventDispatcher:postEvent(2, 3, request)
	inputSystem.playerInputRequestPool:incrementCurrentIndex()
end

function simulationInputChannel:sendPauseRequest(inputSystem, input)
	local request = inputSystem.gameStateRequestPool:getCurrentAvailableObject()
	request.stateInitializer = self.PAUSE_STATE_INITIALIZER
	inputSystem.eventDispatcher:postEvent(3, 1, request)
	inputSystem.gameStateRequestPool:incrementCurrentIndex()
end

return simulationInputChannel