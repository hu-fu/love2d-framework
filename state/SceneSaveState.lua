require '/state/GameState'

local sceneSaveState = GameState.new()

function sceneSaveState:reset()
	
end

function sceneSaveState:init(stateManager, initParam)
	self:reset()
end

function sceneSaveState:update(stateManager, dt)
	--do stuff
	self:endState(stateManager)
end

function sceneSaveState:draw(stateManager)
	love.graphics.print('SAVING SCENE', 10, 10)
end

function sceneSaveState:handleKeyPress(stateManager, key)
	
end

function sceneSaveState:handleKeyRelease(stateManager, key)
	
end

function sceneSaveState:handleKeyHold(stateManager)
	
end

function sceneSaveState:endState(stateManager)
	stateManager:revertState()
end

return sceneSaveState