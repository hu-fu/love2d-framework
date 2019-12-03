require '/render/RendererLayer'

local BackgroundImageLayer = RendererLayer.new(0, 0, 2, nil)

BackgroundImageLayer.imageRenderer = require '/render/ImageRenderer'

BackgroundImageLayer.areaBackground = nil

function BackgroundImageLayer:setAreaBackground(areaBackground)
	self.areaBackground = areaBackground
end

function BackgroundImageLayer:update(gameRenderer)
	
end

function BackgroundImageLayer:draw(canvas)
	if self.areaBackground then
	
		self.imageRenderer:drawImage(canvas, self.areaBackground.imageId, 
			self.areaBackground.x, self.areaBackground.y, self.areaBackground.xSpeed, 
			self.areaBackground.ySpeed)
	end
end

function BackgroundImageLayer:reset()
	
end

return BackgroundImageLayer