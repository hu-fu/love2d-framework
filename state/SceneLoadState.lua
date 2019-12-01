--should be called scene transition state -> save previous state info -> load new state info
--(BETTER) or divided into two states : scene save state AND scene load state
--rewrite this so it resets all systems accordingly

require '/state/GameState'
require '/state/StateInitializer'

local sceneLoadState = GameState.new()

sceneLoadState.stateInitializer = StateInitializer.new(5)

sceneLoadState.initParam = nil
sceneLoadState.TRANSITION = false
sceneLoadState.SCENE_INIT = false
sceneLoadState.AREA_INIT = false
sceneLoadState.ENTITY_INIT = false
sceneLoadState.SCRIPT_INIT = false
sceneLoadState.RENDERER_INIT = false

function sceneLoadState:reset()
	self.initParam = nil
	self.TRANSITION = false
	self.SCENE_INIT = false
	self.AREA_INIT = false
	self.ENTITY_INIT = false
	self.SCRIPT_INIT = false
	self.RENDERER_INIT = false
end

function sceneLoadState:init(stateManager, initParam)
	self:reset()
	self.initParam = initParam
	--run transition(self.initParam.transitionType)
	self:initFlag()		--should be initiated way before this (on game file load) --this is going to be deprecated!
end

function sceneLoadState:update(stateManager, dt)
	--watch out brother this thing runs every frame (no shit)
	--while not transition:
	--transition:run(dt)
	--if transition over:
	
	if not self.SCENE_INIT then
		self:initScene()
		self.SCENE_INIT = true
	end
	
	if self.SCENE_INIT and not self.AREA_INIT then
		self:initArea()
		self.AREA_INIT = true
	end
	
	if self.AREA_INIT and not self.ENTITY_INIT then
		self:initEntity()
		--create a script to modify entity.id according to some sceneInit parameters,
			--like a spawn point or other stuff
		self.ENTITY_INIT = true
	end
	
	if self.ENTITY_INIT and not self.SCRIPT_INIT then
		self:initScript()
		self.SCRIPT_INIT = true
	end
	
	if self.SCRIPT_INIT and not self.RENDERER_INIT then
		self:initRenderer()
		self.RENDERER_INIT = true
	end
	
	if self.RENDERER_INIT then
		--initialize the rest of the stuff, start simulation scene
		self:initCamera()
		self:initItem()
		self:initImageLoader()
		self:initProjectiles()
		self:initVisualEffects()
		self:initDialogue()
		self:initInput()
		self:initializeSceneState(stateManager)
	end
	
	--set * on components
	--start scene sim on state manager
end

function sceneLoadState:draw(stateManager)
	love.graphics.print('LOADING SCENE:', 10, 10)
	love.graphics.print('System table: ' .. #self.systems, 10, 20)
	--love.graphics.print(self.systems[self.SYSTEM.GAME_DATABASE]:getDatabaseRow('generic_table', 2)['id'], 10, 30)
	love.graphics.print('System table: ' .. #self.systems, 10, 20)
	--love.graphics.print(self.initParam.sceneInitializer.var_1, 10, 30)
	self:writeDebugInfo(10, 500)
end

function sceneLoadState:handleKeyPress(stateManager, key)
	
end

function sceneLoadState:handleKeyRelease(stateManager, key)
	
end

function sceneLoadState:handleKeyHold(stateManager)
	
end

function sceneLoadState:initFlag()
	local flagLoader = self.systems[self.SYSTEM.FLAG_LOADER]
	flagLoader:initState()
end

function sceneLoadState:initScene()
	local sceneLoader = self.systems[self.SYSTEM.SCENE_LOADER]
	sceneLoader:runSceneInitializer(self.initParam.sceneInitializer)
end

function sceneLoadState:initArea()
	local sceneLoader = self.systems[self.SYSTEM.SCENE_LOADER]
	sceneLoader.setSceneOnSystemMethods[sceneLoader.SYSTEM_ID.AREA_LOADER](sceneLoader, 
		sceneLoader.sceneStack:getCurrent())
end

function sceneLoadState:initEntity()
	local sceneLoader = self.systems[self.SYSTEM.SCENE_LOADER]
	sceneLoader.setSceneOnSystemMethods[sceneLoader.SYSTEM_ID.ENTITY_LOADER](sceneLoader, 
		sceneLoader.sceneStack:getCurrent())
end

function sceneLoadState:initScript()
	local sceneLoader = self.systems[self.SYSTEM.SCENE_LOADER]
	sceneLoader.setSceneOnSystemMethods[sceneLoader.SYSTEM_ID.SCENE_SCRIPT](sceneLoader, 
		sceneLoader.sceneStack:getCurrent())
end

function sceneLoadState:initializeSceneState(stateManager)
	local initParam = self.stateInitializer:getInitParameters()
	self:changeState(stateManager, stateManager.stateTable[stateManager.STATE_ID.TEST_STATE_C],
		initParam)
end

function sceneLoadState:initRenderer()
	--I don't know where this should go, maybe here, maybe before this
	local gameRenderer = self.systems[self.SYSTEM.GAME_RENDERER]
	gameRenderer:addLayerToList(gameRenderer.layers.spatialEntity)
	gameRenderer:addLayerToList(gameRenderer.layers.backgroundSpatialEntity)
	gameRenderer:addLayerToList(gameRenderer.layers.areaBackground)
	gameRenderer:addLayerToList(gameRenderer.layers.projectile)
	gameRenderer:addLayerToList(gameRenderer.layers.effect)
	gameRenderer:addLayerToList(gameRenderer.layers.dialogue)
	gameRenderer:addLayerToList(gameRenderer.layers.foregroundSpatialEntity)
end

function sceneLoadState:initInput()
	--this should go before this; at the start obviously; 
		--called again after INPUT mapping modifications
	local inputSystem = self.systems[self.SYSTEM.PLAYER_INPUT]
	inputSystem:setActiveChannel(inputSystem.channels.simulation)
	inputSystem:requestInputMappingFromDatabase()
end

function sceneLoadState:initCamera()
	local cameraSystem = self.systems[self.SYSTEM.CAMERA]
	cameraSystem:initBehaviour(cameraSystem.CAMERA_BEHAVIOUR.TEST_FOLLOW, nil)
end

function sceneLoadState:initItem()
	local itemSystem = self.systems[self.SYSTEM.ITEM]
	itemSystem:initScene()
end

function sceneLoadState:initImageLoader()
	--should be called only once on game start
	local imageLoaderSystem = self.systems[self.SYSTEM.IMAGE_LOADER]
	imageLoaderSystem:setImageTablesOnAllSystems()
end

function sceneLoadState:initProjectiles()
	local projectileSystem = self.systems[self.SYSTEM.PROJECTILE]
	projectileSystem:initProjectilesOnSystems()
end

function sceneLoadState:initVisualEffects()
	local effectSystem = self.systems[self.SYSTEM.VISUAL_EFFECT]
	self.systems[self.SYSTEM.VISUAL_EFFECT]:initGlobalEmitter()
	effectSystem:initGlobalEmitterOnSystems()
end

function sceneLoadState:initDialogue()
	self.systems[self.SYSTEM.DIALOGUE]:setActivePlayersOnGameRenderer()
end

--DEBUG:

function sceneLoadState:writeDebugInfo(x, y)
	love.graphics.print(INFO_STR, x, y)
end

return sceneLoadState