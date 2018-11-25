local EMITTER_TYPE = require '/effect/EMITTER_TYPE'
local ACTION = require '/action/ACTION'

local EMITTER_TEMPLATE = {
	[EMITTER_TYPE.GENERIC] = {
		deviationX = 0, deviationY = 0, 
		w = 0, h = 0,
		overwriteDimensions = true,
		direction = 0,
		focus = true,
		actionSetId = ACTION.SET_ID.GENERIC_EMITTER,
		actionId = ACTION.ACTION_ID[ACTION.SET_ID.GENERIC_EMITTER].GENERIC
	},
	
	[EMITTER_TYPE.GLOBAL] = {
		deviationX = 0, deviationY = 0, 
		w = 0, h = 0,
		overwriteDimensions = false,
		direction = 0,
		focus = false,
		actionSetId = ACTION.SET_ID.GENERIC_EMITTER,
		actionId = ACTION.ACTION_ID[ACTION.SET_ID.GENERIC_EMITTER].GLOBAL
	},
	
	--... add as many as you want!
}

return EMITTER_TEMPLATE