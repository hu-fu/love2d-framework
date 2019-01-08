--this must be stateless

return {
	['id'] = 1,
	
	['variables'] = {
		totalTime = 5,
		replay = true,
		--...
	},
	
	['init'] = function(scriptSystem, self, component)
		component.componentTable.movement.rotation = math.random(math.rad(1), math.rad(360))
		component.componentTable.movement.velocity = 50
		scriptSystem:requestMovementAction(component.componentTable.movement, 
			scriptSystem.MOVEMENT_REQUEST.START_MOVEMENT)
	end,
	
	['threads'] = {
		{
			priority = 1,
			method = function(scriptSystem, self, component, dt)
				
			end
		},
		
		{
			priority = 2,
			method = function(scriptSystem, self, component, dt)
				
			end
		}
	}
}