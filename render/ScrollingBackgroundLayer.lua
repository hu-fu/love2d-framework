require '/render/RendererLayer'

local ScrollingBackgroundLayer = RendererLayer.new(0, 0, 3, nil)

local SCROLL_DIRECTION = require '/render/SCROLL_DIRECTION'

ScrollingBackgroundLayer.imageRenderer = require '/render/ScrollingImageRenderer'

ScrollingBackgroundLayer.scrollingImage = nil
ScrollingBackgroundLayer.coordinateList = {
	{x=0, y=0}, {x=0, y=0}, {x=0, y=0}
}

function ScrollingBackgroundLayer:setImageList(scrollingImage)
	if scrollingImage.imageId then
		self.setImageListMethods[scrollingImage.direction](self, scrollingImage)
	end
end

function ScrollingBackgroundLayer:update(gameRenderer, dt)
	if self.scrollingImage.imageId then
		self.updateMethods[self.scrollingImage.direction](self, dt)
	end
end

function ScrollingBackgroundLayer:draw(canvas)
	
	if self.scrollingImage.imageId then
		for i=1, #self.coordinateList do
			
			self.imageRenderer:drawImage(canvas, self.scrollingImage.imageId, 
				self.coordinateList[i].x, self.coordinateList[i].y)
		end
	end
end

function ScrollingBackgroundLayer:reset()
	
end

ScrollingBackgroundLayer.setImageListMethods = {
	[SCROLL_DIRECTION.UP] = function(self, scrollingImage)
		self.scrollingImage = scrollingImage
		
		self.coordinateList[1].x = scrollingImage.x
		self.coordinateList[1].y = scrollingImage.height*-1
		
		self.coordinateList[2].x = scrollingImage.x
		self.coordinateList[2].y = 0
		
		self.coordinateList[3].x = scrollingImage.x
		self.coordinateList[3].y = scrollingImage.height
	end,
	
	[SCROLL_DIRECTION.LEFT] = function(self, scrollingImage)
		
	end,
	
	[SCROLL_DIRECTION.DOWN] = function(self, scrollingImage)
		self.setImageListMethods[SCROLL_DIRECTION.UP](self, scrollingImage)
	end,
	
	[SCROLL_DIRECTION.RIGHT] = function(self, scrollingImage)
		
	end,
}

ScrollingBackgroundLayer.updateMethods = {
	[SCROLL_DIRECTION.UP] = function(self, dt)
		
	end,
	
	[SCROLL_DIRECTION.LEFT] = function(self, dt)
		
	end,
	
	[SCROLL_DIRECTION.DOWN] = function(self, dt)
		local vel = self.scrollingImage.speed*dt
		
		self.coordinateList[1].y = self.coordinateList[1].y + vel
		self.coordinateList[2].y = self.coordinateList[2].y + vel
		self.coordinateList[3].y = self.coordinateList[3].y + vel
		
		if self.coordinateList[1].y >= 0 then
			self.coordinateList[1].x = self.scrollingImage.x
			self.coordinateList[1].y = self.scrollingImage.height*-1
			
			self.coordinateList[2].x = self.scrollingImage.x
			self.coordinateList[2].y = 0
			
			self.coordinateList[3].x = self.scrollingImage.x
			self.coordinateList[3].y = self.scrollingImage.height
		end
	end,
	
	[SCROLL_DIRECTION.RIGHT] = function(self, dt)
		
	end,
}


return ScrollingBackgroundLayer