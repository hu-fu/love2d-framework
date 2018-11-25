--------------------
--Inventory Methods:
--------------------

INVENTORY_METHODS = {}

require '/item/InventoryObjects'
INVENTORY_METHODS.inventoryItemFactory = InventoryItemFactory.new()
local INVENTORY = require '/item/INVENTORY'
local ITEM_TYPE = require '/item/ITEM_TYPE'
local ITEM = require '/item/ITEM'
local ITEM_DATABASE = require '/item/ITEM_DATABASE'
local ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'

function INVENTORY_METHODS:getItemFromDatabase(itemType, itemId)
	return ITEM_DATABASE[itemType][itemId]
end

function INVENTORY_METHODS:getInventoryById(inventoryTable, inventoryId)
	return inventoryTable[inventoryId]
end

function INVENTORY_METHODS:getItemFromInventory(system, inventoryTable, inventoryId, itemType, itemId, itemIndex)
	local inventory = self:getInventoryById(inventoryTable, inventoryId)
	return self.getItemMethods[itemType](system, inventory, itemType, itemId, itemIndex)
end

function INVENTORY_METHODS:addItem(system, inventoryTable, inventoryId, itemEntity, itemType, itemId)
	local inventory = self:getInventoryById(inventoryTable, inventoryId)
	self.addItemMethods[itemType](system, inventory, itemEntity, itemType, itemId)
end

function INVENTORY_METHODS:removeItem(system, inventoryTable, inventoryId, itemType, itemId, itemIndex, 
	componentType, component)
	local inventory = self:getInventoryById(inventoryTable, inventoryId)
	self.removeItemMethods[itemType](system, inventory, itemType, itemId, componentType, component)
end

INVENTORY_METHODS.getItemMethods = {
	[ITEM_TYPE.GENERIC] = function(system, inventory, itemType, itemId, itemIndex)
		
	end,
	
}

INVENTORY_METHODS.addItemMethods = {
	[ITEM_TYPE.GENERIC] = function(system, inventory, itemEntity, itemType, itemId)
		local dbItem = INVENTORY_METHODS:getItemFromDatabase(itemType, itemId)
		local inventoryItem = inventory[itemType][itemId]
		local itemQuantity = itemEntity.itemQuantity
		
		if not inventoryItem then
			local item = INVENTORY_METHODS.inventoryItemFactory:createInventoryItem(itemType, itemId)
			inventory[itemType][itemId] = item
			inventoryItem = inventory[itemType][itemId]
		end
		
		if inventoryItem.quantity + itemQuantity > dbItem.maxQuantity then
			--sets quantity to max carry value:
			itemQuantity = dbItem.maxQuantity - inventoryItem.quantity
		end
		
		if inventoryItem.quantity + itemQuantity > dbItem.maxQuantity then
			INVENTORY_METHODS:onAddItem(system, false, inventory, itemEntity, itemType, itemId)
		else
			inventoryItem.quantity = inventoryItem.quantity + itemQuantity
			INVENTORY_METHODS:onAddItem(system, true, inventory, itemEntity, itemType, itemId)
		end
	end,
	
}

INVENTORY_METHODS.removeItemMethods = {
	[ITEM_TYPE.GENERIC] = function(system, inventory, itemType, itemId, itemIndex, componentType, component)
		--check if component is present in some cases; unnequip item in component
		INVENTORY_METHODS:onRemoveItem(system, true, inventory, itemType, itemId, itemIndex, componentType, component)
	end,
	
}

function INVENTORY_METHODS:equipItem(componentType, component, inventoryItem)
	self.equipItemMethods[componentType](component, inventoryItem)
end

function INVENTORY_METHODS:unnequipItem(componentType, component, inventoryItem)
	self.unnequipItemMethods[componentType](component, inventoryItem)
end

INVENTORY_METHODS.equipItemMethods = {
	
}

INVENTORY_METHODS.unnequipItemMethods = {
	
}

function INVENTORY_METHODS:onGetItem(system, inventoryItem, inventory, itemType, itemId, itemIndex)
	if system.onGetItem then
		system:onGetItem(self, inventoryItem, inventory, itemType, itemId, itemIndex)
	end
end

function INVENTORY_METHODS:onAddItem(system, isAdded, inventory, itemEntity, itemType, itemId)
	if system.onAddItem then
		system:onAddItem(self, isAdded, inventory, itemEntity, itemType, itemId)
	end
end

function INVENTORY_METHODS:onRemoveItem(system, isRemoved, inventory, itemEntity, itemType, itemId)
	if system.onRemoveItem then
		system:onRemoveItem(self, isRemoved, inventory, itemEntity, itemType, itemId)
	end
end

function INVENTORY_METHODS:onEquipItem()
	
end

function INVENTORY_METHODS:onUnnequipItem()
	
end

return INVENTORY_METHODS