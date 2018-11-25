local METHOD_ID = require '/effect/CONTROL_METHOD'
local CONTROLLER_TYPE = require '/effect/VISUAL_EFFECT_CONTROLLER_TYPE'

local VISUAL_EFFECT_CONTROLLER = {
	[CONTROLLER_TYPE.GENERIC] = {
		totalTime = 0.1,
		loop = false,
		animation = true,
		animationTotalTime = 0.1,
		animationLoop = true,
		
		methods = {
			{
				methodId = METHOD_ID.GENERIC,
				stopTime = 0.1,
				arguments = {vel = 10.0}
			},
			
			--add more here (called at previous method stop time)
		},
		
		animationUpdate = {
			{
				updateTime = 0.03,
				quad = 2,
				soundId = nil
			},
			{
				updateTime = 0.06,
				quad = 3,
				soundId = nil
			}
		}
	},
	
	--... add as many as you want!
}

return VISUAL_EFFECT_CONTROLLER