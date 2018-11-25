require '/state/GameState'

local testStateB = GameState.new()

function testStateB:init(stateManager)
	self:reset()
	self:resetStateVariables()
	self:initializeStateVariables()
	self:load()
end

function testStateB:initializeStateVariables()
	FUG = 0
	
	self.currentAreaMap = areaMap.new(0,0,0,0)
	self.playerCamera = playerCamera.new(0, 0, SCREEN_W, SCREEN_H, 10)
	self.areaRenderer = areaRenderer.new()
	self.debugger = debugger.new()
	self.entityTables = {}
	self.eventSystem = require '/event/EventSystem'
	self.areaLoadSystem = require 'areaLoadSystem'
	self.systemTest = require 'systemTest'
	self.ENTITY_ROLES = require 'ENTITY_ROLE'
	self.ENTITY_TYPES = require '/entity/ENTITY_TYPE'
	self.ENTITY_COMPONENTS = require '/entity/ENTITY_COMPONENT'
	self.mapToQuadsConverter = require 'mapToQuadsConverter'
	self.entityArea = actionArea.new(self.playerCamera.x, self.playerCamera.y)
	self.playerHostilePairsManager = collisionPairsManager.new(100, true, true)
	self.playerObstaclePairsManager = collisionPairsManager.new(100, true, true)
	self.hostileObstaclePairsManager = collisionPairsManager.new(100, true, true)
	self.hostileHostilePairsManager = collisionPairsManager.new(100, true, true)
	
	--new test stuff (should have gone into the systemTest file but whatever):
	require '/event/Events'
	
	--system(new):
	self.eventSystem:init()
	
	self.eventSystem:setEventVariablesOnSystem(self.systemTest.animationSystem)
	self.eventSystem:setEventVariablesOnSystem(self.systemTest.animatedIdleSystem)
	self.eventSystem:setEventVariablesOnSystem(self.systemTest.playerEntityControllerSystem)
	self.eventSystem:setEventVariablesOnSystem(self.systemTest.entityMovementSystem)
	self.eventSystem:setEventVariablesOnSystem(self.systemTest.playerEntityInputSystem)
	self.eventSystem:setEventVariablesOnSystem(self.systemTest.spatialPartitioningSystem)
	self.eventSystem:setEventVariablesOnSystem(self.systemTest.targetingSystem)
	self.eventSystem:setEventVariablesOnSystem(self.systemTest.collisionSystem)
	
	--renderer(new):
	self.gameRenderer = require '/render/GameRenderer'
	self.spatialEntityLayer = require '/render/SpatialEntityLayer'
	self.eventSystem:setEventVariablesOnSystem(self.spatialEntityLayer)
	self.gameRenderer:addLayerToList(self.spatialEntityLayer)
	
	--animation(new):
	self.animationLoader = require '/animation/AnimationLoader'
	self.entityAnimationSystem = require '/animation/EntityAnimationSystem'
	self.eventSystem:setEventVariablesOnSystem(self.entityAnimationSystem)
	self.eventSystem:setEventVariablesOnSystem(self.animationLoader)
	
	--action(new):
	self.actionLoader = require '/action/ActionLoader'
	self.entityActionSystem = require '/action/EntityActionSystem'
	self.eventSystem:setEventVariablesOnSystem(self.actionLoader)
	self.eventSystem:setEventVariablesOnSystem(self.entityActionSystem)
	
	--projectile(new):
	self.projectileSystem = require '/projectile/ProjectileSystem'
	self.projectileSystem:createProjectileTemplateTable()
	self.projectileSystem:createSpawnTable()
	self.projectileSystem:createControllerTable()
	self.projectileSystem:createDestructorTable()
	self.projectileSystem:createAnimationTable()
	
	--interaction(new):
	self.interactionSystem = require '/interaction/InteractionSystem'
	self.eventSystem:setEventVariablesOnSystem(self.interactionSystem)
	
	--effect(new):
	self.visualEffectSystem = require '/effect/VisualEffectSystem'
	self.visualEffectSystem:createEffectTemplateTable()
	self.visualEffectSystem:createControllerTable()
	self.visualEffectSystem:initializeEffectObjects()
end

function testStateB:resetStateVariables()
	self.currentAreaMap = nil
	self.playerCamera = nil
	self.areaRenderer = nil
	self.debugger = nil
	self.entityTables = nil
	self.areaLoadSystem = nil
	self.systemTest = nil
	self.ENTITY_ROLES = nil
	self.ENTITY_TYPES = nil
	self.ENTITY_COMPONENTS = nil
	self.mapToQuadsConverter = nil
	self.entityArea = nil
	self.playerHostilePairsManager = nil
	self.playerObstaclePairsManager = nil
	self.hostileObstaclePairsManager = nil
	self.hostileHostilePairsManager = nil
	self.gameRenderer = nil
	self.spatialEntityLayer = nil
	self.animationLoader = nil
	self.entityAnimationSystem = nil
	self.actionLoader = nil
	self.entityActionSystem = nil
	self.eventSystem = nil
	self.interactionSystem = nil
	self.visualEffectSystem = nil
end

function testStateB:load()
	
	for i=1, 3 do self.debugger.debugStrings[i] = '' end
	
	--------------------load state prototype:-----------------
	--Area load system routine:
	
	self.areaLoadSystem:setAreaId(1)
	self.areaLoadSystem:setAreaFile()
	self.areaLoadSystem:updateAreaMap(self.currentAreaMap)
	self.areaLoadSystem:updatePlayerCamera(self.playerCamera)
	self.areaLoadSystem:updateAreaRenderer(self.areaRenderer, self.currentAreaMap, self.playerCamera)
	--self.areaLoadSystem:createEntities(entityTables)	--adds entities on the map file to the created tables
	self.areaLoadSystem:setEntitySprites(self.areaRenderer)
	self.areaLoadSystem:setProjectileSprites(self.areaRenderer)
	
	--new renderer stuff:
	self.areaLoadSystem:setEntitySprites(self.spatialEntityLayer.entityRenderer)
	self.areaLoadSystem:setProjectileSprites(self.spatialEntityLayer.entityRenderer)
	self.areaLoadSystem:setEffectSprites(self.spatialEntityLayer.entityRenderer)
	
	-------------------------others:--------------------------
	
	self.areaRenderer:setSpriteList1(self.systemTest.entityDatabases[self.ENTITY_TYPES.GENERIC_ENTITY]:getTableRows('entitySpriteboxTable'))
	
	local mapQuads = self.mapToQuadsConverter:getMapQuads(self.currentAreaMap, self.currentAreaMap.tileLayer1)
	for i=1, #mapQuads do
		--just for testing. components must be created by type
		
		table.insert(self.systemTest.obstacleDatabase.tables['globalEntityTable'], self.systemTest.gameEntityBuilder:createEntity())
		table.insert(self.systemTest.obstacleDatabase.tables['entityMainTable'], self.systemTest.gameEntityBuilder:createComponent(self.ENTITY_COMPONENTS.MAIN))
		table.insert(self.systemTest.obstacleDatabase.tables['entitySceneTable'], self.systemTest.gameEntityBuilder:createComponent(self.ENTITY_COMPONENTS.SCENE))
		table.insert(self.systemTest.obstacleDatabase.tables['entitySpriteboxTable'], self.systemTest.gameEntityBuilder:createComponent(self.ENTITY_COMPONENTS.SPRITEBOX))
		table.insert(self.systemTest.obstacleDatabase.tables['entityAnimatedIdleTable'], self.systemTest.gameEntityBuilder:createComponent(self.ENTITY_COMPONENTS.IDLE))
		table.insert(self.systemTest.obstacleDatabase.tables['entityHitboxTable'], self.systemTest.gameEntityBuilder:createComponent(self.ENTITY_COMPONENTS.HITBOX))
		
		self.systemTest.gameEntityBuilder:addComponentToEntity(self.systemTest.obstacleDatabase.tables['globalEntityTable'][i], 
			self.ENTITY_COMPONENTS.MAIN, self.systemTest.obstacleDatabase.tables['entityMainTable'][i])
		self.systemTest.gameEntityBuilder:addComponentToEntity(self.systemTest.obstacleDatabase.tables['globalEntityTable'][i], 
			self.ENTITY_COMPONENTS.SCENE, self.systemTest.obstacleDatabase.tables['entitySceneTable'][i])
		self.systemTest.gameEntityBuilder:addComponentToEntity(self.systemTest.obstacleDatabase.tables['globalEntityTable'][i], 
			self.ENTITY_COMPONENTS.SPRITEBOX, self.systemTest.obstacleDatabase.tables['entitySpriteboxTable'][i])
		self.systemTest.gameEntityBuilder:addComponentToEntity(self.systemTest.obstacleDatabase.tables['globalEntityTable'][i], 
			self.ENTITY_COMPONENTS.IDLE, self.systemTest.obstacleDatabase.tables['entityAnimatedIdleTable'][i])
		self.systemTest.gameEntityBuilder:addComponentToEntity(self.systemTest.obstacleDatabase.tables['globalEntityTable'][1], 
			self.ENTITY_COMPONENTS.HITBOX, self.systemTest.obstacleDatabase.tables['entityHitboxTable'][i])
		
		self.systemTest.obstacleDatabase.tables['entitySceneTable'][i].role, self.systemTest.obstacleDatabase.tables['entityHitboxTable'][i].x, 
		self.systemTest.obstacleDatabase.tables['entityHitboxTable'][i].y, self.systemTest.obstacleDatabase.tables['entityHitboxTable'][i].w, 
		self.systemTest.obstacleDatabase.tables['entityHitboxTable'][i].h = 
		self.ENTITY_ROLES.OBSTACLE, mapQuads[i].x, mapQuads[i].y, mapQuads[i].w, mapQuads[i].h 
	end
	
	self.areaLoadSystem.areaFile.entityList = self.systemTest.entityDatabases
	self.systemTest.spatialPartitioningSystem:addArea(self.areaLoadSystem.areaFile, true)
	--self.areaCreationSystem:setAreaEntityDatabase(self.areaLoadSystem.areaFile.areaId, 
	--	self.areaLoadSystem.areaFile.entityList)
	
	self.systemTest.targetingSystem:buildTargetTable(self.systemTest.entityDatabases)
	self.systemTest.targetingSystem:createSpatialQueryPool(5)
	
	for i = 1, #self.systemTest.animatedIdleSystem.animatedIdleComponentTable do
		local direction = math.random(1,8)
		self.systemTest.animatedIdleSystem:startState(self.systemTest.animatedIdleSystem.animatedIdleComponentTable[i], 
			direction)
	end
	
	self.entityArea:createAreaQuad(0, 0, self.playerCamera.w, self.playerCamera.h)
	
	self.playerHostilePairsManager:buildPairsTable()
	self.playerObstaclePairsManager:buildPairsTable()
	self.hostileObstaclePairsManager:buildPairsTable()
	self.hostileHostilePairsManager:buildPairsTable()
	
	--animation(new):
	self.entityAnimationSystem:setSpriteComponentList(self.systemTest.entityDatabase.tables['entitySpriteboxTable'])
	
	--action(new):
	self.entityActionSystem:setActionComponentList(self.systemTest.entityDatabase.tables['entityActionTable'])
	self.entityActionSystem:getAction(1, 1, self.systemTest.entityDatabase.tables['entityActionTable'][1])
	
	--interaction(new):
	
	--projectile(new):
	self.spatialEntityLayer.entityRenderer.projectileList = self.projectileSystem.projectileObjectPool.objectPool
	
	--visual effect(new):
	self.spatialEntityLayer.entityRenderer.effectList = self.visualEffectSystem.objectPool[2].objectPool
end

function testStateB:update(stateManager, dt)
	
	--if dt < 1/5 then love.timer.sleep(1/5 - dt) end		--use to test lower frame rates
	
	self.debugger:resetDebugStrings()
	self.playerHostilePairsManager:resetHashChain()
	
	self.systemTest.playerEntityInputSystem:handleKeyHold()
	
	self.systemTest.playerEntityControllerSystem:main()
	
	self.systemTest.animatedIdleSystem:main(dt)
	
	self.systemTest.entityMovementSystem:main(dt)
		
	for i=1, #self.systemTest.spatialPartitioningSystem.areas[1].entityList[self.ENTITY_TYPES.GENERIC_ENTITY] do
		self.systemTest.spatialPartitioningSystem:updateEntityPosition(
			self.ENTITY_TYPES.GENERIC_ENTITY, 
			self.systemTest.spatialPartitioningSystem.areas[1].entityList[self.ENTITY_TYPES.GENERIC_ENTITY][i],
			self.systemTest.spatialPartitioningSystem.areas[1].grid)
	end
	
	self.systemTest.spatialPartitioningSystem:getCollisionPairsInArea(
		1, self.systemTest.spatialPartitioningSystem.areas[1].grid, (self.entityArea.x + self.entityArea.areas[1].tx),
		(self.entityArea.y + self.entityArea.areas[1].ty), self.entityArea.areas[1].w, self.entityArea.areas[1].h, 
		self.ENTITY_ROLES.PLAYER, self.ENTITY_ROLES.HOSTILE_NPC, self.playerHostilePairsManager)
	
	self.systemTest.collisionSystem:detectCollisions(self.playerHostilePairsManager)
	
	self.systemTest.spatialPartitioningSystem:getCollisionPairsInArea(
		1, self.systemTest.spatialPartitioningSystem.areas[1].grid, (self.entityArea.x + self.entityArea.areas[1].tx),
		(self.entityArea.y + self.entityArea.areas[1].ty), self.entityArea.areas[1].w,self.entityArea.areas[1].h, 
		self.ENTITY_ROLES.PLAYER, self.ENTITY_ROLES.OBSTACLE, self.playerObstaclePairsManager)
	
	self.systemTest.collisionSystem:detectCollisions(self.playerObstaclePairsManager)
	
	self.systemTest.spatialPartitioningSystem:getCollisionPairsInArea(
		1, self.systemTest.spatialPartitioningSystem.areas[1].grid, (self.entityArea.x + self.entityArea.areas[1].tx),
		(self.entityArea.y + self.entityArea.areas[1].ty), self.entityArea.areas[1].w, self.entityArea.areas[1].h, 
		self.ENTITY_ROLES.HOSTILE_NPC, self.ENTITY_ROLES.OBSTACLE, self.hostileObstaclePairsManager)
	
	self.systemTest.collisionSystem:detectCollisions(self.hostileObstaclePairsManager)
	
	self.systemTest.spatialPartitioningSystem:getCollisionPairsInArea(
		1, self.systemTest.spatialPartitioningSystem.areas[1].grid, 
		(self.entityArea.x + self.entityArea.areas[1].tx), (self.entityArea.y + self.entityArea.areas[1].ty), 
		self.entityArea.areas[1].w, self.entityArea.areas[1].h, self.ENTITY_ROLES.HOSTILE_NPC, self.ENTITY_ROLES.HOSTILE_NPC,
		self.hostileHostilePairsManager)
	
	self.systemTest.collisionSystem:detectCollisions(self.hostileHostilePairsManager)
	
	self.playerCamera.x, self.playerCamera.y = math.floor(self.systemTest.entityDatabase.tables['entityHitboxTable'][1].x
		- (self.playerCamera.w/2) + (self.systemTest.entityDatabase.tables['entityHitboxTable'][1].w/2)), 
		math.floor(self.systemTest.entityDatabase.tables['entityHitboxTable'][1].y - (self.playerCamera.h/2) + 
		(self.systemTest.entityDatabase.tables['entityHitboxTable'][1].h/2))
	
	--self.playerCamera:keyHold()
		
	self.entityArea:changePosition(self.playerCamera.x, self.playerCamera.y)
	
	self.gameRenderer:updateCanvas(self.playerCamera.x, self.playerCamera.y, self.playerCamera.w, 
		self.playerCamera.h)
	self.gameRenderer:update()
	
	self.systemTest.spatialPartitioningSystem:runQueries()
	
	self.systemTest.targetingSystem:main()
	
	self.entityActionSystem:main(dt)
	
	self.entityAnimationSystem:main(dt)
	
	self.interactionSystem:main(dt)
	
	self.debugger.profiler:start()
	
		--profile stuff here
		
		self.projectileSystem:main(dt)
		self.visualEffectSystem:main(dt)
		
	self.debugger.profiler:stop()
end

function testStateB:draw(stateManager)
	
	local status, camX, camY = self.playerCamera:tilemapIndexModification(64, 64)
	
	self.areaRenderer:drawScene(self.playerCamera, self.currentAreaMap.tileW, self.currentAreaMap.tileH)
	self.gameRenderer:draw()
	
	--debug text goes below:
	love.graphics.setColor(255, 255, 255)
		
		love.graphics.print('1: toggle profiling data | WASD: move camera |', 10, 10)
		love.graphics.print('FPS = ' .. love.timer.getFPS(), 10, 30)
		love.graphics.print('camera x, y = ' .. self.playerCamera.x .. ', ' .. self.playerCamera.y, 10, 50)
		love.graphics.print('camera status, Ix, Iy = ' .. tostring(status) .. ', ' .. camX .. ', ' .. camY, 10, 60)
		
		love.graphics.print('Spritebatch count: ' .. self.areaRenderer.layers[2]:getCount(), 10, 80)
		
		love.graphics.print(self.systemTest.entityDatabase.tables['entityHitboxTable'][1].x, 10, 100)
		love.graphics.print(self.systemTest.entityDatabase.tables['entityHitboxTable'][1].y, 10, 110)
		
		self.systemTest.spatialPartitioningSystem.areas[1].grid.subGrids[1]:draw(self.playerCamera)
		self.systemTest.spatialPartitioningSystem.areas[1].grid.subGrids[1]:displayTableOccupation(self.ENTITY_ROLES.HOSTILE_NPC, 10, 130)
		
		--[[
		love.graphics.print(tostring(self.systemTest.spatialPartitioningSystem.areas[1].entityList[self.ENTITY_TYPES.GENERIC_ENTITY][1].spatialIndexX),
			10, 250)
		love.graphics.print(tostring(self.systemTest.spatialPartitioningSystem.areas[1].entityList[self.ENTITY_TYPES.GENERIC_ENTITY][1].spatialIndexY),
			10, 260)
		love.graphics.print(tostring(self.systemTest.spatialPartitioningSystem.areas[1].entityList[self.ENTITY_TYPES.GENERIC_ENTITY][1].xOverlap),
			10, 270)
		love.graphics.print(tostring(self.systemTest.spatialPartitioningSystem.areas[1].entityList[self.ENTITY_TYPES.GENERIC_ENTITY][1].yOverlap),
			10, 280)
		]]
		
		love.graphics.print(tostring(self.systemTest.entityDatabase.tables['entityAnimatedIdleTable'][1].state), 10, 300)
		
		love.graphics.print(FUG, 10, 320)
		
		self.systemTest.targetingSystem:drawEntityQuad(self.systemTest.entityDatabase.tables['entityTargetingTable'][1], self.playerCamera)
		self.interactionSystem:drawDebugInteraction(self.playerCamera)
		
		--self.debugger:printDebugStrings(10, 340)
		
		self.debugger:showProfilerData(10, (SCREEN_H - #self.debugger.profiler.reports*10 - 20))
		
	love.graphics.setColor(255, 255, 255)
end

function testStateB:handleKeyPress(stateManager, key)
	self.debugger:keyPress(key)
	self.systemTest.playerEntityInputSystem:handleKeyPress(key)
	
	if key == 'p' then
		self:initializeVoidState(stateManager)
	end
	
	if key == 'i' then
		--interaction test:
		local interactionRequest = {}
		
		interactionRequest.interactionType , interactionRequest.x, interactionRequest.y,
		interactionRequest.w, interactionRequest.h, interactionRequest.originEntity, 
		interactionRequest.originRole, interactionRequest.targetRoleGroup = 
			1, self.systemTest.entityDatabase.tables['entityHitboxTable'][1].x - 50, 
			self.systemTest.entityDatabase.tables['entityHitboxTable'][1].y - 50,
			self.systemTest.entityDatabase.tables['entityHitboxTable'][1].w + 100,
			self.systemTest.entityDatabase.tables['entityHitboxTable'][1].h + 100,
			self.systemTest.entityDatabase.tables['entityHitboxTable'][1],
			self.systemTest.entityDatabase.tables['entitySceneTable'][1].role,
			self.interactionSystem.ENTITY_ROLE_GROUP.ENEMY
		
		self.interactionSystem.eventMethods[1][1](interactionRequest)
	end
	
	if key == 'f' then
		--press button -> shoot bullets lmao
		for i=1, 10 do
			self.projectileSystem:activateSpawn(1, 1, 
				self.systemTest.entityDatabase.tables['entityHitboxTable'][1], 1, 
				self.systemTest.entityDatabase.tables['entityHitboxTable'][1].x + math.random(-100,100), 
				self.systemTest.entityDatabase.tables['entityHitboxTable'][1].y + math.random(-100,100),
				math.random(0,360), nil, nil)
		end
	end
	
	if key == 'e' then
		local effectRequest = {}
	
		effectRequest.numberOfEffects, effectRequest.effectType, effectRequest.templateType,
		effectRequest.lifeTime, effectRequest.x, effectRequest.y, effectRequest.direction,
		effectRequest.senderRef, effectRequest.targetRef, effectRequest.targetList,
		effectRequest.pathObject, effectRequest.callback = 5, 1, nil, 
		self.systemTest.entityDatabase.tables['entityHitboxTable'][1].x,
		self.systemTest.entityDatabase.tables['entityHitboxTable'][1].y,
		math.random(0,360), self.systemTest.entityDatabase.tables['entityHitboxTable'][1],
		nil, nil, nil, nil
		
		self.visualEffectSystem.eventMethods[1][1](effectRequest)
	end
end

function testStateB:handleKeyRelease(stateManager, key)
	self.systemTest.playerEntityInputSystem:handleKeyRelease(key)
end

function testStateB:handleKeyHold(stateManager)

end

function testStateB:initializeVoidState(stateManager)
	self:changeState(stateManager, stateManager.stateTable[stateManager.STATE_ID.VOID])
	--we can send additional commands to the void state here (ex: loadArea(self.params))
end

return testStateB