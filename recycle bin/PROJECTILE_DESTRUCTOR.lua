local PROJECTILE_DESTRUCTOR = {}

PROJECTILE_DESTRUCTOR.ENTITY_ROLES = require 'ENTITY_ROLE'
PROJECTILE_DESTRUCTOR.PROJECTILE_CONTROLLER = require 'PROJECTILE_CONTROLLER'

PROJECTILE_DESTRUCTOR.TYPES = {
	GENERIC = 1
}

PROJECTILE_DESTRUCTOR.TEMPLATES = {
	--needs a default value
	
	[PROJECTILE_DESTRUCTOR.PROJECTILE_CONTROLLER.TYPES.GENERIC] = {
		[PROJECTILE_DESTRUCTOR.TYPES.GENERIC] = {
			[1] = function(projectileComponents)
				local x, y = PROJECTILE_DESTRUCTOR.PROJECTILE_CONTROLLER.projectileControlMethods:projectileTest(projectileComponents.spatial.direction, 
					projectileComponents.spatial.velocity, projectileComponents.spatial.x, projectileComponents.spatial.y)
				projectileComponents.spatial.x, projectileComponents.spatial.y = projectileComponents.spatial.x - x, projectileComponents.spatial.y - y
			end
		}
	}
}

return PROJECTILE_DESTRUCTOR