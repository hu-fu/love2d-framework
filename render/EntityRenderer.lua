EntityRenderer = {}
EntityRenderer.__index = EntityRenderer

setmetatable(EntityRenderer, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EntityRenderer.new ()
	local self = setmetatable ({}, EntityRenderer)
		
	return self
end

function EntityRenderer:drawEntity(canvas, entity)

end