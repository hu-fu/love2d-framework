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
	self.systems[self.SYSTEM.PLAYER_ENTITY_CONTROLLER]:update()
	self.systems[self.SYSTEM.ENTITY_SPAWN]:update(dt)
	self.systems[self.SYSTEM.ENTITY_DESPAWN]:update(dt)
	self.systems[self.SYSTEM.IDLE]:update(dt)
	self.systems[self.SYSTEM.ENTITY_MOVEMENT]:update(dt)
	self.systems[self.SYSTEM.ENTITY_EVENT]:update(dt)
	self.systems[self.SYSTEM.COMBAT]:update(dt)
	self.systems[self.SYSTEM.ITEM]:update()
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
	self.systems[self.SYSTEM.COLLISION]:update()
	self.systems[self.SYSTEM.DIALOGUE_LOADER]:update(dt)
end

function testStateC:draw(stateManager)
	love.graphics.setColor(255, 255, 255)
	
	self.systems[self.SYSTEM.GAME_RENDERER]:draw()
	
	self:writeDebugSpatial()
	self:writeDebugInfo(10, 500)
	self:writeDialogueLines()
	
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 550)
end

function testStateC:handleKeyPress(stateManager, key)
	self.systems[self.SYSTEM.PLAYER_INPUT]:handleKeyPress(key)
end

function testStateC:handleKeyRelease(stateManager, key)
	self.systems[self.SYSTEM.PLAYER_INPUT]:handleKeyRelease(key)
end

function testStateC:handleKeyHold(stateManager)
	self.systems[self.SYSTEM.PLAYER_INPUT]:handleKeyHold()
end

--DEBUG:

function testStateC:writeDialogueLines()
	self.systems[self.SYSTEM.DIALOGUE_LOADER]:printDialogueLines()
end

function testStateC:writeDebugInfo(x, y)
	love.graphics.print(INFO_STR, x, y)
end

function testStateC:writeDebugSpatial()
	local spatialSys = self.systems[self.SYSTEM.SPATIAL_PARTITIONING]
	local role = 10
	
	if spatialSys.area then
		--spatialSys.area.grid.subGrids[1]:draw(self.systems[self.SYSTEM.CAMERA].lens.x, 
		--	self.systems[self.SYSTEM.CAMERA].lens.y)
		spatialSys.area.grid.subGrids[1]:displayTableOccupation(role, 0, 0)
	end
end

return testStateC