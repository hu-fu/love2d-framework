function love.load()
	require '/init/init'
end

function love.update(dt)
	FPS_CONFIG:capFramerate(dt)
	GAME_STATE_MANAGER:update(dt)
end

function love.draw()
	love.graphics.scale(1.0, 1.0)
	GAME_STATE_MANAGER:draw()
end

function love.keypressed( key )
	GAME_STATE_MANAGER:handleKeyPress(key)
end

function love.keyreleased( key )
	GAME_STATE_MANAGER:handleKeyRelease(key)
end