local ITEM_TYPE = require '/item/ITEM_TYPE'
local ITEM = require '/item/ITEM'

local ITEM_DATABASE = {
	[ITEM_TYPE.GENERIC] = require '/item/asset/generic',
	--...
}

return ITEM_DATABASE