GameState = {}
GameState.__index = GameState

setmetatable(GameState, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function GameState.new ()
	local self = setmetatable ({}, GameState)
		
		self.runningTime = 0
		
		self.SYSTEM = require '/system/SYSTEM_ID'
		self.systems = nil
	return self
end

function GameState:setSystems(systems)
	self.systems = systems
end

function GameState:init(stateManager, initParam)
	
end

function GameState:finish(stateManager)

end

function GameState:incrementRunningTime(dt)
	self.runningTime = self.runningTime + dt
end

function GameState:reset()
	self.runningTime = 0
end

function GameState:pause(stateManager)
	
end

function GameState:resume(stateManager)
	
end

function GameState:changeState(stateManager, state, initParam)
	stateManager:changeState(state, initParam)
end

function GameState:update(stateManager, dt)
	
end

function GameState:draw()

end

function GameState:handleKeyPress(stateManager, key)

end

function GameState:handleKeyRelease(stateManager, key)

end

function GameState:handleKeyHold(stateManager)

end