SpatialUpdater = {}
SpatialUpdater.__index = SpatialUpdater

setmetatable(SpatialUpdater, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialUpdater.new (id)
	local self = setmetatable ({}, SpatialUpdater)
		self.id = id
		self.defaultUpdateAreaQueue = {}
		self.updateAreaQueue = {}
		self.currentFrame = 1
	return self
end

function SpatialUpdater:incrementCurrentFrame()
	self.currentFrame = self.currentFrame + 1
	if self.currentFrame > #self.updateAreaQueue then
		self.currentFrame = 1
	end
end

function SpatialUpdater:update(updateSystem, ...)
	
end

function SpatialUpdater:getCurrentUpdateArea()
	return self.updateAreaQueue[self.currentFrame]
end

function SpatialUpdater:revertAreaQueueToDefault()
	for i=#self.updateAreaQueue, 1, -1 do
		table.remove(self.updateAreaQueue)
	end
	
	for i=1, #self.defaultUpdateAreaQueue do
		table.insert(self.updateAreaQueue, self.defaultUpdateAreaQueue[i])
	end
end

function SpatialUpdater:reset()
	self.currentFrame = 1
end