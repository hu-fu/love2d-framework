--------------
--Area Loader:
--------------

local SceneLoader = {}

---------------
--Dependencies:
---------------

require '/scene/SceneObjects'
require '/scene/GameScene'
require '/persistent/GameDatabaseQuery'
require '/event/EventObjectPool'
SceneLoader.SYSTEM_ID = require '/system/SYSTEM_ID'
SceneLoader.EVENT_TYPES = require '/event/EVENT_TYPE'
SceneLoader.DATABASE_TABLES = require '/persistent/DATABASE_TABLE'
SceneLoader.DATABASE_QUERY = require '/persistent/DATABASE_QUERY'
SceneLoader.SCENE = require '/scene/SCENE'
SceneLoader.SCENE_ASSET = require '/scene/SCENE_ASSET'
SceneLoader.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
SceneLoader.STATE = require '/state/GAME_STATE'

function SceneLoader:databaseQueryDefaultCallbackMethod() return function () end end
SceneLoader.databaseSystemRequestPool = EventObjectPool.new(SceneLoader.EVENT_TYPES.DATABASE_REQUEST, 10)
SceneLoader.databaseQueryPool = DatabaseQueryPool.new(10, SceneLoader.DATABASE_QUERY.GENERIC, 
	DatabaseQueryBuilder.new(), SceneLoader:databaseQueryDefaultCallbackMethod())

SceneLoader.initSceneRequestPool = EventObjectPool.new(SceneLoader.EVENT_TYPES.INIT_SCENE, 10)
SceneLoader.setGameStateRequestPool = EventObjectPool.new(SceneLoader.EVENT_TYPES.SET_GAME_STATE, 10)

-------------------
--System Variables:
-------------------

SceneLoader.id = SceneLoader.SYSTEM_ID.SCENE_LOADER
SceneLoader.sceneFactory = GameSceneBuilder.new()

SceneLoader.eventDispatcher = nil
SceneLoader.eventListenerList = {}

SceneLoader.assetsFolderPath = '/scene/assets/'

SceneLoader.sceneStack = SceneStack.new(4)	--do I need a stack?? Probably not lol

----------------
--Event Methods:
----------------

SceneLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			SceneLoader:changeScene(request)
		end,
		
		--...
	}
}

---------------
--Init Methods:
---------------

---------------
--Exec Methods:
---------------

function SceneLoader:changeScene(request)
	local sceneInitializer = self:createSceneInitializer(request.sceneId)
		
	local saveStateInitializer = StateInitializer.new(self.STATE.SCENE_SAVE)
	local loadStateInitializer = StateInitializer.new(self.STATE.SCENE_LOAD)
		
	local loaderInitParams = loadStateInitializer:getInitParameters()
	loaderInitParams.sceneInitializer = sceneInitializer
	
	--if not request.quickTransition send some transition states too
	self:sendChangeGameStateRequest(loadStateInitializer)
	self:sendChangeGameStateRequest(saveStateInitializer)
end

function SceneLoader:createSceneInitializer(sceneId, ...)
	local sceneInitializer = GameSceneInitializer.new(sceneId)
	--set other stuff
	return sceneInitializer
end

function SceneLoader:sendChangeGameStateRequest(stateInitializer)
	local changeStateRequest = self.setGameStateRequestPool:getCurrentAvailableObject()
	changeStateRequest.stateInitializer = stateInitializer
	
	self.setGameStateRequestPool:incrementCurrentIndex()
	self.eventDispatcher:postEvent(5, 1, changeStateRequest)
end

function SceneLoader:runSceneInitializer(sceneInitializer)
	--run at scene load
	self:initializeScene(sceneInitializer.sceneId, sceneInitializer)
end

function SceneLoader:initializeScene(sceneId, initParams)
	local scene = self:createScene(sceneId, initParams)
	self:pushScene(scene)
	--self:setSceneOnAllSystems()
end

function SceneLoader:pushScene(scene)
	self.sceneStack:pushScene(scene)
end

function SceneLoader:getSceneFromCache(sceneId)
	return self.sceneStack:getScene(sceneId)
end

function SceneLoader:clearSceneCache()
	self.sceneStack:clear()
end

function SceneLoader:loadSceneAsset(sceneId)
	local sceneAsset = self.SCENE_ASSET[sceneId]
	local path = self.assetsFolderPath .. sceneAsset.filepath
	local assetObj = require(path)
	return assetObj
end

function SceneLoader:createSceneFromAsset(asset)
	local sceneObj = SceneLoader.sceneFactory:createCompleteScene()
	
	sceneObj.components.main.id = asset.id
	sceneObj.components.main.tag = asset.tag
	
	sceneObj.components.area.areaId = asset.areaId
	
	sceneObj.components.entity.entityList[self.ENTITY_TYPE.GENERIC_ENTITY] = 
		asset.entityList['generic']
	
	sceneObj.components.script.scriptIdList = asset.scriptIdList
	
	return sceneObj
end

function SceneLoader:requestSceneModifier(scene)
	--get mod from ingame db
	
	local queryObj = self.databaseQueryPool:getCurrentAvailableObject(self.DATABASE_QUERY.GENERIC)
	self.databaseQueryPool.queryBuilder:setDatabaseQueryParameters(queryObj, 'scene_table')
	self.databaseQueryPool:incrementCurrentIndex()
	queryObj.responseCallback = self:modifySceneByDbCallback(scene)
	
	local databaseSystemRequest = self.databaseSystemRequestPool:getCurrentAvailableObject()
	databaseSystemRequest.databaseQuery = queryObj
	self.eventDispatcher:postEvent(1, 1, databaseSystemRequest)
	self.databaseSystemRequestPool:incrementCurrentIndex()
end

function SceneLoader:createScene(sceneId, initParams)
	local scene = self:getSceneFromCache(sceneId)
	
	if scene == nil then
		local sceneAsset = self:loadSceneAsset(sceneId)
		scene = self:createSceneFromAsset(sceneAsset)
		self:requestSceneModifier(scene)
		self:modifySceneParameters(scene, initParams)
	end
	
	return scene
end

function SceneLoader:modifySceneParameters(scene, initParams)
	--do stuff
	--use the init params to modify scene objects, like the player character and others
	--example: set entity.id new spawn point, etc
	
end

function SceneLoader:modifySceneByDbModifier(scene, sceneMod)
	--do stuff (sceneMod is the db row)
	
end

function SceneLoader:modifySceneByDbCallback(scene)
	--callback for scene modifier method
	return function(results) 
		self:modifySceneByDbModifier(scene, results)
	end
end

function SceneLoader:setSceneOnAllSystems()
	local scene = self.sceneStack:getCurrent()
	
	self.setSceneOnSystemMethods[self.SYSTEM_ID.AREA_LOADER](self, scene)
	--...
end

SceneLoader.setSceneOnSystemMethods = {
	[SceneLoader.SYSTEM_ID.AREA_LOADER] = function(sceneLoader, scene)
		local initSceneRequest = sceneLoader.initSceneRequestPool:getCurrentAvailableObject()
		initSceneRequest.sceneObj = scene
		sceneLoader.eventDispatcher:postEvent(2, 1, initSceneRequest)
		sceneLoader.initSceneRequestPool:incrementCurrentIndex()
	end,
	
	[SceneLoader.SYSTEM_ID.ENTITY_LOADER] = function(sceneLoader, scene)
		local initSceneRequest = sceneLoader.initSceneRequestPool:getCurrentAvailableObject()
		initSceneRequest.sceneObj = scene
		sceneLoader.eventDispatcher:postEvent(3, 1, initSceneRequest)
		sceneLoader.initSceneRequestPool:incrementCurrentIndex()
	end,
	
	[SceneLoader.SYSTEM_ID.SCENE_SCRIPT] = function(sceneLoader, scene)
		local initSceneRequest = sceneLoader.initSceneRequestPool:getCurrentAvailableObject()
		initSceneRequest.sceneObj = scene
		sceneLoader.eventDispatcher:postEvent(4, 1, initSceneRequest)
		sceneLoader.initSceneRequestPool:incrementCurrentIndex()
	end,
	
	--...
}

----------------
--Return module:
----------------

return SceneLoader