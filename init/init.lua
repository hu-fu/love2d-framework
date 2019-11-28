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
local fileHandlingSystem = SYSTEM_INIT.systemTable[42]

local SETTINGS_FILE = fileHandlingSystem:getFile('settings')

if SETTINGS_FILE == nil then
	local settingsFileBody = databaseSystem:createTableString('settings')
	fileHandlingSystem:writeFile('settings', '', settingsFileBody)
	SETTINGS_FILE = fileHandlingSystem:getFile('settings')
end

databaseSystem:initTableFromFile('settings', SETTINGS_FILE)

local SCREEN_W = databaseSystem.gameDatabase['settings']['screen_w']
local SCREEN_H = databaseSystem.gameDatabase['settings']['screen_h']
love.window.setMode(SCREEN_W, SCREEN_H, {fullscreen=false, resizable=true, vsync=1})

------------------------load starting scene:-----------------------------------

--init scene from database:

--init the table with the values in the file
local saveFileName = 'test_save.txt'
local SAVE_FILE = fileHandlingSystem:getFile('generic_table', saveFileName)
databaseSystem:initTableFromFile('generic_table', SAVE_FILE)

--build a new state initializer with the parameters from the db
--local sceneInitializer = GameSceneInitializer.new(databaseSystem.gameDatabase['generic_table'][1].sceneId)	--this is the correct line, I just don't want to crash my old pc
local sceneInitializer = GameSceneInitializer.new(1)	--hardcoded sceneId=1, see line above
local stateInitializer = StateInitializer.new(4)
local stateInitParams = stateInitializer:getInitParameters()
stateInitParams.sceneInitializer = sceneInitializer

--init the scene
GAME_STATE_MANAGER = require '/state/GameStateManager'
GAME_STATE_MANAGER:init(SYSTEM_INIT:getSystems())
GAME_STATE_MANAGER:runStateInitializer(stateInitializer)
