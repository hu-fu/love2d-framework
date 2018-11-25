-------------------------
--Inventory Item factory:
-------------------------

local ITEM_TYPE = require '/item/ITEM_TYPE'

InventoryItemFactory = {}
InventoryItemFactory.__index = InventoryItemFactory

setmetatable(InventoryItemFactory, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function InventoryItemFactory.new ()
	local self = setmetatable ({}, InventoryItemFactory)
		
	return self
end

function InventoryItemFactory:createInventoryItem(itemType, itemId)
	return self.createInventoryItemByType[itemType](itemId)
end

InventoryItemFactory.createInventoryItemByType = {
	[ITEM_TYPE.GENERIC] = function(itemId)
		return {
			id = itemId,
			quantity = 0
		}
	end
	
	--...
}