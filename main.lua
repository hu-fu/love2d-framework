require 'misc'
require '/entity/GameEntity'
require '/debug/Debugger'

function love.load()
	
	------------------------screen:---------------------------
	--adjustable (just for testing):
	SCREEN_W = 800
	SCREEN_H = 600
	
	--conf.lua not working
	love.window.setMode(SCREEN_W, SCREEN_H, {fullscreen=false, resizable=true, vsync=1})
	love.window.setTitle('Project_1_2')
	
	--------------------init game state:---------------------
	INFO_STR = 0
	
	FPS_CONFIG = require '/timestep/FpsConfig'
	
	SYSTEM_INIT = require '/system/SystemInitializer'
	SYSTEM_INIT:init()
	
	local stateInit = require '/test/change_scene'
	GAME_STATE_MANAGER = require '/state/GameStateManager'
	GAME_STATE_MANAGER:init(SYSTEM_INIT:getSystems())
	GAME_STATE_MANAGER:runStateInitializer(stateInit)
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