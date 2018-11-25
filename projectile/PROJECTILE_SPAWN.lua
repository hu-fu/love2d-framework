--Spawns are instant. No delayed spawns. This is intentional and VERY important.

local PROJECTILE_SPAWN_TYPES = require '/projectile/PROJECTILE_SPAWN_TYPE'
local PROJECTILE_TEMPLATE_TYPES = require '/projectile/PROJECTILE_TEMPLATE_TYPE'
local ENTITY_ROLE_GROUP = require '/entity/ENTITY_ROLE_GROUP'
local projectileTargetingMethods = require '/projectile/projectileTargetingMethods'

local PROJECTILE_SPAWN = {
	[PROJECTILE_SPAWN_TYPES.GENERIC] = {
		{
			projectileTemplate = PROJECTILE_TEMPLATE_TYPES.GENERIC,
			roleGroup = ENTITY_ROLE_GROUP.SAME_PROJECTILE,
			xOffset = 0,
			yOffset = 0,
			velocityModifier = 0,
			
			getDirection = function(defaultDirection, x, y, targetEntity)
				if targetEntity then
					return projectileTargetingMethods:getDirectionToTarget(x, y, targetEntity)
				end
				return defaultDirection
			end
		},
		
		--add more to the spawn here
	},
	
	--add other types of spawn here
}

return PROJECTILE_SPAWN