require '/state/GameState'

local testStateC = GameState.new()

function testStateC:init(stateManager, initParam)
	self:reset()
	self.systems[self.SYSTEM.PLAYER_INPUT]:setActiveChannel(self.systems[self.SYSTEM.PLAYER_INPUT].channels.simulation)
	self.systems[self.SYSTEM.ENTITY_SPAWN]:initScene()
end

function testStateC:update(stateManager, dt)
	self.systems[self.SYSTEM.PLAYER_INPUT]:handleKeyHold()
	self.systems[self.SYSTEM.INTERACTION]:update()
	self.systems[self.SYSTEM.ENTITY_SCRIPT]:update(dt)
	self.systems[self.SYSTEM.ENTITY_CONTROLLER]:update()
	self.systems[self.SYSTEM.ENTITY_SPAWN]:update(dt)
	self.systems[self.SYSTEM.ENTITY_DESPAWN]:update(dt)
	self.systems[self.SYSTEM.IDLE]:update(dt)
	self.systems[self.SYSTEM.ENTITY_MOVEMENT]:update(dt)
	self.systems[self.SYSTEM.ENTITY_EVENT]:update(dt)
	self.systems[self.SYSTEM.COMBAT]:update(dt)
	self.systems[self.SYSTEM.ITEM]:update()
	self.systems[self.SYSTEM.COLLISION]:update()
	self.systems[self.SYSTEM.CAMERA]:update(dt)
	self.systems[self.SYSTEM.TARGETING]:update()
	self.systems[self.SYSTEM.PROJECTILE]:update(dt)
	self.systems[self.SYSTEM.HEALTH]:update(dt)
	self.systems[self.SYSTEM.VISUAL_EFFECT]:update(dt)
	self.systems[self.SYSTEM.SOUND]:update(dt)
	self.systems[self.SYSTEM.ENTITY_ANIMATION]:update(dt)
	self.systems[self.SYSTEM.SPATIAL_UPDATE]:update(dt)
	self.systems[self.SYSTEM.GAME_RENDERER]:update()
	self.systems[self.SYSTEM.SPATIAL_PARTITIONING]:runQueries()		--maybe it should be called at the start too?
	self.systems[self.SYSTEM.DIALOGUE]:update(dt)
end

function testStateC:draw(stateManager)
	love.graphics.setColor(255, 255, 255)
	
	self.systems[self.SYSTEM.GAME_RENDERER]:draw()
	
	self:writeDebugSpatial()
	self:writeDebugInfo(10, 500)
	
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 550)
end

function testStateC:handleKeyPress(stateManager, key)
	self.systems[self.SYSTEM.PLAYER_INPUT]:handleKeyPress(key)
	
	if key == 'f5' then
		self:saveState(stateManager)
	end
	
	if key == 'f9' then
		self:loadState(stateManager)
	end
end

function testStateC:handleKeyRelease(stateManager, key)
	self.systems[self.SYSTEM.PLAYER_INPUT]:handleKeyRelease(key)
end

function testStateC:handleKeyHold(stateManager)
	self.systems[self.SYSTEM.PLAYER_INPUT]:handleKeyHold()
end

function testStateC:saveState(stateManager)
	--save game routine
	--change to sceneSaveState
	--1. save game to db
	--2. save game from db to file
	--3. resume game
	
	local databaseSystem = self.systems[18]
	local fileHandlingSystem = self.systems[42]
	local entityLoader = self.systems[21]
	local playerEntity = entityLoader:getEntityById(1, nil, nil)
	
	--save current state to db
	databaseSystem:writeToDatabase('generic_table', playerEntity)
	
	--save db state to file
	local saveFileName = 'test_save.txt'
	local SAVE_FILE = fileHandlingSystem:getFile('generic_table', saveFileName)
	local saveFileBody = databaseSystem:createTableString('generic_table')
	
	--create file if it doesn't exist
	if SAVE_FILE == nil then
		fileHandlingSystem:writeFile('generic_table', saveFileName, '...')
		SAVE_FILE = fileHandlingSystem:getFile('generic_table', saveFileName)
	end
	
	fileHandlingSystem:writeFile('generic_table', saveFileName, saveFileBody)
end

function testStateC:loadState(stateManager)
	--load game routine
	--change to sceneLoadState
	--1. load the area
	--2. modify stuff using the db (maybe load from file too - just for testing the routine)
	--3. resume game
end

--DEBUG:

function testStateC:writeDebugInfo(x, y)
	love.graphics.print(INFO_STR, x, y)
end

function testStateC:writeDebugSpatial()
	local spatialSys = self.systems[self.SYSTEM.SPATIAL_PARTITIONING]
	local role = 12
	
	if spatialSys.area then
		--spatialSys.area.grid.subGrids[1]:draw(self.systems[self.SYSTEM.CAMERA].lens.x, 
		--	self.systems[self.SYSTEM.CAMERA].lens.y)
		spatialSys.area.grid.subGrids[1]:displayTableOccupation(role, 0, 0)
	end
end

return testStateC