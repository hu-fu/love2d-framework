require '/render/EntityRenderer'

local ScrollingImageRenderer = EntityRenderer.new()

ScrollingImageRenderer.imageTable = {}

function ScrollingImageRenderer:setImageTable(imageTable)
	self.imageTable = imageTable
end

function ScrollingImageRenderer:drawImage(canvas, imageId, x, y)
	--TODO: https://love2d.org/wiki/Canvas
	
	local image = self.imageTable[imageId]
	love.graphics.draw(image, (x - canvas.x), (y - canvas.y))
end

return ScrollingImageRenderer