require '/render/RendererLayer'

local ForegroundImageLayer = RendererLayer.new(0, 0, 101, nil)

ForegroundImageLayer.imageRenderer = require '/render/ImageRenderer'

ForegroundImageLayer.areaForeground = nil

function ForegroundImageLayer:setAreaForeground(areaForeground)
	self.areaForeground = areaForeground
end

function ForegroundImageLayer:update(gameRenderer)
	
end

function ForegroundImageLayer:draw(canvas)
	if self.areaForeground then
	
		self.imageRenderer:drawImage(canvas, self.areaForeground.imageId, 
			self.areaForeground.x, self.areaForeground.y, self.areaForeground.xSpeed, 
			self.areaForeground.ySpeed)
	end
end

function ForegroundImageLayer:reset()
	
end

return ForegroundImageLayer