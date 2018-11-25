------------------------
--Spatial Update System:
------------------------

local SpatialUpdateSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
require '/spatial update/SpatialUpdateArea'

SpatialUpdateSystem.EVENT_TYPES = require '/event/EVENT_TYPE'
SpatialUpdateSystem.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
SpatialUpdateSystem.UPDATE_AREA = require '/spatial update/UPDATE_AREA'

-------------------
--System Variables:
-------------------

SpatialUpdateSystem.id = SYSTEM_ID.SPATIAL_UPDATE

SpatialUpdateSystem.cameraLens = nil

SpatialUpdateSystem.updateAreaTable = require '/spatial update/UPDATE_AREA_TABLE'
SpatialUpdateSystem.frameCounter = 1
SpatialUpdateSystem.maxFrames = 20

SpatialUpdateSystem.updaterTable = {}

function SpatialUpdateSystem:spatialQueryDefaultCallbackMethod() return function () end end
SpatialUpdateSystem.spatialSystemRequestPool = EventObjectPool.new(SpatialUpdateSystem.EVENT_TYPES.SPATIAL_REQUEST, 1)
SpatialUpdateSystem.getEntitiesQueryPool = SpatialQueryPool.new(20, SpatialUpdateSystem.QUERY_TYPES.GET_ENTITIES_IN_AREA_BY_ROLE, 
	SpatialQueryBuilder.new(), SpatialUpdateSystem:spatialQueryDefaultCallbackMethod())
SpatialUpdateSystem.getCollisionPairsQueryPool = SpatialQueryPool.new(20, SpatialUpdateSystem.QUERY_TYPES.GET_COLLISION_PAIRS_IN_AREA, 
	SpatialQueryBuilder.new(), SpatialUpdateSystem:spatialQueryDefaultCallbackMethod())

SpatialUpdateSystem.eventDispatcher = nil
SpatialUpdateSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

SpatialUpdateSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--init camera lens
			SpatialUpdateSystem:setCameraLens(request.lens)
			SpatialUpdateSystem:updateAllAreas()
		end,
		
		[2] = function(request)
			--add updater to list
			SpatialUpdateSystem:addUpdater(request.updaterObj)
		end
	}
}

---------------
--Init Methods:
---------------

function SpatialUpdateSystem:setCameraLens(cameraLens)
	self.cameraLens = cameraLens
end

function SpatialUpdateSystem:init()
	--set init updaters here
	local entityUpdater = require '/spatial update/SpatialEntityUpdater'
	self:addUpdater(entityUpdater)
end

---------------
--Exec Methods:
---------------

function SpatialUpdateSystem:update(dt)
	self:incrementFrameCounter()
	self:updateAreas()
	self:runUpdaters()
	self:resetRequestPools()
end

function SpatialUpdateSystem:resetRequestPools()
	self.getEntitiesQueryPool:resetCurrentIndex()
	self.getCollisionPairsQueryPool:resetCurrentIndex()
	self.spatialSystemRequestPool:resetCurrentIndex()
end

function SpatialUpdateSystem:updateAllAreas()
	for areaIndex, area in pairs(self.updateAreaTable) do
		area:updateArea(self.cameraLens.x, self.cameraLens.y, self.cameraLens.w, 
			self.cameraLens.h)
	end
end

function SpatialUpdateSystem:updateAreas()
	for areaIndex, area in pairs(self.updateAreaTable) do
		if self.frameCounter % area.updateFrequency == 0 then
			area:updateArea(self.cameraLens.x, self.cameraLens.y, self.cameraLens.w, 
				self.cameraLens.h)
		end
	end
end

function SpatialUpdateSystem:runUpdaters()
	for i=1, #self.updaterTable do
		self.updaterTable[i]:incrementCurrentFrame()
		self.updaterTable[i]:update(self)
	end
end

function SpatialUpdateSystem:incrementFrameCounter()
	self.frameCounter = self.frameCounter + 1
	if self.frameCounter > self.maxFrames then
		self.frameCounter = 1
	end	
end

function SpatialUpdateSystem:addUpdater(updater)
	for i=1, #self.updaterTable do
		if self.updaterTable[i] == updater then
			return nil
		end
	end
	
	updater:reset()
	table.insert(self.updaterTable, updater)
end

--DEBUG:
function SpatialUpdateSystem:printAreaVariables()
	INFO_STR = ''
	
	for i=1, #self.updateAreaTable do
		INFO_STR = INFO_STR .. ' | ' .. self.updateAreaTable[i].x .. ', ' .. self.updateAreaTable[i].y
			.. ', ' .. self.updateAreaTable[i].w .. ', ' .. self.updateAreaTable[i].h
	end
end

----------------
--Return module:
----------------

return SpatialUpdateSystem