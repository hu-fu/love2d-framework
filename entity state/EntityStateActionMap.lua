--[[
STATE[state_id][action_id] = allowed/not allowed (bool)
required by the entity state systems
used in STATE vs. ACTION tests
]]

local EntityStateActionMap = {}

EntityStateActionMap.ENTITY_STATE = require '/entity state/ENTITY_STATE'
EntityStateActionMap.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'

EntityStateActionMap.actionMap = {
	
	[EntityStateActionMap.ENTITY_STATE.FREE] = {
		[EntityStateActionMap.ENTITY_ACTION.IDLE] = true,
		[EntityStateActionMap.ENTITY_ACTION.MOVE] = true,
		[EntityStateActionMap.ENTITY_ACTION.MOVE_START] = true,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SET_STATE] = true,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SEARCH] = true,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SET_TARGET] = true,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_RESET_STATE] = true,
		[EntityStateActionMap.ENTITY_ACTION.START_SPAWN] = true,
		[EntityStateActionMap.ENTITY_ACTION.END_SPAWN] = true,
		[EntityStateActionMap.ENTITY_ACTION.START_DESPAWN] = true,
		[EntityStateActionMap.ENTITY_ACTION.END_DESPAWN] = true,
		[EntityStateActionMap.ENTITY_ACTION.INTERACT_REQUEST] = true,
		[EntityStateActionMap.ENTITY_ACTION.START_EVENT] = true,
		[EntityStateActionMap.ENTITY_ACTION.END_EVENT] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_A] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_B] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_C] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_MELEE] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_RANGED] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_INDEX] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_CUSTOM] = true,
		[EntityStateActionMap.ENTITY_ACTION.LOCKUP] = true,
		[EntityStateActionMap.ENTITY_ACTION.KNOCKBACK] = true,
		[EntityStateActionMap.ENTITY_ACTION.SPECIAL_MOVE] = true,
		[EntityStateActionMap.ENTITY_ACTION.SPECIAL_ATTACK] = true,
		[EntityStateActionMap.ENTITY_ACTION.START_COMBAT] = true,
		[EntityStateActionMap.ENTITY_ACTION.END_COMBAT] = true,
	},
	
	[EntityStateActionMap.ENTITY_STATE.SPAWN] = {
		[EntityStateActionMap.ENTITY_ACTION.IDLE] = false,
		[EntityStateActionMap.ENTITY_ACTION.MOVE] = false,
		[EntityStateActionMap.ENTITY_ACTION.MOVE_START] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SET_STATE] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SEARCH] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SET_TARGET] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_RESET_STATE] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_SPAWN] = true,
		[EntityStateActionMap.ENTITY_ACTION.END_SPAWN] = true,
		[EntityStateActionMap.ENTITY_ACTION.START_DESPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_DESPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.INTERACT_REQUEST] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_EVENT] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_EVENT] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_A] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_B] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_C] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_MELEE] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_RANGED] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_INDEX] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_CUSTOM] = false,
		[EntityStateActionMap.ENTITY_ACTION.LOCKUP] = false,
		[EntityStateActionMap.ENTITY_ACTION.KNOCKBACK] = false,
		[EntityStateActionMap.ENTITY_ACTION.SPECIAL_MOVE] = false,
		[EntityStateActionMap.ENTITY_ACTION.SPECIAL_ATTACK] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_COMBAT] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_COMBAT] = false,
	},
	
	[EntityStateActionMap.ENTITY_STATE.DESPAWN] = {
		[EntityStateActionMap.ENTITY_ACTION.IDLE] = false,
		[EntityStateActionMap.ENTITY_ACTION.MOVE] = false,
		[EntityStateActionMap.ENTITY_ACTION.MOVE_START] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SET_STATE] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SEARCH] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SET_TARGET] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_RESET_STATE] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_SPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_SPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_DESPAWN] = true,
		[EntityStateActionMap.ENTITY_ACTION.END_DESPAWN] = true,
		[EntityStateActionMap.ENTITY_ACTION.INTERACT_REQUEST] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_EVENT] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_EVENT] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_A] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_B] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_C] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_MELEE] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_RANGED] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_INDEX] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_CUSTOM] = false,
		[EntityStateActionMap.ENTITY_ACTION.LOCKUP] = false,
		[EntityStateActionMap.ENTITY_ACTION.KNOCKBACK] = false,
		[EntityStateActionMap.ENTITY_ACTION.SPECIAL_MOVE] = false,
		[EntityStateActionMap.ENTITY_ACTION.SPECIAL_ATTACK] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_COMBAT] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_COMBAT] = false,
	},
	
	[EntityStateActionMap.ENTITY_STATE.EVENT] = {
		[EntityStateActionMap.ENTITY_ACTION.IDLE] = false,
		[EntityStateActionMap.ENTITY_ACTION.MOVE] = false,
		[EntityStateActionMap.ENTITY_ACTION.MOVE_START] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SET_STATE] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SEARCH] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SET_TARGET] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_RESET_STATE] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_SPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_SPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_DESPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_DESPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.INTERACT_REQUEST] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_EVENT] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_EVENT] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_A] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_B] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_C] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_MELEE] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_RANGED] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_INDEX] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_CUSTOM] = false,
		[EntityStateActionMap.ENTITY_ACTION.LOCKUP] = false,
		[EntityStateActionMap.ENTITY_ACTION.KNOCKBACK] = false,
		[EntityStateActionMap.ENTITY_ACTION.SPECIAL_MOVE] = false,
		[EntityStateActionMap.ENTITY_ACTION.SPECIAL_ATTACK] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_COMBAT] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_COMBAT] = false,
	},
	
	[EntityStateActionMap.ENTITY_STATE.COMBAT] = {
		[EntityStateActionMap.ENTITY_ACTION.IDLE] = false,
		[EntityStateActionMap.ENTITY_ACTION.MOVE] = false,
		[EntityStateActionMap.ENTITY_ACTION.MOVE_START] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SET_STATE] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SEARCH] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_SET_TARGET] = false,
		[EntityStateActionMap.ENTITY_ACTION.TARGETING_RESET_STATE] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_SPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_SPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_DESPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_DESPAWN] = false,
		[EntityStateActionMap.ENTITY_ACTION.INTERACT_REQUEST] = false,
		[EntityStateActionMap.ENTITY_ACTION.START_EVENT] = false,
		[EntityStateActionMap.ENTITY_ACTION.END_EVENT] = false,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_A] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_B] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_SLOT_C] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_MELEE] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_RANGED] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_INDEX] = true,
		[EntityStateActionMap.ENTITY_ACTION.ATTACK_CUSTOM] = true,
		[EntityStateActionMap.ENTITY_ACTION.LOCKUP] = true,
		[EntityStateActionMap.ENTITY_ACTION.KNOCKBACK] = true,
		[EntityStateActionMap.ENTITY_ACTION.SPECIAL_MOVE] = true,
		[EntityStateActionMap.ENTITY_ACTION.SPECIAL_ATTACK] = true,
		[EntityStateActionMap.ENTITY_ACTION.START_COMBAT] = true,
		[EntityStateActionMap.ENTITY_ACTION.END_COMBAT] = true,
	}
}

return EntityStateActionMap