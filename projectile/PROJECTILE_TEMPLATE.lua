local PROJECTILE_TYPES = require '/projectile/PROJECTILE_TYPE'
local PROJECTILE_CONTROLLER_TYPES = require '/projectile/PROJECTILE_CONTROLLER_TYPE'
local PROJECTILE_DESTRUCTOR_TYPES = require '/projectile/PROJECTILE_DESTRUCTOR_TYPE'
local PROJECTILE_TEMPLATE_TYPES = require '/projectile/PROJECTILE_TEMPLATE_TYPE'

local PROJECTILE_TEMPLATE = {
	[PROJECTILE_TEMPLATE_TYPES.GENERIC] = {
		projectileType = PROJECTILE_TYPES.GENERIC,
		w = 0,
		h = 0,
		velocity = 700,
		spritesheetId = 5,
		spritesheetQuad = 1,
		spriteOffsetX = -12,
		spriteOffsetY = -12,
		controller = PROJECTILE_CONTROLLER_TYPES.GENERIC,
		destructor = PROJECTILE_DESTRUCTOR_TYPES.GENERIC,
	}
	
	--...
}

return PROJECTILE_TEMPLATE