require '/render/EntityRenderer'

local ImageRenderer = EntityRenderer.new()

ImageRenderer.imageTable = {}

function ImageRenderer:setImageTable(imageTable)
	self.imageTable = imageTable
end

function ImageRenderer:drawImage(canvas, imageId, x, y, xSpeed, ySpeed)
	--TODO: https://love2d.org/wiki/Canvas
	
	local image = self.imageTable[imageId]
	love.graphics.draw(image, (x - canvas.x)*xSpeed, (y - canvas.y)*ySpeed)
end

return ImageRenderer