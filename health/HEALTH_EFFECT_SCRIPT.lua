local HEALTH_SCRIPT = {}

HEALTH_SCRIPT.ID = require '/health/HEALTH_EFFECT'

HEALTH_SCRIPT.SCRIPT = {
	[HEALTH_SCRIPT.ID.HEALTH_REGEN] = require '/health/effect script/HEALTH_REGEN',
	[HEALTH_SCRIPT.ID.IMMUNITY] = require '/health/effect script/IMMUNITY',
	
}

return HEALTH_SCRIPT