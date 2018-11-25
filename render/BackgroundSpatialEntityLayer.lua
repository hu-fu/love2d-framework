require '/render/RendererLayer'
require '/spatial/SpatialPartitioningObjects'
require '/spatial/SpatialEntityHashtable'
require '/spatial/SpatialPartitioningQuery'
require '/event/EventObjectPool'

local BackgroundSpatialEntityLayer = RendererLayer.new(1, 0, 5, nil)

BackgroundSpatialEntityLayer.entityRenderer = require '/render/SpatialEntityRenderer'
BackgroundSpatialEntityLayer.spatialEntityHashtable = SpatialEntityHashtableSimple.new()

BackgroundSpatialEntityLayer.EVENT_TYPES = require '/event/EVENT_TYPE'
BackgroundSpatialEntityLayer.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
BackgroundSpatialEntityLayer.ENTITY_TYPES = require '/entity/ENTITY_TYPE'
BackgroundSpatialEntityLayer.ENTITY_ROLES = require '/entity/ENTITY_ROLE'

BackgroundSpatialEntityLayer.roles = {
	BackgroundSpatialEntityLayer.ENTITY_ROLES.BACKGROUND_OBJECT
}

function BackgroundSpatialEntityLayer:spatialQueryDefaultCallbackMethod() return function () end end
BackgroundSpatialEntityLayer.spatialSystemRequestPool = EventObjectPool.new(BackgroundSpatialEntityLayer.EVENT_TYPES.SPATIAL_REQUEST, 1)
BackgroundSpatialEntityLayer.spatialQueryPool = SpatialQueryPool.new(2, BackgroundSpatialEntityLayer.QUERY_TYPES.GET_ENTITIES_IN_AREA_FOR_RENDERING, 
	SpatialQueryBuilder.new(), BackgroundSpatialEntityLayer:spatialQueryDefaultCallbackMethod())

function BackgroundSpatialEntityLayer:update(gameRenderer)
	--TODO: if not spatial update then DO NOT reset the list OR request a new one!
	self:reset()
	self:requestEntityList(gameRenderer)
end

function BackgroundSpatialEntityLayer:draw(canvas)
	for i=1, #self.spatialEntityHashtable.indexTable do
		self.entityRenderer:drawEntity(canvas, 
			self.spatialEntityHashtable.entityTable[self.spatialEntityHashtable.indexTable[i]])
	end
end

function BackgroundSpatialEntityLayer:requestEntityList(gameRenderer)
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

function BackgroundSpatialEntityLayer:reset()
	self.spatialEntityHashtable:reset()
	self.spatialQueryPool:resetCurrentIndex()
	self.spatialSystemRequestPool:resetCurrentIndex()
end

return BackgroundSpatialEntityLayer