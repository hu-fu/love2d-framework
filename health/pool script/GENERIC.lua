return {
	--template for pool scripts
	
	onHit = function(healthSystem, self, component)
		
	end,
	
	onRegen = function(healthSystem, self, component)
		
	end,
	
	onLoss = {
		{
			activationPercentage = 10,
			method = function(healthSystem, self, component, dt)
				
			end
		},
		{
			activationPercentage = 0,
			method = function(healthSystem, self, component, dt)
				--healthSystem:sendDespawnRequest(component, 1, nil, nil)
			end
		},
	},
	
	onGain = {
		{
			activationPercentage = 50,
			method = function(healthSystem, self, component, dt)
				
			end
		},
	}
}