local SPAWN_TYPE = require '/spawn/ENTITY_SPAWN_TYPE'

local ENTITY_SPAWN = {
	[SPAWN_TYPE.GENERIC] = require '/spawn/script/generic_spawn',
	--...
}

return ENTITY_SPAWN