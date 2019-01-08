return {
	--activates when the player character is hit
	
	id = 2,
	totalTime = 2.0,
	
	onStart = function(healthSystem, self, component)
		component.immunityActive = true
		component.immunityTime = 0
		--apply some blinking effect
	end,
	
	onEnd = function(healthSystem, self, component)
		
	end,
	
	onRun = function(healthSystem, self, component, dt)
		component.immunityTime = component.immunityTime + dt
		
		if component.immunityTime >= self.totalTime then
			component.immunityActive = false
			component.immunityTime = 0
			healthSystem:deactivateEffectScript(component, self.id)
		end
	end
}