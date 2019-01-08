return {
	--template for pool scripts
	--health script for player character (note the immunity checks, npcs don't need this)
	
	getValue = function(healthSystem, self, component, value)
		if component.immunityActive and value < 0 then
			return 0
		else
			--calculate the loss/gain value
			return value
		end
	end,
	
	modifyHealthPoints = function(healthSystem, self, component, value)
		component.healthPoints = component.healthPoints + value
	end,
	
	onHit = function(healthSystem, self, component)
		--start immunity script (if component.immunity == true)
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
				--this request should go to the entity controller! This is just for testing!!!
				healthSystem:sendDespawnRequest(component, 1)
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