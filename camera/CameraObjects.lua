--------------
--Camera lens:
--------------

CameraLens = {}
CameraLens.__index = CameraLens

setmetatable(CameraLens, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function CameraLens.new ()
	local self = setmetatable ({}, CameraLens)
		self.x = 0
		self.y = 0
		self.w = 0
		self.h = 0
		self.zoom = 0
		self.filter = 0
		self.vel = 0
		
		self.spatialX = 0
		self.spatialY = 0
		self.spatialUpdate = false
	return self
end