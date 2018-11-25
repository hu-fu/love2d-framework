return {
	['id'] = 1,
	
	['variables'] = {
		currentTime = nil,
		totalTime = nil,
		variable = nil
	},
	
	['init'] = function(scriptSystem, self)
		
	end,
	
	['threads'] = {
		{
			priority = 1,
			method = function(scriptSystem, self, dt)
				
			end
		},
		
		{
			priority = 2,
			method = function(scriptSystem, self, dt)
				
			end
		},
		
		--...
	}
}