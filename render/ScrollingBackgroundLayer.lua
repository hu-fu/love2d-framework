--[[
unfinished
Not a priority
Accepts a list of images and scrolls through them in order
It should stop on the last one.
Only render the images overlapped with the camera canvas
Should have a method to push an image to the image array
]]

require '/render/RendererLayer'

local ScrollingBackgroundLayer = RendererLayer.new(0, 0, 1, nil)

local SCROLL_DIRECTION = require '/render/SCROLL_DIRECTION'

ScrollingBackgroundLayer.imageRenderer = require '/render/InfiniteScrollingImageRenderer'	--this one's fine

ScrollingBackgroundLayer.scrollingImages = nil
ScrollingBackgroundLayer.imageCoordinatesList = {}

function ScrollingBackgroundLayer:setImageList(scrollingImages)
	if scrollingImages.imageIdList then
		self.setImageListMethods[scrollingImages.direction](self, scrollingImages)
	end
end

function ScrollingBackgroundLayer:update(gameRenderer, dt)
	if self.scrollingImages then
		self.updateMethods[self.scrollingImages.direction](self, dt)
	end
end

function ScrollingBackgroundLayer:draw(canvas)
	
	if self.scrollingImages.imageId then
		for i=1, #self.coordinateList do
			
			self.imageRenderer:drawImage(canvas, self.scrollingImages.imageId, 
				self.coordinateList[i].x, self.coordinateList[i].y)
		end
	end
end

function ScrollingBackgroundLayer:reset()
	
end

ScrollingBackgroundLayer.setImageListMethods = {
	[SCROLL_DIRECTION.UP] = function(self, scrollingImages)
		
	end,
	
	[SCROLL_DIRECTION.LEFT] = function(self, scrollingImages)
		
	end,
	
	[SCROLL_DIRECTION.DOWN] = function(self, scrollingImages)
		self.scrollingImages = scrollingImages
		
		for i=1, #scrollingImages.imageParametersList then
			--set imageCoordinatesList
			
			self.imageCoordinatesList[i].x = 1
			self.imageCoordinatesList[i].y = 1
		end
	end,
	
	[SCROLL_DIRECTION.RIGHT] = function(self, scrollingImages)
		
	end,
}

ScrollingBackgroundLayer.updateMethods = {
	[SCROLL_DIRECTION.UP] = function(self, dt)
		
	end,
	
	[SCROLL_DIRECTION.LEFT] = function(self, dt)
		
	end,
	
	[SCROLL_DIRECTION.DOWN] = function(self, dt)
		local vel = self.scrollingImages.speed*dt
		
		--[[
		self.coordinateList[1].y = self.coordinateList[1].y + vel
		self.coordinateList[2].y = self.coordinateList[2].y + vel
		self.coordinateList[3].y = self.coordinateList[3].y + vel
		
		if self.coordinateList[1].y >= 0 then
			self.coordinateList[1].x = self.scrollingImages.x
			self.coordinateList[1].y = self.scrollingImages.height*-1
			
			self.coordinateList[2].x = self.scrollingImages.x
			self.coordinateList[2].y = 0
			
			self.coordinateList[3].x = self.scrollingImages.x
			self.coordinateList[3].y = self.scrollingImages.height
		end
		]]
	end,
	
	[SCROLL_DIRECTION.RIGHT] = function(self, dt)
		
	end,
}

return ScrollingBackgroundLayer