local BEHAVIOUR = require '/camera/CAMERA_BEHAVIOUR'

local SCRIPT = {
	[BEHAVIOUR.GENERIC] = {
		variables = {
			var_1 = 'camera var'
		},
		
		init = function(cameraSystem, self, initRequest)
			--reset/set self.variables
		end,
		
		update = function(cameraSystem, self, dt)
			
		end
	},
	
	[BEHAVIOUR.TEST_FOLLOW] = {
		variables = {
			entity = false
		},
		
		init = function(self, cameraSystem, initRequest)
			self.variables.entity = cameraSystem:getFocusEntityById(1, 1)
			
			if self.variables.entity then
				cameraSystem.lens.x = self.variables.entity.components.hitbox.x
					- (cameraSystem.lens.w/2) + (self.variables.entity.components.hitbox.w/2)
				cameraSystem.lens.y = self.variables.entity.components.hitbox.y
					- (cameraSystem.lens.h/2) + (self.variables.entity.components.hitbox.h/2)
			end
		end,
		
		update = function(self, cameraSystem, dt)
			if self.variables.entity then
				cameraSystem.lens.x = (self.variables.entity.components.hitbox.x)
					- (cameraSystem.lens.w/2) + ((self.variables.entity.components.hitbox.w/2))
				cameraSystem.lens.y = (self.variables.entity.components.hitbox.y)
					- (cameraSystem.lens.h/2) + ((self.variables.entity.components.hitbox.h/2))
			end
		end
	},
	
}

return SCRIPT