----------------
--Sprite Loader:
----------------

local SpriteLoader = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
require '/event/EventObjectPool'
SpriteLoader.EVENT_TYPES = require '/event/EVENT_TYPE'
SpriteLoader.SPRITESHEET = require '/graphics/SPRITESHEET'
SpriteLoader.SPRITESHEET_ASSET = require '/graphics/SPRITESHEET_ASSET'

SpriteLoader.setGraphicRequestPool = EventObjectPool.new(SpriteLoader.EVENT_TYPES.SET_GRAPHIC, 10)

-------------------
--System Variables:
-------------------

SpriteLoader.id = SYSTEM_ID.SPRITE_LOADER

SpriteLoader.folderPath = '/graphics/spritesheet'

SpriteLoader.spritesheets = {}
SpriteLoader.quads = {}
SpriteLoader.defaultSpritesheet = nil
SpriteLoader.defaultQuadTable = nil

SpriteLoader.eventDispatcher = nil
SpriteLoader.eventListenerList = {}

----------------
--Event Methods:
----------------

SpriteLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			--set entity request
				--entity loader -> sprite loader -> load all needed entity sprites :)
			
			SpriteLoader:loadSpritesByEntityDb(request.entityDb)
		end,
		
		[2] = function(request)
			--load sprite by id(s)
			
		end,
		
		--...
	}
}

---------------
--Init Methods:
---------------

function SpriteLoader:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function SpriteLoader:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function SpriteLoader:buildSpriteTables()
	self:createDefaultSprites()
	
	self.spritesheets = {}
	self.quads = {}
	
	for sheetName, sheetId in pairs(self.SPRITESHEET) do
		self.spritesheets[sheetId] = self.defaultSpritesheet
		self.quads[sheetId] = self.defaultQuadTable
	end
end

function SpriteLoader:createDefaultSprites()
	self:createDefaultSpritesheet()
	self:createDefaultQuadTable()
end

function SpriteLoader:createDefaultSpritesheet()
	self.defaultSpritesheet = self:loadSpritesheet(-1)
end

function SpriteLoader:createDefaultQuadTable()
	self.defaultQuadTable = self:loadQuadTable(-1)
end

function SpriteLoader:preloadSprites()
	--preload stuff here
	self:loadSprites(self.SPRITESHEET.DEFAULT)
end

function SpriteLoader:init()
	self:buildSpriteTables()
	self:preloadSprites()
end

---------------
--Exec Methods:
---------------

function SpriteLoader:loadSprites(spritesheetId)
	--main load function
	local spritesheet = self:loadSpritesheet(spritesheetId)
	local quadsTable = self:loadQuadTable(spritesheetId)
	self.spritesheets[spritesheetId] = spritesheet
	self.quads[spritesheetId] = quadsTable
end

function SpriteLoader:getSpritesheetAsset(spritesheetId)
	local asset = self.SPRITESHEET_ASSET[spritesheetId]
	if not asset then
		asset = self.SPRITESHEET_ASSET[self.SPRITESHEET.DEFAULT]
	end
	return asset
end

function SpriteLoader:loadSpritesheet(spritesheetId)
	local asset = self:getSpritesheetAsset(spritesheetId)
	local filepath = self.folderPath .. asset.spritesheetPath
	return love.graphics.newImage(filepath)
end

function SpriteLoader:loadQuadTable(spritesheetId)
	local asset = self:getSpritesheetAsset(spritesheetId)
	local filepath = self.folderPath .. asset.quadPath
	local quads = require(filepath)
	local quadsTable = {}
	
	for i=1, #quads do
		table.insert(quadsTable, love.graphics.newQuad(quads[i][1], quads[i][2], quads[i][3], 
			quads[i][4], quads[i][5], quads[i][6]))
	end
	
	self:setQuadTableDefaultValue(quadsTable)
	return quadsTable
end

function SpriteLoader:setQuadTableDefaultValue(t)
	local default = love.graphics.newQuad(0, 0, 0, 0, 0, 0)
	local mt = {__index = function (t) return t.___ end}
	t.___ = default
	setmetatable(t, mt)
end

function SpriteLoader:setSpriteTablesOnAllSystems()
	local request = self.setGraphicRequestPool:getCurrentAvailableObject()
	request.spritesheetTable = self.spritesheets
	request.quadTable = self.quads
	self.setSpriteTablesOnSystemMethods[SYSTEM_ID.GAME_RENDERER](self, request)
	self.setGraphicRequestPool:incrementCurrentIndex()
end

SpriteLoader.setSpriteTablesOnSystemMethods = {
	[SYSTEM_ID.GAME_RENDERER] = function(self, request)
		self.eventDispatcher:postEvent(1, 2, request)
	end,
	
	--...
}

function SpriteLoader:loadSpritesByEntityDb(entityDb)
	for entityType, entityList in pairs(entityDb.globalTables) do
		for entityIndex, entity in pairs(entityList) do
			if entity.components.spritebox then
				self:loadSprites(entity.components.spritebox.defaultSpritesheetId)
				self:loadSprites(entity.components.spritebox.spritesheetId)
			end
			
			--load from more components here
		end
	end
end

----------------
--Return module:
----------------

return SpriteLoader