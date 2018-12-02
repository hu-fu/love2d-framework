local PROJECTILE_SPAWN = {}

--Spawns are instant. No delayed spawns. This is intentional and VERY important.

local projectileType = require 'PROJECTILE_TYPE'
local projectileTargetingMethods = require 'projectileTargetingMethods'
PROJECTILE_SPAWN.PROJECTILE_TEMPLATE_TYPES = projectileType.TEMPLATE_TYPES

PROJECTILE_SPAWN.TYPES = {
	GENERIC = 1
}

PROJECTILE_SPAWN.TEMPLATES = {
	[PROJECTILE_SPAWN.TYPES.GENERIC] = {
		{
			projectileTemplate = PROJECTILE_SPAWN.PROJECTILE_TEMPLATE_TYPES.GENERIC,
			xOffset = 0,
			yOffset = 0,
			velocityModifier = 0,
			getDirection = function(defaultDirection)
				return defaultDirection
			end
		},
		{
			projectileTemplate = PROJECTILE_SPAWN.PROJECTILE_TEMPLATE_TYPES.GENERIC,
			xOffset = 0,
			yOffset = 0,
			velocityModifier = 0,
			getDirection = function(defaultDirection)
				return defaultDirection*-1
			end
		}
	}
}

return PROJECTILE_SPAWN