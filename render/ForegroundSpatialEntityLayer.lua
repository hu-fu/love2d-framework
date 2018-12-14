require '/render/RendererLayer'
require '/spatial/SpatialPartitioningObjects'
require '/spatial/SpatialEntityHashtable'
require '/spatial/SpatialPartitioningQuery'
require '/event/EventObjectPool'

local ForegroundSpatialEntityLayer = RendererLayer.new(0, 0, 100, nil)

ForegroundSpatialEntityLayer.entityRenderer = require '/render/SpatialEntityRenderer'
ForegroundSpatialEntityLayer.spatialEntityHashtable = SpatialEntityHashtableSimple.new()

ForegroundSpatialEntityLayer.EVENT_TYPES = require '/event/EVENT_TYPE'
ForegroundSpatialEntityLayer.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
ForegroundSpatialEntityLayer.ENTITY_TYPES = require '/entity/ENTITY_TYPE'
ForegroundSpatialEntityLayer.ENTITY_ROLES = require '/entity/ENTITY_ROLE'

ForegroundSpatialEntityLayer.roles = {
	ForegroundSpatialEntityLayer.ENTITY_ROLES.FOREGROUND_OBJECT
}

function ForegroundSpatialEntityLayer:spatialQueryDefaultCallForeMethod() return function () end end
ForegroundSpatialEntityLayer.spatialSystemRequestPool = EventObjectPool.new(ForegroundSpatialEntityLayer.EVENT_TYPES.SPATIAL_REQUEST, 1)
ForegroundSpatialEntityLayer.spatialQueryPool = SpatialQueryPool.new(2, ForegroundSpatialEntityLayer.QUERY_TYPES.GET_ENTITIES_IN_AREA_FOR_RENDERING, 
	SpatialQueryBuilder.new(), ForegroundSpatialEntityLayer:spatialQueryDefaultCallForeMethod())

function ForegroundSpatialEntityLayer:update(gameRenderer)
	--TODO: if not spatial update then DO NOT reset the list OR request a new one!
	self:reset()
	self:requestEntityList(gameRenderer)
end

function ForegroundSpatialEntityLayer:draw(canvas)
	for i=1, #self.spatialEntityHashtable.indexTable do
		self.entityRenderer:drawEntity(canvas, 
			self.spatialEntityHashtable.entityTable[self.spatialEntityHashtable.indexTable[i]])
	end
end

function ForegroundSpatialEntityLayer:requestEntityList(gameRenderer)
	local queryObj = self.spatialQueryPool:getCurrentAvailableObjectDefault()
	--queryObj.querySubType = 1
	queryObj.spatialEntityHashtable = self.spatialEntityHashtable
	queryObj.spatialEntityList = self.entityList
	queryObj.areaX = gameRenderer.canvas.x
	queryObj.areaY = gameRenderer.canvas.y
	queryObj.areaW = gameRenderer.canvas.w
	queryObj.areaH = gameRenderer.canvas.h
	queryObj.roles = self.roles
	
	local spatialSystemRequest = self.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = queryObj
	gameRenderer.eventDispatcher:postEvent(1, 1, spatialSystemRequest)
	
	self.spatialQueryPool:incrementCurrentIndex()
	self.spatialSystemRequestPool:incrementCurrentIndex()
end

function ForegroundSpatialEntityLayer:reset()
	self.spatialEntityHashtable:reset()
	self.spatialQueryPool:resetCurrentIndex()
	self.spatialSystemRequestPool:resetCurrentIndex()
end

return ForegroundSpatialEntityLayer