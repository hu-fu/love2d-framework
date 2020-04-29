local ACTION_IDS = require '/action/ACTION'

local ACTION_ASSET = {
	[ACTION_IDS.SET_ID.PLAYER_MAIN] = {name = 'PLAYER_MAIN', filepath = 'PLAYER_MAIN'},
	[ACTION_IDS.SET_ID.GENERIC_AREA] = {name = 'GENERIC_AREA', filepath = 'GENERIC_AREA'},
	[ACTION_IDS.SET_ID.GENERIC_EMITTER] = {name = 'GENERIC_EMITTER', filepath = 'GENERIC_EMITTER'},
	[ACTION_IDS.SET_ID.PLAYER_B] = {name = 'PLAYER_B', filepath = 'PLAYER_B'},
	[ACTION_IDS.SET_ID.PLAYER_C] = {name = 'PLAYER_C', filepath = 'PLAYER_C'},
	--...
}

return ACTION_ASSET