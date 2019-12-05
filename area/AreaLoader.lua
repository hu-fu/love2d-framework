--------------
--Area Loader:
--------------

local AreaLoader = {}

---------------
--Dependencies:
---------------

require '/area/GameArea'
require '/area/AreaObjects'
require '/event/EventObjectPool'
require '/persistent/GameDatabaseQuery'
local SYSTEM_ID = require '/system/SYSTEM_ID'
AreaLoader.EVENT_TYPES = require '/event/EVENT_TYPE'
AreaLoader.AREA_ASSETS = require '/area/AREA_ASSET'
AreaLoader.DATABASE_TABLES = require '/persistent/DATABASE_TABLE'
AreaLoader.DATABASE_QUERY = require '/persistent/DATABASE_QUERY'

function AreaLoader:databaseQueryDefaultCallbackMethod() return function () end end
AreaLoader.databaseSystemRequestPool = EventObjectPool.new(AreaLoader.EVENT_TYPES.DATABASE_REQUEST, 10)
AreaLoader.databaseQueryPool = DatabaseQueryPool.new(10, AreaLoader.DATABASE_QUERY.GENERIC, 
	DatabaseQueryBuilder.new(), AreaLoader:databaseQueryDefaultCallbackMethod())

AreaLoader.initAreaRequestPool = EventObjectPool.new(AreaLoader.EVENT_TYPES.INIT_AREA, 10)

-------------------
--System Variables:
-------------------

AreaLoader.id = SYSTEM_ID.AREA_LOADER
AreaLoader.areaStack = AreaStack.new(4)

AreaLoader.eventDispatcher = nil
AreaLoader.eventListenerList = {}

AreaLoader.assetsFolderPath = '/area/assets/'

----------------
--Event Methods:
----------------

AreaLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			--init scene(request.sceneObj)
			AreaLoader:initScene(request.sceneObj)
		end,
		
	}
}

---------------
--Init Methods:
---------------

function AreaLoader:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function AreaLoader:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

---------------
--Exec Methods:
---------------

function AreaLoader:initScene(scene)
	local area = self:getAreaFromStack(scene.components.area.areaId)
	
	if not area then
		area = self:getAreaObject(scene.components.area.areaId)
	end
	
	self:modifyAreaByScene(area, scene)
	self:requestAreaModifier(area)
	self:pushArea(area)
	self:setAreaOnAllSystems()
end

function AreaLoader:pushArea(area)
	self.areaStack:pushArea(area)
end

function AreaLoader:getAreaFromStack(areaId)
	return self.areaStack:getArea(areaId)
end

function AreaLoader:getAreaObject(areaId)
	local assetFile = self:getAreaAssetFile(areaId)
	local areaObject = nil
	
	if assetFile then
		areaObject = self:createAreaFromAsset(assetFile)
	else
		--areaObject = default error area
	end
	
	return areaObject
end

function AreaLoader:getAreaAssetFile(areaId)
	--gets original asset (.lua file)
	local areaAsset = self.AREA_ASSETS[areaId]
	local path = self.assetsFolderPath .. areaAsset.filepath
	local assetFile = require(path)
	return assetFile
end

function AreaLoader:modifyAreaByScene(area, scene)
	--modify area using the scene var modifiers
end

function AreaLoader:createAreaFromAsset(assetFile)
	local areaObject = GameArea.new()
	
	--modify areaFile -> areaObject here:
	areaObject.main.id = assetFile.id
	areaObject.main.tag = assetFile.tag
	
	areaObject.spatial.unitWidth = assetFile.unitWidth
	areaObject.spatial.unitHeight = assetFile.unitHeight
	areaObject.spatial.maxUnitWidth = assetFile.maxUnitWidth
	areaObject.spatial.maxUnitHeight = assetFile.maxUnitHeight
	areaObject.spatial.w = assetFile.unitWidth*assetFile.maxUnitWidth
	areaObject.spatial.h = assetFile.unitHeight*assetFile.maxUnitHeight
	areaObject.spatial.minimumNodeWidth = assetFile.minimumNodeWidth
	areaObject.spatial.minimumNodeHeight = assetFile.minimumNodeHeight
	areaObject.spatial.nodeSizeMultiplier = assetFile.nodeSizeMultiplier
	
	areaObject.background.imageId = assetFile.backgroundImageId
	areaObject.background.x = assetFile.backgroundX
	areaObject.background.y = assetFile.backgroundY
	areaObject.background.xSpeed = assetFile.backgroundXSpeed
	areaObject.background.ySpeed = assetFile.backgroundYSpeed
	
	areaObject.foreground.imageId = assetFile.foregroundImageId
	areaObject.foreground.x = assetFile.foregroundX
	areaObject.foreground.y = assetFile.foregroundY
	areaObject.foreground.xSpeed = assetFile.foregroundXSpeed
	areaObject.foreground.ySpeed = assetFile.foregroundYSpeed
	
	areaObject.infiniteScrollingBackground.imageId = assetFile.infiniteScrollingBackgroundImageId
	areaObject.infiniteScrollingBackground.x = assetFile.infiniteScrollingBackgroundX
	areaObject.infiniteScrollingBackground.y = assetFile.infiniteScrollingBackgroundY
	areaObject.infiniteScrollingBackground.direction = assetFile.infiniteScrollingBackgroundDirection
	areaObject.infiniteScrollingBackground.speed = assetFile.infiniteScrollingBackgroundSpeed
	areaObject.infiniteScrollingBackground.width = assetFile.infiniteScrollingBackgroundImageWidth
	areaObject.infiniteScrollingBackground.height = assetFile.infiniteScrollingBackgroundImageHeight
	
	areaObject.spawn = assetFile.spawn
	
	return areaObject
end

function AreaLoader:requestAreaModifier(area)
	local queryObj = self.databaseQueryPool:getCurrentAvailableObject(self.DATABASE_QUERY.GENERIC)
	self.databaseQueryPool.queryBuilder:setDatabaseQueryParameters(queryObj, 'request_from_area_loader')
	self.databaseQueryPool:incrementCurrentIndex()
	queryObj.responseCallback = self:modifyAreaObjectCallback(area)
	
	local databaseSystemRequest = self.databaseSystemRequestPool:getCurrentAvailableObject()
	databaseSystemRequest.databaseQuery = queryObj
	self.eventDispatcher:postEvent(1, 1, databaseSystemRequest)
	self.databaseSystemRequestPool:incrementCurrentIndex()
end

function AreaLoader:modifyAreaObject(areaObj, areaMod)
	--do stuff, where areaMod is a db table row
end

function AreaLoader:modifyAreaObjectCallback(areaObj)
	--callback for areaObj modifier method
	return function(results) 
		self:modifyAreaObject(areaObj, results)
	end
end

function AreaLoader:setAreaOnAllSystems()
	local request = self.initAreaRequestPool:getCurrentAvailableObject()
	request.area = self.areaStack:getCurrent()
	self.setAreaOnSystemMethods[SYSTEM_ID.SPATIAL_PARTITIONING](self, request)
	self.setAreaOnSystemMethods[SYSTEM_ID.ENTITY_SPAWN](self, request)
	self.setAreaOnSystemMethods[SYSTEM_ID.GAME_RENDERER](self, request)
	self.setAreaOnSystemMethods[SYSTEM_ID.IMAGE_LOADER](self, request)
	self.initAreaRequestPool:incrementCurrentIndex()
end

AreaLoader.setAreaOnSystemMethods = {
	[SYSTEM_ID.SPATIAL_PARTITIONING] = function(self, request)
		self.eventDispatcher:postEvent(2, 2, request)
	end,
	
	[SYSTEM_ID.ENTITY_SPAWN] = function(self, request)
		self.eventDispatcher:postEvent(3, 3, request)
	end,
	
	[SYSTEM_ID.GAME_RENDERER] = function(self, request)
		self.eventDispatcher:postEvent(4, 4, request)
	end,
	
	[SYSTEM_ID.IMAGE_LOADER] = function(self, request)
		self.eventDispatcher:postEvent(5, 1, request)
	end,
}

----------------
--Return module:
----------------

return AreaLoader