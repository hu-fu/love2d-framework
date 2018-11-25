PROJECTILE_DESTRUCTOR_TYPES = require '/projectile/PROJECTILE_DESTRUCTOR_TYPE'
PROJECTILE_DESTRUCTION_TYPES = require '/projectile/PROJECTILE_DESTRUCTION_TYPE'

local PROJECTILE_DESTRUCTOR = {
	[PROJECTILE_DESTRUCTOR_TYPES.GENERIC] = {
		[PROJECTILE_DESTRUCTION_TYPES.GENERIC] = function(projectileSystem, projectileObject, entityObject)
			
		end,
		
		[PROJECTILE_DESTRUCTION_TYPES.WALL_COLLISION] = function(projectileSystem, projectileObject, entityObject)
			
		end,
		
		[PROJECTILE_DESTRUCTION_TYPES.ENTITY_COLLISION] = function(projectileSystem, projectileObject, entityObject)
			
		end,
	},
	
	--...
}

return PROJECTILE_DESTRUCTOR