local ACTIONS = require '/action/ACTION'
local SET_ID = ACTIONS.SET_ID.PLAYER_MAIN
local CALL_TYPE = require '/action/ACTION_CALL_TYPE'
local COMBAT_STATE = require '/combat/COMBAT_STATE'
local ATTACK_TYPE = require '/combat/ATTACK_TYPE'

return {
	[ACTIONS.ACTION_ID[SET_ID].GENERIC] = {
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
					component.componentTable.actionState.state = 1
				end
			}
		}
	},
	
	[ACTIONS.ACTION_ID[SET_ID].IDLE] = {
		id = 2,
		animationSetId = 1,
		animationId = 1,
		totalTime = 0.6,
		replay = true,
		
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
	
	[ACTIONS.ACTION_ID[SET_ID].DESPAWN_TEST] = {
		id = 1,
		animationSetId = 0,
		animationId = 0,
		totalTime = 0.3,
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
	
	[ACTIONS.ACTION_ID[SET_ID].INTERACT_TEST] = {
		id = 1,
		animationSetId = 1,
		animationId = 1,
		totalTime = 1.2,
		replay = false,
		
		variables = {
			
		},
		
		methods = {
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.0,
				frameFrequency = 0,
				method = function(self, system, component)
					--start interaction
				end
			},
			
			{
				callType = CALL_TYPE.ONCE,
				callTime = 1.2,
				frameFrequency = 0,
				method = function(self, system, component)
					system:endEventState(component)
				end
			}
		}
	},
	
	[ACTIONS.ACTION_ID[SET_ID].COMBAT_TEST] = {
		id = 5,
		animationSetId = 1,
		animationId = 3,
		totalTime = 0.3,
		replay = false,
		
		variables = {
			combatState = COMBAT_STATE.ATTACK_MELEE,
			cancel = false,
			cancelTime = 0,
			staminaCost = 20,
		},
		
		methods = {
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.0,
				frameFrequency = 0,
				method = function(self, system, component)
					system:sendHealthRequest(component, 2, -90, nil, nil)
				end
			},
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.25,
				frameFrequency = 0,
				method = function(self, system, component)
					component.comboActivation = true
				end
			}
		}
	},
	
	[ACTIONS.ACTION_ID[SET_ID].COMBAT_RANGED] = {
		id = 6,
		animationSetId = 1,
		animationId = 3,
		totalTime = 999.9,
		replay = false,
		
		variables = {
			combatState = COMBAT_STATE.ATTACK_RANGED,
			cancel = true,
			cancelTime = 999.7,
			staminaCost = 20,
		},
		
		methods = {
			{
				id = 1,
				callType = CALL_TYPE.THREAD_START,
				callTime = 0.2,
				frameFrequency = 10,
				method = function(self, system, component)
					
					--shoot bullets pew pew pew
					system:sendProjectileRequest(component, 1, component.componentTable.movement.rotation)
					
					system:sendSoundRequest(component, 1, 2, 1, 2, 'name', 0.4, false, false, component, 
						false, component.componentTable.hitbox.x, component.componentTable.hitbox.y)
					
				end
			},
			{
				id = 2,
				callType = CALL_TYPE.ONCE,
				callTime = 0.4,
				frameFrequency = 0,
				method = function(self, system, component)
					
					system:sendVisualEffectRequest(component, 1, 1, 1, component.componentTable.spritebox, 
						component.componentTable.spritebox.x, component.componentTable.spritebox.y, 
						component.componentTable.movement.rotation)
				end
			},
			{
				id = 1,
				callType = CALL_TYPE.THREAD_STOP,
				callTime = 999.9,
				frameFrequency = 10,
				method = function(self, system, component)
					--ends thread where id == 1
				end
			},
			{
				id = nil,
				callType = CALL_TYPE.ONCE,
				callTime = 999.8,
				frameFrequency = 0,
				method = function(self, system, component)
					component.comboActivation = true
					
					--end visual effect emitter:
					system:sendVisualEffectRequest(component, 2, 1, 1, nil, nil, nil, nil,
						component.componentTable.spritebox.effectEmitter)
				end
			}
		}
	},
	
	[ACTIONS.ACTION_ID[SET_ID].KNOCKBACK_TEST] = {
		id = 7,
		animationSetId = 1,
		animationId = 4,
		totalTime = 0.3,
		replay = false,
		
		variables = {
			combatState = COMBAT_STATE.KNOCKBACK,
			cancel = false,
			cancelTime = 0,
		},
		
		methods = {
			{
				callType = CALL_TYPE.ONCE,
				callTime = 0.0,
				frameFrequency = 0,
				method = function(self, system, component)
					
				end
			},
		}
	},
}