--------------
--Init Script:
--------------

require 'misc'
require '/entity/GameEntity'
require '/debug/Debugger'

----------------------init globals:----------------------

INFO_STR = 0

JSON_ENCODE = require '/json/json'

FPS_CONFIG = require '/timestep/FpsConfig'

----------------------init systems:----------------------

SYSTEM_INIT = require '/system/SystemInitializer'
SYSTEM_INIT:init()
	
local stateInit = require '/test/change_scene'
GAME_STATE_MANAGER = require '/state/GameStateManager'
GAME_STATE_MANAGER:init(SYSTEM_INIT:getSystems())
GAME_STATE_MANAGER:runStateInitializer(stateInit)

---------------------init settings:----------------------

--adjustable (just for testing):
SCREEN_W = 800
SCREEN_H = 600
	
--conf.lua not working
love.window.setMode(SCREEN_W, SCREEN_H, {fullscreen=false, resizable=true, vsync=1})
love.window.setTitle('Project_1_2')

--[[
IMP: code the fileHandlingSystem

(code this here then move to config folder)
1. create config file if it doesn't exist
1.1 write config table to file (get settings table string via createTableString(tableId))
2. get file
3. get settings from file (lua table via the game db)
4. get default settings from game db
5. modify game db default settings to file settings

steps 3,4 and 5 can be done by invoking initTableFromFile(tableId, file) from game db
]]
