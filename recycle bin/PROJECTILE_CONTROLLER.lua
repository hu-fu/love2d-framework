local PROJECTILE_CONTROLLER = {}

local projectileTargetingMethods = require 'projectileTargetingMethods'
local projectileStateManager = require 'projectileState'
PROJECTILE_CONTROLLER.projectileControlMethods = require 'projectileControlMethods'
PROJECTILE_CONTROLLER.PROJECTILE_STATES = projectileStateManager.states

PROJECTILE_CONTROLLER.TYPES = {
	GENERIC = 1
}

PROJECTILE_CONTROLLER.TEMPLATES = {
	
	[PROJECTILE_CONTROLLER.TYPES.GENERIC] = {
		[PROJECTILE_CONTROLLER.PROJECTILE_STATES.SPAWN] = {
			[40] = function(projectileComponents)
				local x, y = PROJECTILE_CONTROLLER.projectileControlMethods:projectileTest(projectileComponents.spatial.direction, 
					projectileComponents.spatial.velocity, projectileComponents.spatial.x, projectileComponents.spatial.y)
				projectileComponents.spatial.x, projectileComponents.spatial.y = projectileComponents.spatial.x + x, projectileComponents.spatial.y + y
			end
		},
		
		[PROJECTILE_CONTROLLER.PROJECTILE_STATES.ACTIVE] = {
			[2] = function(projectileComponents)
				local x, y = PROJECTILE_CONTROLLER.projectileControlMethods:projectileTest(projectileComponents.spatial.direction, 
					projectileComponents.spatial.velocity, projectileComponents.spatial.x, projectileComponents.spatial.y)
				projectileComponents.spatial.x, projectileComponents.spatial.y = projectileComponents.spatial.x + x, projectileComponents.spatial.y + y
			end,
			[4] = function(projectileComponents)
				local x, y = PROJECTILE_CONTROLLER.projectileControlMethods:projectileTest(projectileComponents.spatial.direction, 
					projectileComponents.spatial.velocity, projectileComponents.spatial.x, projectileComponents.spatial.y)
				projectileComponents.spatial.x, projectileComponents.spatial.y = projectileComponents.spatial.x + x, projectileComponents.spatial.y + y
			end
		}
	}
	
	--...
}

return PROJECTILE_CONTROLLER