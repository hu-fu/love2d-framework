SpatialUpdateArea = {}
SpatialUpdateArea.__index = SpatialUpdateArea

setmetatable(SpatialUpdateArea, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialUpdateArea.new (name, updateFrequency, widthMod, heightMod, x, y, w, h, 
	minX, minY, maxW, maxH)
	local self = setmetatable ({}, SpatialUpdateArea)
		self.name = name
		
		self.updateFrequency = updateFrequency
		
		self.widthMod = widthMod
		self.heightMod = heightMod
		
		self.x = x
		self.y = y
		self.w = w
		self.h = h
		
		self.minX = minX
		self.minY = minY
		self.maxW = maxW
		self.maxH = maxH
	return self
end

function SpatialUpdateArea:setModifiers(widthMod, heightMod)
	self.widthMod = widthMod
	self.heightMod = heightMod
end

function SpatialUpdateArea:setQuad(x, y, w, h)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
end

function SpatialUpdateArea:setBoundary(maxX, maxY, maxW, maxH)
	self.maxX = maxX
	self.maxY = maxY
	self.maxW = maxW
	self.maxH = maxH
end

function SpatialUpdateArea:updateArea(x, y, w, h)
	local modifiedW = w*self.widthMod
	local modifiedH = h*self.heightMod
	self.x = ((x + (x+w))/2) - (modifiedW/2)
	self.y = ((y + (y+h))/2) - (modifiedH/2)
	self.w = modifiedW
	self.h = modifiedH
end

function SpatialUpdateArea:updateBounds()
	if self.x < self.minX then
		self.x = self.minX
	end
	if self.y < self.minY then
		self.y = self.minY
	end
	if self.w > self.maxW then
		self.w = self.maxW
	end
	if self.h > self.maxH then
		self.h = self.maxH
	end
end