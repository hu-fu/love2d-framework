----------------
--Sprite Loader:
----------------

local ImageLoader = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
require '/event/EventObjectPool'
ImageLoader.EVENT_TYPES = require '/event/EVENT_TYPE'
ImageLoader.IMAGE = require '/graphics/IMAGE'
ImageLoader.IMAGE_ASSET = require '/graphics/IMAGE_ASSET'

ImageLoader.setGraphicRequestPool = EventObjectPool.new(ImageLoader.EVENT_TYPES.SET_GRAPHIC, 10)

-------------------
--System Variables:
-------------------

ImageLoader.id = SYSTEM_ID.IMAGE_LOADER

ImageLoader.folderPath = '/graphics/image'

ImageLoader.images = {}
ImageLoader.defaultImage = nil

ImageLoader.eventDispatcher = nil
ImageLoader.eventListenerList = {}

----------------
--Event Methods:
----------------

ImageLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			--set area request
				--area loader -> image loader -> load all needed images
					--request.area
						--how about unloading previous area images??
			ImageLoader:loadImagesByArea(request.area)
		end,
		
		[2] = function(request)
			--load image by id(s)
			
		end,
		
		--...
	}
}

---------------
--Init Methods:
---------------

function ImageLoader:buildImageTable()
	self:createDefaultImage()
	
	self.images = {}
	
	for imageName, imageId in pairs(self.IMAGE) do
		self.images[imageId] = self.defaultImage
	end
end

function ImageLoader:createDefaultImage()
	self.defaultImage = self:getImage(-1)
end

function ImageLoader:preloadImages()
	--preload stuff here
	self:loadImage(self.IMAGE.DEFAULT)
end

function ImageLoader:init()
	self:buildImageTable()
	self:preloadImages()
end

---------------
--Exec Methods:
---------------

function ImageLoader:getImage(imageId)
	local asset = self:getImageAsset(imageId)
	local filepath = self.folderPath .. asset.imagePath
	return love.graphics.newImage(filepath)
end

function ImageLoader:loadImage(imageId)
	local asset = self:getImageAsset(imageId)
	local filepath = self.folderPath .. asset.imagePath
	self.images[imageId] = love.graphics.newImage(filepath)
end

function ImageLoader:getImageAsset(imageId)
	local asset = self.IMAGE_ASSET[imageId]
	if not asset then
		asset = self.IMAGE_ASSET[self.IMAGE.DEFAULT]
	end
	return asset
end

function ImageLoader:setImageTablesOnAllSystems()
	local request = self.setGraphicRequestPool:getCurrentAvailableObject()
	request.imageTable = self.images
	self.setImageTablesOnSystemMethods[SYSTEM_ID.GAME_RENDERER](self, request)
	self.setGraphicRequestPool:incrementCurrentIndex()
end

ImageLoader.setImageTablesOnSystemMethods = {
	[SYSTEM_ID.GAME_RENDERER] = function(self, request)
		self.eventDispatcher:postEvent(1, 3, request)
	end,
	
	--...
}

function ImageLoader:loadImagesByArea(area)
	if area.background.imageId then
		self:loadImage(area.background.imageId)
	end
	
	if area.foreground.imageId then
		self:loadImage(area.foreground.imageId)
	end
	
	if area.infiniteScrollingBackground.imageId then
		self:loadImage(area.infiniteScrollingBackground.imageId)
	end
end

----------------
--Return module:
----------------

return ImageLoader