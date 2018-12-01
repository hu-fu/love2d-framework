local ACTIONS = require '/action/ACTION'
local SET_ID = ACTIONS.SET_ID.GENERIC_EMITTER
local CALL_TYPE = require '/action/ACTION_CALL_TYPE'

return {
	[ACTIONS.ACTION_ID[SET_ID].GENERIC] = {
		id = 1,
		animationSetId = 0,
		animationId = 0,
		totalTime = 0.2,
		replay = true,
		
		variables = {
			
		},
		
		methods = {
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.0,
				timeFrequency = 1,
				method = function(self, system, component)
					--bad business, should send the thing to the request stack first
					--note that you can set up the emission position here relative to the w,h of the emitter
					local x = component.x + (component.w/2)
					local y = component.y + (component.h/2)
					system:spawnVisualEffect(1, x, y, math.random(0,360), component)
				end
			},
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.1,
				timeFrequency = 1,
				method = function(self, system, component)
					local x = component.x + (component.w/2)
					local y = component.y + (component.h/2)
					system:spawnVisualEffect(1, x, y, math.random(0,360), component)
				end
			}
		}
	},
	
	[ACTIONS.ACTION_ID[SET_ID].GLOBAL] = {
		id = 2,
		animationSetId = 0,
		animationId = 0,
		totalTime = 10000.0,
		replay = true,
		
		variables = {
			
		},
		
		methods = {
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.0,
				timeFrequency = 1,
				method = function(self, system, component)
					--apparently an action with no methods crashes the game. nice
				end
			}
		}
	}
}