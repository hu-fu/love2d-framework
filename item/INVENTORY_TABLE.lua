--obligatory string indexes; this is persistent for some inventory types (like PLAYER_INV)
--equipped items are stored into the entity components

local INVENTORY = require '/item/INVENTORY'
local ITEM_TYPE = require '/item/ITEM_TYPE'
local ITEM = require '/item/ITEM'

local INVENTORY_TABLE = {
	[INVENTORY.GENERIC] = {
		[ITEM_TYPE.GENERIC] = {
			[ITEM.GENERIC] = {id=ITEM.GENERIC, quantity=0},
			--...
		},
		
		--[[
		item type . weapon = {
			[generic] = {quantity=x, upgrade='upgrade id', other vars},
			OR
			[generic] = {{upgrade, other vars}, {upgrade, other vars}, ...}
			OR
			{{itemId=x, ...}, {itemId=y, ...}, ...}	--this is better, use it
		}
		]]
	},
	
	--...
}

return INVENTORY_TABLE