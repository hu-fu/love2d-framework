local DESPAWN_TYPE = require '/despawn/ENTITY_DESPAWN_TYPE'

local ENTITY_DESPAWN = {
	[DESPAWN_TYPE.GENERIC] = require '/despawn/script/generic_despawn',
	--...
}

return ENTITY_DESPAWN