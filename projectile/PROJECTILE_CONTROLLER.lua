local METHOD_ID = require '/projectile/CONTROL_METHOD'
local CONTROLLER_TYPE = require '/projectile/PROJECTILE_CONTROLLER_TYPE'

local PROJECTILE_CONTROLLER = {
	[CONTROLLER_TYPE.GENERIC] = {
		totalTime = 2.0,
		animation = true,
		animationTotalTime = 0.1,
		animationLoop = true,
		
		methods = {
			{
				methodId = METHOD_ID.GENERIC,
				stopTime = 2.0,
				arguments = {vel = 5.0}
			},
			
			--add more here (called at previous method stop time)
		},
		
		animationUpdate = {
			{
				updateTime = 0.05,
				quad = 2,
			},
		}
	},
	
	--... add as many as you want!
}

return PROJECTILE_CONTROLLER