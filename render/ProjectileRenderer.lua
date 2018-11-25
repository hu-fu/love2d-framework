require 'misc'
require '/render/EntityRenderer'

local ProjectileRenderer = EntityRenderer.new()

ProjectileRenderer.spritesheetTable = {}
ProjectileRenderer.quadTable = {}

function ProjectileRenderer:setSpriteTables(spritesheetTable, quadTable)
	self.spritesheetTable = spritesheetTable
	self.quadTable = quadTable
end

function ProjectileRenderer:drawEntity(canvas, projectile)
	-- O F F S E T S P L E A S E --
	love.graphics.draw(self.spritesheetTable[projectile.sprite.spritesheetId], 
		self.quadTable[projectile.sprite.spritesheetId][projectile.sprite.spritesheetQuad], 
		math.floor((projectile.spatial.x + projectile.sprite.spriteOffsetX) - canvas.x), 
		math.floor((projectile.spatial.y + projectile.sprite.spriteOffsetY) - canvas.y))
end

return ProjectileRenderer