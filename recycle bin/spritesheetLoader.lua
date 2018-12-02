--[[
Contains a list(?) of all texture maps assigned by an unique id
-> Entity textures + quads
-> Map textures + quads
-> Particle textures + quads

A request (from anywhere) is made to the renderer to fetch a specific spritesheet
Check if it's already loaded on the renderer, if it isn't get it through the loader

Each sheet/quad has a unique ID, global to the whole program

IMPORTANT(28/09/2016):
	The tile spritesheet/quads are loaded according to the area id
	The area map should have a 'area.spritesheet = spritesheetId' variable
]]

local spritesheetLoader = {}

local BACKGROUND_FOLDER = '/graphics/background/'
local OVERLAY_FOLDER = '/graphics/overlay/'
local TILE_SPRITESHEET_FOLDER = '/graphics/tile/'
local ENTITY_SPRITESHEET_FOLDER = '/graphics/entity/'
local PARTICLE_SPRITESHEET_FOLDER = '/graphics/particles/'
local PROJECTILE_SPRITESHEET_FOLDER = '/graphics/projectile/'
local EFFECT_SPRITESHEET_FOLDER = '/graphics/effect/'

---------
--Images:
---------

local background_image = {

}

local overlay_image = {

}

---------
--Sheets:
---------

local tile_spritesheet = {
	[1] = 'tilesheet_1.png',
	[2] = 'tilesheet_1.png'
}

local entity_spritesheet = {
	[1] = 'player.png'
}

local particle_spritesheet = {
	[1] = 'particlesheet_1.png'
}

local projectile_spritesheet = {
	[1] = 'default.png'
}

local effect_spritesheet = {
	[1] = 'default.png'
}

--------
--Quads:
--------

local tile_spritesheet_quads = {
	[1] = {64,64,2,1},	--{tileW, tileH, nTileRows, nTileColumns}
	[2] = {64,64,2,1}
}

local entity_spritesheet_quads = {	--same id as the corresponding spritesheet
	[1] = 'player'
}

local particle_spritesheet_quads = {

}

local projectile_spritesheet_quads = {
	[1] = 'default'
}

local effect_spritesheet_quads = {
	[1] = 'default'
}

----------
--Methods:
----------

function spritesheetLoader:loadTileSpritesheet(id)
	local filepath = TILE_SPRITESHEET_FOLDER .. tile_spritesheet[id]
	return love.graphics.newImage(filepath)
end

function spritesheetLoader:loadTileSpritesheetQuads(id)
	local quadInfo = tile_spritesheet_quads[id]
	local quads = {}
	local x, y = 0, 0
	local tileW, tileH = quadInfo[1], quadInfo[2]
	local maxW, maxH = quadInfo[3]*quadInfo[1], quadInfo[4]*quadInfo[2]
	
	for j = 1, quadInfo[4] do
		for i = 1, quadInfo[3] do
			table.insert(quads, love.graphics.newQuad(x, y, tileW, tileH, maxW, maxH))
			x = x + tileW
		end
		x, y = 0, y + tileH
	end
	
	return quads
end

function spritesheetLoader:loadEntitySpritesheet(id)
	local filepath = ENTITY_SPRITESHEET_FOLDER .. entity_spritesheet[id]
	return love.graphics.newImage(filepath)
end

function spritesheetLoader:loadEntitySpritesheetQuads(id)
	local filepath = ENTITY_SPRITESHEET_FOLDER .. entity_spritesheet_quads[id]
	local quads = require (filepath)
	local entitySpritesheetQuads = {}
	
	for i=1, #quads do
		table.insert(entitySpritesheetQuads, love.graphics.newQuad(quads[i][1], quads[i][2], quads[i][3], quads[i][4], quads[i][5], quads[i][6]))
	end
	
	return entitySpritesheetQuads
end

function spritesheetLoader:loadParticleSpritesheet(id)

end

function spritesheetLoader:loadProjectileSpritesheet(id)
	local filepath = PROJECTILE_SPRITESHEET_FOLDER .. projectile_spritesheet[id]
	return love.graphics.newImage(filepath)
end

function spritesheetLoader:loadProjectileSpritesheetQuads(id)
	local filepath = PROJECTILE_SPRITESHEET_FOLDER .. projectile_spritesheet_quads[id]
	local quads = require (filepath)
	local projectileSpritesheetQuads = {}
	
	for i=1, #quads do
		table.insert(projectileSpritesheetQuads, love.graphics.newQuad(quads[i][1], quads[i][2], quads[i][3], quads[i][4], quads[i][5], quads[i][6]))
	end
	
	return projectileSpritesheetQuads
end

function spritesheetLoader:loadEffectSpritesheet(id)
	local filepath = EFFECT_SPRITESHEET_FOLDER .. effect_spritesheet[id]
	return love.graphics.newImage(filepath)
end

function spritesheetLoader:loadEffectSpritesheetQuads(id)
	local filepath = EFFECT_SPRITESHEET_FOLDER .. effect_spritesheet_quads[id]
	local quads = require (filepath)
	local effectSpritesheetQuads = {}
	
	for i=1, #quads do
		table.insert(effectSpritesheetQuads, love.graphics.newQuad(quads[i][1], quads[i][2], quads[i][3], quads[i][4], quads[i][5], quads[i][6]))
	end
	
	return effectSpritesheetQuads
end

function spritesheetLoader:loadBackground(id)
	local filepath = BACKGROUND_FOLDER .. background_image[id]
	return love.graphics.newImage(filepath)
end

function spritesheetLoader:loadOverlay(id)
	local filepath = OVERLAY_FOLDER .. overlay_image[id]
	return love.graphics.newImage(filepath)
end

----------------
--Return module:
----------------

return spritesheetLoader