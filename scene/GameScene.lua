---------------
--Scene Object:
---------------

GameScene = {}
GameScene.__index = GameScene

setmetatable(GameScene, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function GameScene.new ()
	local self = setmetatable ({}, GameScene)
		
		self.components = {
			main = nil,
			area = nil,
			entity = nil,
			script = nil
		}
		
	return self
end

----------------
--Scene Factory:
----------------

GameSceneBuilder = {}
GameSceneBuilder.__index = GameSceneBuilder

setmetatable(GameSceneBuilder, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function GameSceneBuilder.new ()
	local self = setmetatable ({}, GameSceneBuilder)
		self.SCENE_COMPONENTS = require '/scene/SCENE_COMPONENT'
		self.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
		
		self.createComponentMethods = nil
		self:setCreateComponentMethods()
		self.addComponentToSceneMethods = nil
		self:setAddComponentToSceneMethods()
	return self
end

function GameSceneBuilder:createScene()
	return GameScene.new()
end

function GameSceneBuilder:createCompleteScene()
	local scene = GameScene.new()
	self:createAllComponents(scene)
	return scene
end

function GameSceneBuilder:createAllComponents(scene)
	for componentName, componentId in pairs(self.SCENE_COMPONENTS) do
		self:addComponentToScene(scene, componentId, self:createComponent(componentId))
	end
end

function GameSceneBuilder:createComponent(componentType)
	return self.createComponentMethods[componentType]()
end

function GameSceneBuilder:setCreateComponentMethods()
	self.createComponentMethods = {
		
		[self.SCENE_COMPONENTS.MAIN] = function()
			return {
				componentTable = nil,
				id = 0,
				tag = ''
			}
		end,
		
		[self.SCENE_COMPONENTS.AREA] = function()
			return {
				componentTable = nil,
				areaId = 0
			}
		end,
		
		[self.SCENE_COMPONENTS.ENTITY] = function()
			return {
				componentTable = nil,
				entityList = {
					[self.ENTITY_TYPE.GENERIC_ENTITY] = {},
					[self.ENTITY_TYPE.GENERIC_WALL] = {}
				}
			}
		end,
		
		[self.SCENE_COMPONENTS.SCRIPT] = function()
			return {
				componentTable = nil,
				scriptIdList = nil
			}
		end
		
		--...
	}
end

function GameSceneBuilder:addComponentToScene(scene, componentType, component)
	self.addComponentToSceneMethods[componentType](scene, component)
end

function GameSceneBuilder:setAddComponentToSceneMethods()
	self.addComponentToSceneMethods = {
	
		[self.SCENE_COMPONENTS.MAIN] = function(scene, component)
			component.componentTable = scene.components
			scene.components.main = component
		end,
		
		[self.SCENE_COMPONENTS.AREA] = function(scene, component)
			component.componentTable = scene.components
			scene.components.area = component
		end,
		
		[self.SCENE_COMPONENTS.ENTITY] = function(scene, component)
			component.componentTable = scene.components
			scene.components.entity = component
		end,
		
		[self.SCENE_COMPONENTS.SCRIPT] = function(scene, component)
			component.componentTable = scene.components
			scene.components.script = component
		end
	}
end

--------------------
--Scene Initializer:
--------------------

GameSceneInitializer = {}
GameSceneInitializer.__index = GameSceneInitializer

setmetatable(GameSceneInitializer, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function GameSceneInitializer.new (sceneId)
	local self = setmetatable ({}, GameSceneInitializer)
		
		self.sceneId = sceneId
		
		self.extraEntities = {}		--just an idea (a good one)
		
		self.initCallback = nil
	return self
end