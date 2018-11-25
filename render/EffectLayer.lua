require '/render/RendererLayer'
require '/spatial/SpatialPartitioningObjects'
require '/spatial/SpatialEntityHashtable'
require '/spatial/SpatialPartitioningQuery'
require '/event/EventObjectPool'

local EffectLayer = RendererLayer.new(0, 0, 11, nil)

EffectLayer.effectRenderer = require '/render/EffectRenderer'
EffectLayer.spatialEntityHashtable = SpatialEntityHashtableSimple.new()

EffectLayer.EVENT_TYPES = require '/event/EVENT_TYPE'
EffectLayer.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
EffectLayer.ENTITY_TYPES = require '/entity/ENTITY_TYPE'
EffectLayer.ENTITY_ROLES = require '/entity/ENTITY_ROLE'

EffectLayer.roles = {
	EffectLayer.ENTITY_ROLES.VISUAL_EFFECT
}

EffectLayer.globalEmitter = nil

function EffectLayer:spatialQueryDefaultCallbackMethod() return function () end end
EffectLayer.spatialSystemRequestPool = EventObjectPool.new(EffectLayer.EVENT_TYPES.SPATIAL_REQUEST, 1)
EffectLayer.spatialQueryPool = SpatialQueryPool.new(2, EffectLayer.QUERY_TYPES.GET_ENTITIES_IN_AREA_FOR_RENDERING, 
	SpatialQueryBuilder.new(), EffectLayer:spatialQueryDefaultCallbackMethod())

function EffectLayer:update(gameRenderer)
	self:reset()
	self:requestEntityList(gameRenderer)
end

function EffectLayer:draw(canvas)
	for i=1, #self.globalEmitter.effectList do
		self.effectRenderer:drawEntity(canvas, self.globalEmitter.effectList[i].components)
	end
	
	--WATCH OUT: this also fetches the global emitter!
	for i=1, #self.spatialEntityHashtable.indexTable do
		local emitter = self.spatialEntityHashtable.entityTable[self.spatialEntityHashtable.indexTable[i]].parentEntity
		
		for j=1, #emitter.effectList do
			self.effectRenderer:drawEntity(canvas, emitter.effectList[j].components)
		end
	end
end

function EffectLayer:requestEntityList(gameRenderer)
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

function EffectLayer:reset()
	self.spatialEntityHashtable:reset()
	self.spatialQueryPool:resetCurrentIndex()
	self.spatialSystemRequestPool:resetCurrentIndex()
end

function EffectLayer:setGlobalEmitter(emitter)
	self.globalEmitter = emitter
end

return EffectLayer