require '/render/RendererLayer'
require '/spatial/SpatialPartitioningObjects'
require '/spatial/SpatialEntityHashtable'
require '/spatial/SpatialPartitioningQuery'
require '/event/EventObjectPool'

local SpatialEntityLayer = RendererLayer.new(0, 0, 10, nil)

SpatialEntityLayer.entityRenderer = require '/render/SpatialEntityRenderer'
SpatialEntityLayer.spatialEntityHashtable = SpatialEntityHashtableSimple.new()

SpatialEntityLayer.EVENT_TYPES = require '/event/EVENT_TYPE'
SpatialEntityLayer.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
SpatialEntityLayer.ENTITY_TYPES = require '/entity/ENTITY_TYPE'
SpatialEntityLayer.ENTITY_ROLES = require '/entity/ENTITY_ROLE'

SpatialEntityLayer.roles = {
	--draw entities of the following roles:
	SpatialEntityLayer.ENTITY_ROLES.PLAYER,
	SpatialEntityLayer.ENTITY_ROLES.HOSTILE_NPC,
	SpatialEntityLayer.ENTITY_ROLES.OBSTACLE,
	SpatialEntityLayer.ENTITY_ROLES.BULLET,
	SpatialEntityLayer.ENTITY_ROLES.ENTITY_EVENT,
	SpatialEntityLayer.ENTITY_ROLES.ITEM	--TODO: should be in other renderer (?)
	--SpatialEntityLayer.ENTITY_ROLES.VISUAL_EFFECT
}

function SpatialEntityLayer:spatialQueryDefaultCallbackMethod() return function () end end
SpatialEntityLayer.spatialSystemRequestPool = EventObjectPool.new(SpatialEntityLayer.EVENT_TYPES.SPATIAL_REQUEST, 1)
SpatialEntityLayer.spatialQueryPool = SpatialQueryPool.new(2, SpatialEntityLayer.QUERY_TYPES.GET_ENTITIES_IN_AREA_FOR_RENDERING, 
	SpatialQueryBuilder.new(), SpatialEntityLayer:spatialQueryDefaultCallbackMethod())

function SpatialEntityLayer:update(gameRenderer)
	self:reset()
	self:requestEntityList(gameRenderer)
end

function SpatialEntityLayer:draw(canvas)
	for i=1, #self.spatialEntityHashtable.indexTable do
		self.entityRenderer:drawEntity(canvas, 
			self.spatialEntityHashtable.entityTable[self.spatialEntityHashtable.indexTable[i]])
	end
	
	--for debug only:
	--self.entityRenderer:debug_drawProjectiles(canvas)
	--self.entityRenderer:debug_drawEffects(canvas)
end

function SpatialEntityLayer:requestEntityList(gameRenderer)
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

function SpatialEntityLayer:reset()
	self.spatialEntityHashtable:reset()
	self.spatialQueryPool:resetCurrentIndex()
	self.spatialSystemRequestPool:resetCurrentIndex()
end

return SpatialEntityLayer