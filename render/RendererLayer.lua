RendererLayer = {}
RendererLayer.__index = RendererLayer

setmetatable(RendererLayer, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function RendererLayer.new (id, layerType, zIndex, entityRenderer)
	local self = setmetatable ({}, RendererLayer)
		self.id = id
		self.type = layerType
		self.zIndex = zIndex
		
		self.entityList = {}
		self.entityRenderer = entityRenderer
	return self
end

function RendererLayer:update(gameRenderer)
	--request new entity list, sort, etc
end

function RendererLayer:draw(canvas)
	
end

function RendererLayer:setZIndex(zIndex)
	self.zIndex = zIndex
end

function RendererLayer:setEntityList(entityList)
	self.entityList = entityList
end

function RendererLayer:setEntityRenderer(entityRenderer)
	self.entityRenderer = entityRenderer
end

function RendererLayer:initEntityList(nEntities)
	
end

function RendererLayer:requestEntityList(gameRenderer)
	
end

function RendererLayer:sortEntityList()

end