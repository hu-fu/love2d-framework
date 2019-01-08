PROJECTILE_DESTRUCTOR_TYPES = require '/projectile/PROJECTILE_DESTRUCTOR_TYPE'
PROJECTILE_DESTRUCTION_TYPES = require '/projectile/PROJECTILE_DESTRUCTION_TYPE'

local PROJECTILE_DESTRUCTOR = {
	[PROJECTILE_DESTRUCTOR_TYPES.GENERIC] = {
		[PROJECTILE_DESTRUCTION_TYPES.GENERIC] = function(projectileSystem, projectileObject, entityObject)
			
		end,
		
		[PROJECTILE_DESTRUCTION_TYPES.WALL_COLLISION] = function(projectileSystem, projectileObject, entityObject)
			
		end,
		
		[PROJECTILE_DESTRUCTION_TYPES.ENTITY_COLLISION] = function(projectileSystem, projectileObject, entityObject)
			--test: send health request
			projectileSystem:sendHealthRequest(entityObject.componentTable.health, 2, -10, nil, nil)
		end,
	},
	
	--...
}

return PROJECTILE_DESTRUCTOR