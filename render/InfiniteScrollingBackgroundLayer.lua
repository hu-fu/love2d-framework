require '/render/RendererLayer'

local InfiniteScrollingBackgroundLayer = RendererLayer.new(0, 0, 2, nil)

local SCROLL_DIRECTION = require '/render/SCROLL_DIRECTION'

InfiniteScrollingBackgroundLayer.imageRenderer = require '/render/InfiniteScrollingImageRenderer'

InfiniteScrollingBackgroundLayer.scrollingImage = nil
InfiniteScrollingBackgroundLayer.coordinateList = {
	{x=0, y=0}, {x=0, y=0}, {x=0, y=0}
}

function InfiniteScrollingBackgroundLayer:setImageList(scrollingImage)
	if scrollingImage.imageId then
		self.setImageListMethods[scrollingImage.direction](self, scrollingImage)
	end
end

function InfiniteScrollingBackgroundLayer:update(gameRenderer, dt)
	if self.scrollingImage then
		self.updateMethods[self.scrollingImage.direction](self, dt)
	end
end

function InfiniteScrollingBackgroundLayer:draw(canvas)
	
	if self.scrollingImage then
		for i=1, #self.coordinateList do
			
			self.imageRenderer:drawImage(canvas, self.scrollingImage.imageId, 
				self.coordinateList[i].x, self.coordinateList[i].y)
		end
	end
end

function InfiniteScrollingBackgroundLayer:reset()
	
end

InfiniteScrollingBackgroundLayer.setImageListMethods = {
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

InfiniteScrollingBackgroundLayer.updateMethods = {
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


return InfiniteScrollingBackgroundLayer