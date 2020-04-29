--this must be stateless
--moving platform test

return {
	['id'] = 1,
	
	['variables'] = {
		totalTime = 5,
		replay = true,
		--...
	},
	
	['init'] = function(scriptSystem, self, component)
		
	end,
	
	['threads'] = {
		{
			priority = 1,
			method = function(scriptSystem, self, component, dt)
				--component.componentTable.spritebox.y = component.componentTable.spritebox.y - 1
			end
		},
		
		{
			priority = 2,
			method = function(scriptSystem, self, component, dt)
				
			end
		}
	}
}