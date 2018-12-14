require 'misc'
require '/render/EntityRenderer'

local SpatialEntityRenderer = EntityRenderer.new()

SpatialEntityRenderer.ENTITY_TYPES = require '/entity/ENTITY_TYPE'

SpatialEntityRenderer.spritesheetTable = {}
SpatialEntityRenderer.quadTable = {}

function SpatialEntityRenderer:setSpriteTables(spritesheetTable, quadTable)
	self.spritesheetTable = spritesheetTable
	self.quadTable = quadTable
end

function SpatialEntityRenderer:drawEntity(canvas, spatialEntity)
	self.drawEntityMethods[spatialEntity.entityType](canvas, spatialEntity.parentEntity)
end

SpatialEntityRenderer.drawEntityMethods = {
	[SpatialEntityRenderer.ENTITY_TYPES.GENERIC_ENTITY] = function(canvas, parentEntity)
		local spritebox = parentEntity.componentTable.spritebox
		
		love.graphics.draw(SpatialEntityRenderer.spritesheetTable[spritebox.spritesheetId], 
			SpatialEntityRenderer.quadTable[spritebox.spritesheetId][spritebox.quad], 
			math.floor(spritebox.x - canvas.x), math.floor(spritebox.y - canvas.y))
		
		--draw hitbox (debug):
		local hitbox = parentEntity.componentTable.hitbox
		if hitbox then
			love.graphics.rectangle('line', math.floor(hitbox.x - canvas.x), 
				math.floor(hitbox.y - canvas.y), hitbox.w, hitbox.h)
		end
	end,
	
	[SpatialEntityRenderer.ENTITY_TYPES.GENERIC_WALL] = function(canvas, parentEntity)
		local spritebox = parentEntity.componentTable.spritebox
		
		love.graphics.draw(SpatialEntityRenderer.spritesheetTable[spritebox.spritesheetId], 
			SpatialEntityRenderer.quadTable[spritebox.spritesheetId][spritebox.quad], 
			math.floor(spritebox.x - canvas.x), math.floor(spritebox.y - canvas.y))
		
		--draw hitbox (debug):
		local hitbox = parentEntity.componentTable.hitbox
		if hitbox then
			love.graphics.rectangle('line', math.floor(hitbox.x - canvas.x), 
				math.floor(hitbox.y - canvas.y), hitbox.w, hitbox.h)
		end
	end,
	
	[SpatialEntityRenderer.ENTITY_TYPES.GENERIC_PROJECTILE] = function(canvas, parentEntity)
		
	end,
	
	[SpatialEntityRenderer.ENTITY_TYPES.VISUAL_EFFECT] = function(canvas, parentEntity)
		
	end,
	
	[SpatialEntityRenderer.ENTITY_TYPES.UNDEFINED] = function(canvas, parentEntity)
		--do nothing
	end,
}

function SpatialEntityRenderer:setDefaultDrawMethod()
	local methodTable = self.drawEntityMethods
	local mt = {__index = function (methodTable) return methodTable.___ end}
	methodTable.___ = methodTable[self.ENTITY_TYPES.UNDEFINED]
	setmetatable(methodTable, mt)
end

--debug stuff:

SpatialEntityRenderer.projectileList = nil
SpatialEntityRenderer.effectList = nil

function SpatialEntityRenderer:debug_drawProjectiles(canvas)
	for i=1, #self.projectileList do
		if self.projectileList[i].active then
			love.graphics.draw(
			self.projectileSpritesheet[self.projectileList[i].components.sprite.spritesheetId], 
			self.projectileSpritesheetQuads[self.projectileList[i].components.sprite.spritesheetId][self.projectileList[i].components.sprite.spritesheetQuad], 
			self.projectileList[i].components.spatial.x - canvas.x, 
			self.projectileList[i].components.spatial.y - canvas.y)
		end
	end
end

function SpatialEntityRenderer:debug_drawEffects(canvas)
	for i=1, #self.effectList do
		if self.effectList[i].active then
			love.graphics.draw(
			self.effectSpritesheet[self.effectList[i].components.sprite.spritesheetId], 
			self.effectSpritesheetQuads[self.effectList[i].components.sprite.spritesheetId][self.effectList[i].components.sprite.spritesheetQuad], 
			self.effectList[i].components.spatial.x - canvas.x, 
			self.effectList[i].components.spatial.y - canvas.y)
		end
	end
end

SpatialEntityRenderer:setDefaultDrawMethod()
return SpatialEntityRenderer