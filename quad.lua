-------------
--quad class:
-------------

quad = {}
quad.__index = quad

setmetatable(quad, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function quad.new (x, y, w, h)
	local self = setmetatable ({}, quad)
	
		self.x = x
		self.y = y
		self.w = w
		self.h = h
		
	return self
end