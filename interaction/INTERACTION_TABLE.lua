local INTERACTION_TYPE = require '/interaction/INTERACTION_TYPE'
local INTERACTION_ID = require '/interaction/INTERACTION'

return {
	[INTERACTION_TYPE.GENERIC] = require '/interaction/script/generic',
	--...
}