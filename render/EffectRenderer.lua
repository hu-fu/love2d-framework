require 'misc'
require '/render/EntityRenderer'

local EffectRenderer = EntityRenderer.new()

EffectRenderer.spritesheetTable = {}
EffectRenderer.quadTable = {}

function EffectRenderer:setSpriteTables(spritesheetTable, quadTable)
	self.spritesheetTable = spritesheetTable
	self.quadTable = quadTable
end

function EffectRenderer:drawEntity(canvas, effect)
	-- O F F S E T S P L E A S E --
	love.graphics.draw(self.spritesheetTable[effect.sprite.spritesheetId], 
		self.quadTable[effect.sprite.spritesheetId][effect.sprite.spritesheetQuad], 
		math.floor((effect.spatial.x + effect.sprite.spriteOffsetX) - canvas.x), 
		math.floor((effect.spatial.y + effect.sprite.spriteOffsetY) - canvas.y))
end

return EffectRenderer