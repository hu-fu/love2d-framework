----------------
--Game Renderer:
----------------

local GameRenderer = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
require '/event/EventObjectPool'
GameRenderer.EVENT_TYPES = require '/event/EVENT_TYPE'

GameRenderer.canvas = require '/render/CanvasQuad'

-------------------
--System Variables:
-------------------

GameRenderer.id = SYSTEM_ID.GAME_RENDERER

GameRenderer.cameraLens = nil

GameRenderer.layers = {}
GameRenderer.activeLayers = {}

GameRenderer.eventDispatcher = nil
GameRenderer.eventListenerList = {}

----------------
--Event Methods:
----------------

GameRenderer.eventMethods = {
	[1] = {
		[1] = function(request)
			--init camera lens
			GameRenderer:setCameraLens(request.lens)
		end,
		
		[2] = function(request)
			--init sprite loader
			GameRenderer:setSpriteGraphics(request.spritesheetTable, request.quadTable)
		end,
		
		[3] = function(request)
			--init image loader
			GameRenderer:setImageGraphics(request.imageTable)
		end,
		
		[4] = function(request)
			--init area variables
			GameRenderer:setAreaGraphics(request.area)
		end,
		
		[5] = function(request)
			--init projectiles
			GameRenderer:setProjectileList(request.projectileList)
		end,
		
		[6] = function(request)
			--init global emitter
			GameRenderer:setGlobalEmitter(request.globalEmitter)
		end,
		
		[7] = function(request)
			--init entity list
			GameRenderer:setEntityList(request.entityDb)
		end,
		
		[8] = function(request)
			--init dialogue players
			GameRenderer:setActivePlayers(request.activePlayers)
		end,
		
		[9] = function(request)
			--init portrait graphics
			GameRenderer:setPortraits(request.portraits)
		end,
		
		--...
	}
}

---------------
--Init Methods:
---------------

function GameRenderer:initializeLayers()
	self.layers.spatialEntity = require '/render/SpatialEntityLayer'
	self.layers.backgroundSpatialEntity = require '/render/BackgroundSpatialEntityLayer'
	self.layers.areaBackground = require '/render/BackgroundImageLayer'
	self.layers.projectile = require '/render/ProjectileLayer'
	self.layers.effect = require '/render/EffectLayer'
	self.layers.dialogue = require '/render/DialogueLayer'
	--add more layers
end

function GameRenderer:init()
	self:initializeLayers()
end

---------------
--Exec Methods:
---------------

function GameRenderer:setCameraLens(cameraLens)
	self.cameraLens = cameraLens
end

function GameRenderer:setSpriteGraphics(spritesheetTable, quadTable)
	self.layers.spatialEntity.entityRenderer:setSpriteTables(spritesheetTable, quadTable)
	self.layers.projectile.projectileRenderer:setSpriteTables(spritesheetTable, quadTable)
	self.layers.effect.effectRenderer:setSpriteTables(spritesheetTable, quadTable)
	--set on other layers if needed
end

function GameRenderer:setImageGraphics(imageTable)
	self.layers.areaBackground.imageRenderer:setImageTable(imageTable)
	--set on other layers if needed
end

function GameRenderer:setAreaGraphics(area)
	self.layers.areaBackground.areaBackground = area.background
	--set on other layers if needed
end

function GameRenderer:setProjectileList(projectileList)
	self.layers.projectile:setProjectileList(projectileList)
end

function GameRenderer:setGlobalEmitter(emitter)
	self.layers.effect:setGlobalEmitter(emitter)
end

function GameRenderer:setEntityList(entityDb)
	self.layers.dialogue:setEntityList(entityDb)
end

function GameRenderer:setActivePlayers(activePlayers)
	self.layers.dialogue:setActivePlayers(activePlayers)
end

function GameRenderer:setPortraits(portraits)
	self.layers.dialogue:setPortraits(portraits)
end

function GameRenderer:update()
	self:updateCanvas()
	
	for i=1, #self.activeLayers do
		self.activeLayers[i]:update(self)
	end
end

function GameRenderer:draw()
	for i=1, #self.activeLayers do
		self.activeLayers[i]:draw(self.canvas)
	end
end

function GameRenderer:updateCanvas()
	if self.cameraLens then
		self.canvas:setArea(self.cameraLens.x, self.cameraLens.y, self.cameraLens.w, 
			self.cameraLens.h)
	else
		--self.canvas:setArea(0, 0, 0, 0)
	end
end

function GameRenderer:sortLayers()
	table.sort(self.activeLayers, function(a, b) return a.zIndex < b.zIndex end)
end

function GameRenderer:addLayerToList(layer)
	for i=1, #self.activeLayers do
		if layer == self.activeLayers[i] then
			return false
		end
	end
	
	table.insert(self.activeLayers, layer)
	self:sortLayers()
	return true
end

function GameRenderer:removeLayerFromList(layer)
	for i=1, #self.activeLayers do
		if layer == self.activeLayers[i] then
			table.remove(self.activeLayers, i)
			return true
		end
	end
	
	return false
end

function GameRenderer:resetLayerList()
	self.activeLayers = {}
end

function GameRenderer:setLayerZIndex(layer, zIndex)
	layer:setZIndex(zIndex)
	
	for i=1, #self.activeLayers do
		if layer == self.activeLayers[i] then
			self:sortLayers()
			break
		end
	end
end

----------------
--Return module:
----------------

return GameRenderer