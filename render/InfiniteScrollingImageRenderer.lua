require '/render/EntityRenderer'

local InfiniteScrollingImageRenderer = EntityRenderer.new()

InfiniteScrollingImageRenderer.imageTable = {}

function InfiniteScrollingImageRenderer:setImageTable(imageTable)
	self.imageTable = imageTable
end

function InfiniteScrollingImageRenderer:drawImage(canvas, imageId, x, y)
	--TODO: https://love2d.org/wiki/Canvas
	
	local image = self.imageTable[imageId]
	love.graphics.draw(image, (x - canvas.x), (y - canvas.y))
end

return InfiniteScrollingImageRenderer