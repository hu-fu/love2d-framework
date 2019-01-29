require '/state/GameState'

local voidState = GameState.new()

voidState.STATE_ID = require '/state/GAME_STATE'

function voidState:init(stateManager)
	self:reset()
end

function voidState:finish(stateManager)
	stateManager:revertState()
end

function voidState:update(stateManager, dt)
	
end

function voidState:draw(stateManager)
	if stateManager:isStateInStack(stateManager.stateTable[self.STATE_ID.TEST_STATE_C]) then
		love.graphics.setColorMask(true, false, true, true)
		stateManager.stateTable[self.STATE_ID.TEST_STATE_C]:draw(stateManager)
		love.graphics.setColorMask()
	end
	
	love.graphics.print('Void state is running', (SCREEN_W/2)-50, SCREEN_H/2)
end

function voidState:handleKeyPress(stateManager, key)
	if key == 'escape' then
		self:finish(stateManager)
	end
end

return voidState