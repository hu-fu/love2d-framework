--------------
--Init Script:
--------------

require 'misc'
require '/entity/GameEntity'
require '/debug/Debugger'

----------------------init globals:----------------------

INFO_STR = 0

FPS_CONFIG = require '/timestep/FpsConfig'

----------------------init systems:----------------------

SYSTEM_INIT = require '/system/SystemInitializer'
SYSTEM_INIT:init()

---------------------init settings:----------------------

love.window.setTitle('Project_1_2')

---------------------------load settings routine:------------------------------

local databaseSystem = SYSTEM_INIT.systemTable[18]
local fileSHandlingSystem = SYSTEM_INIT.systemTable[42]

local SETTINGS_FILE = fileSHandlingSystem:getFile('settings')

if SETTINGS_FILE == nil then
	local settingsFileBody = databaseSystem:createTableString('settings')
	fileSHandlingSystem:writeFile('settings', '', settingsFileBody)
	local SETTINGS_FILE = fileSHandlingSystem:getFile('settings')
end

databaseSystem:initTableFromFile('settings', SETTINGS_FILE)

local SCREEN_W = databaseSystem.gameDatabase['settings']['screen_w']
local SCREEN_H = databaseSystem.gameDatabase['settings']['screen_h']
love.window.setMode(SCREEN_W, SCREEN_H, {fullscreen=false, resizable=true, vsync=1})

------------------------load starting scene:-----------------------------------

local stateInit = require '/test/change_scene'
GAME_STATE_MANAGER = require '/state/GameStateManager'
GAME_STATE_MANAGER:init(SYSTEM_INIT:getSystems())
GAME_STATE_MANAGER:runStateInitializer(stateInit)
