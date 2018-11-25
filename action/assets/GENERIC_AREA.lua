local ACTIONS = require '/action/ACTION'
local SET_ID = ACTIONS.SET_ID.GENERIC_AREA
local CALL_TYPE = require '/action/ACTION_CALL_TYPE'

return {
	[ACTIONS.ACTION_ID[SET_ID].GENERIC] = {
		id = 1,
		animationSetId = 0,
		animationId = 0,
		totalTime = 2.0,
		replay = false,
		
		variables = {
			
		},
		
		methods = {
			{
				callType = CALL_TYPE.THREAD_START,
				callTime = 0.0,
				frameFrequency = 1,
				method = function(self, system, component)
					INFO_STR = component.currentTime .. ', ' .. #component.childEntities
				end
			},
			{
				callType = CALL_TYPE.ONCE,
				callTime = 2.0,
				frameFrequency = 1,
				method = function(self, system, component)
					component.active = false
				end
			}
		}
	},
	
	[ACTIONS.ACTION_ID[SET_ID].CHANGE_AREA] = {
		id = 1,
		animationSetId = 0,
		animationId = 0,
		totalTime = 0.0,
		replay = false,
		
		variables = {
			SCENE = require '/scene/SCENE'
		},
		
		methods = {
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.0,
				frameFrequency = 0,
				method = function(self, system, component)
					--scene change proof of concept:
					--you can set spawn data and other stuff to the triggering entity here
						--change the spawn point to next spawn point for example
					system:changeState(self.variables.SCENE.GENERIC.id, false)
				end
			}
		}
	},
	
	[ACTIONS.ACTION_ID[SET_ID].ELEVATOR] = {
		id = 1,
		animationSetId = 0,
		animationId = 0,
		totalTime = 0.0,
		replay = false,
		
		variables = {
			
		},
		
		methods = {
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.0,
				frameFrequency = 0,
				method = function(self, system, component)
					
				end
			}
		}
	},
	
	[ACTIONS.ACTION_ID[SET_ID].CHEST] = {
		id = 1,
		animationSetId = 0,
		animationId = 0,
		totalTime = 0.0,
		replay = false,
		
		variables = {
			
		},
		
		methods = {
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.0,
				frameFrequency = 0,
				method = function(self, system, component)
					
				end
			}
		}
	},
	
	[ACTIONS.ACTION_ID[SET_ID].DOOR] = {
		id = 1,
		animationSetId = 0,
		animationId = 0,
		totalTime = 0.0,
		replay = false,
		
		variables = {
			
		},
		
		methods = {
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.0,
				frameFrequency = 0,
				method = function(self, system, component)
					
				end
			}
		}
	}
}