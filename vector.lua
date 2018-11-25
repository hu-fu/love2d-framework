---------------
--vector class:
---------------

vector = {}
vector.__index = vector

setmetatable(vector, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})
	
function vector.new (x, y)
	local self = setmetatable ({}, vector)
		self.x = x
		self.y = y
	return self
end

function vector:subtraction(vector)
	return vector.new(vector.x - self.x, vector.y - self.y)
end

function vector:getLength()
	return math.sqrt(self.x^2 + self.y^2)
end

function vector:normalize()
	local length = self:length()
	if length ~= 0 then
		return vector.new(self.x/length, self.y/length)
	else
		return vector.new(0, 0)
	end
end