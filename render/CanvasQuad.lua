CanvasQuad = {}
CanvasQuad.__index = CanvasQuad

setmetatable(CanvasQuad, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function CanvasQuad.new ()
	local self = setmetatable ({}, CanvasQuad)
		self.x = 0
		self.y = 0
		self.w = 0
		self.h = 0
	return self
end

function CanvasQuad:setArea(x, y, w, h)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
end

local canvasQuad = CanvasQuad.new()
return canvasQuad