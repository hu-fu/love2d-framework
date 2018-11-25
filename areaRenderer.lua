require 'misc'

---------------
--areaRenderer:
---------------

--[[
NEEDS AN URGENT (not that urgent, this is enough for testing) REWRITE!
How about subdividing this into different systems?

Methods for accepting 'load sprite' requests:
	should work as a queue
	requests = {req1, req2, req3}
	complete 1 -> 2 requests/frame or unlimited if in another thread

DEPRECATED!!
]]--

areaRenderer = {}
areaRenderer.__index = areaRenderer

setmetatable(areaRenderer, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function areaRenderer.new ()
	local self = setmetatable ({}, areaRenderer)
		
		self.DATABASE_COLUMNS = require 'DATABASE_COLUMN'
		
		self.tileLayer1 = {}
		self.tileLayer2 = {}
		
		self.tileSpritesheet = nil
		self.entitySpritesheet = {}	--[spritesheet ID] = spritesheet
		self.particleSpritesheet = {}
		self.projectileSpritesheet = {}
		self.interfaceSpritesheet = {}
		
		self.tileSpritesheetQuads = {}
		self.entitySpritesheetQuads = {}
		self.particleSpritesheetQuads = {}
		self.projectileSpritesheetQuads = {}
		self.interfaceSpritesheetQuads = {}
		
		self.layers = {
			[1] = false,	--background
			[2] = false,	--tileLayer -> spritebatch
			[3] = false,	--spriteList1
			[4] = false,	--particleList1
			[5] = false,	--tileLayer2 -> spritebatch
			[6] = false,	--spriteList2
			[7] = false,	--particleList2
			[8] = false,	--overlay
			[9] = false,	--interfaceList
			[10] = false	--projectileList
		}

		self.defaultSprite = love.graphics.newImage('/graphics/default/default.png')
		self.defaultQuad = love.graphics.newQuad(0, 0, 0, 0, 0, 0)
		
	return self
end

function areaRenderer:fullReset()
	self:resetTileLayer1()
	self:resetTileLayer2()
	self:resetTileSpritesheet()
	self:resetEntitySpritesheet()
	self:resetParticleSpritesheet()
	self:resetInterfaceSpritesheet()
	self:resetTileSpritesheetQuads()
	self:resetEntitySpritesheetQuads()
	self:resetParticleSpritesheetQuads()
	self:resetInterfaceSpritesheetQuads()
	self:resetLayers()
end

function areaRenderer:resetTileLayer1()
	self.tileLayer1 = {}
end

function areaRenderer:resetTileLayer2()
	self.tileLayer2 = {}
end

function areaRenderer:resetTileSpritesheet()
	self.tileSpritesheet = nil
end

function areaRenderer:resetEntitySpritesheet()
	self.entitySpritesheet = {}
	setDefaultTableValue(self.entitySpritesheet, self.defaultSprite)
end

function areaRenderer:resetParticleSpritesheet()
	self.particleSpritesheet = {}
	setDefaultTableValue(self.particleSpritesheet, self.defaultSprite)
end

function areaRenderer:resetInterfaceSpritesheet()
	self.interfaceSpritesheet = {}
	setDefaultTableValue(self.interfaceSpritesheet, self.defaultSprite)
end

function areaRenderer:resetTileSpritesheetQuads()
	self.tileSpritesheetQuads = {}
	setDefaultTableValue(self.tileSpritesheetQuads, self.defaultQuad)
end

function areaRenderer:resetEntitySpritesheetQuads()
	self.entitySpritesheetQuads = {}
	setDefaultTableValue(self.entitySpritesheetQuads, self.defaultQuad)
end

function areaRenderer:resetParticleSpritesheetQuads()
	self.particleSpritesheetQuads = {}
	setDefaultTableValue(self.particleSpritesheetQuads, self.defaultQuad)
end

function areaRenderer:resetProjectileSpritesheetQuads()
	self.projectileSpritesheetQuads = {}
	setDefaultTableValue(self.projectileSpritesheetQuads, self.defaultQuad)
end

function areaRenderer:resetInterfaceSpritesheetQuads()
	self.interfaceSpritesheetQuads = {}
	setDefaultTableValue(self.interfaceSpritesheetQuads, self.defaultQuad)
end

function areaRenderer:resetLayers()
	for i=1, #self.layers do
		self.layers[i] = false
	end
end

function areaRenderer:setTileLayer1(tileLayer)
	self.tileLayer1 = tileLayer
end

function areaRenderer:setTileLayer2(tileLayer)
	self.tileLayer2 = tileLayer
end

function areaRenderer:setTileSpritesheet(image)
	self.tileSpritesheet = image
end

function areaRenderer:setTileSpritesheetQuads(quads)
	self.tileSpritesheetQuads = quads
end

function areaRenderer:setSpritesheet(id, image)
	self.spritesheet[id] = image
end

function areaRenderer:setSpritesheetQuads(id, quads)
	self.spritesheetQuads[id] = quads
end

function areaRenderer:setSpriteList1(spriteList)
	self.layers[3] = spriteList
end

function areaRenderer:setProjectileSpritesheet(image)
	self.projectileSpritesheet = image
end

function areaRenderer:setProjectileSpritesheetQuads(quads)
	self.projectileSpritesheetQuads = quads
end

function areaRenderer:setProjectileList(list)
	self.layers[10] = list
end

function areaRenderer:setBackground(image)
	self.layers[1] = image
end

function areaRenderer:setOverlay(image)
	self.layers[8] = image
end

function areaRenderer:createSpriteBatch1(layer1Length, indexX, indexY, nTilesX, nTilesY, tileW, tileH)
	if layer1Length > 0 then
		self.layers[2] = love.graphics.newSpriteBatch(self.tileSpritesheet, nTilesX * nTilesY, 'dynamic')
		self:updateSpriteBatch1(indexX, indexY, (indexX + nTilesX)-1, (indexY + nTilesY)-1, tileW, tileH)
	end
end

function areaRenderer:createSpriteBatch2(layer2Length, indexX, indexY, nTilesX, nTilesY, tileW, tileH)
	if layer2Length > 0 then
		self.layers[5] = love.graphics.newSpriteBatch(self.tileSpritesheet, nTilesX * nTilesY, 'dynamic')
		self:updateSpriteBatch2(indexX, indexY, (indexX + nTilesX)-1, (indexY + nTilesY)-1, tileW, tileH)
	end
end

function areaRenderer:getEntitySpritesheet(id)
	if self.entitySpritesheet[id] == nil then
		return false
	end
	return self.entitySpritesheet[id]
end

function areaRenderer:getEntitySpritesheetQuads(id)
	if self.entitySpritesheetQuads[id] == nil then
		return false
	end
	return self.entitySpritesheetQuads[id]
end

function areaRenderer:getProjectileSpritesheet(id)
	if self.projectileSpritesheet[id] == nil then
		return false
	end
	return self.projectileSpritesheet[id]
end

function areaRenderer:getProjectileSpritesheetQuads(id)
	if self.projectileSpritesheetQuads[id] == nil then
		return false
	end
	return self.projectileSpritesheetQuads[id]
end

---------------
--draw methods:
---------------

function areaRenderer:drawEntitySprite(entitySpriteBox, camera)
	
	love.graphics.draw(self.entitySpritesheet[entitySpriteBox.spritesheetId], 
		self.entitySpritesheetQuads[entitySpriteBox.spritesheetId][entitySpriteBox.quad], 
		entitySpriteBox.x - camera.x, entitySpriteBox.y - camera.y)
	
	--draw hitbox (debug):
	love.graphics.rectangle('line', entitySpriteBox.x - camera.x, entitySpriteBox.y - camera.y,
		entitySpriteBox.w, entitySpriteBox.h)
end

function areaRenderer:drawProjectileSprite(projectileComponents, camera)
	--where are the offsets you idiot?
	love.graphics.draw(self.projectileSpritesheet[projectileComponents.sprite.spritesheetId], 
		self.projectileSpritesheetQuads[projectileComponents.sprite.spritesheetId][projectileComponents.sprite.spritesheetQuad], 
		projectileComponents.spatial.x - camera.x, projectileComponents.spatial.y - camera.y)
end

function areaRenderer:updateSpriteBatch1(indexX, indexY, nTilesX, nTilesY, tileW, tileH)
	self.layers[2]:clear()
	
	for i=indexY, nTilesY do
		for j=indexX, nTilesX do
			if self.tileLayer1[i][j] then
				self.layers[2]:add(self.tileSpritesheetQuads[self.tileLayer1[i][j].quad], (j-1)*tileW, (i-1)*tileH)
			end
		end
	end
end

function areaRenderer:updateSpriteBatch2(indexX, indexY, nTilesX, nTilesY, tileW, tileH)
	self.layers[5]:clear()
	
	for i=indexY, nTilesY do
		for j=indexX, nTilesX do
			if self.tileLayer2[i][j] then
				self.layers[5]:add(self.tileSpritesheetQuads[self.tileLayer2[i][j].quad], (j-1)*tileW, (i-1)*tileH)
			end
		end
	end
end

function areaRenderer:drawScene(camera, tileW, tileH)
	--rewrite this whole function!
	
	local update, indexX, indexY = camera:tilemapIndexModification(tileW, tileH)	--Awful
	
	if self.layers[1] then
		--draw background
	end
	if self.layers[2] then
		if update then self:updateSpriteBatch1(indexX, indexY, indexX + math.floor(camera.w/tileW)+1, indexY + math.floor(camera.h/tileH)+1, tileW, tileH) end
		love.graphics.draw(self.layers[2], camera.x*-1, camera.y*-1)	--needs zoom
	end
	if self.layers[3] then
		--[[
		for i=1, #self.layers[3] do
			self:drawEntitySprite(self.layers[3][i], camera)
		end
		]]
	end
	if self.layers[4] then
		--draw particle sprites
	end
	if self.layers[5] then
		if update then self:updateSpriteBatch2(indexX, indexY, indexX + math.floor(camera.w/tileW)+1, indexY + math.floor(camera.h/tileH)+1, tileW, tileH) end
		love.graphics.draw(self.layers[5], camera.x*-1, camera.y*-1)
	end
	if self.layers[6] then
		--draw entity sprites, 2nd layer
	end
	if self.layers[7] then
		--draw particle sprites, 2nd layer
	end
	if self.layers[8] then
		--draw overlay (never used, remove it)
	end
	if self.layers[9] then
		--draw interface
	end
	if self.layers[10] then
		--[[
		for i=1, #self.layers[10] do
			if self.layers[10][i].active then
				self:drawProjectileSprite(self.layers[10][i].componentTable, camera)
			end
		end
		]]
	end
end