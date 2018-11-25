--------------------
--entity type class:
--------------------
--[[
TODO: change the name of this thing

creates a specific entity type
maps an entity db to a specific type
This is just an abstraction layer between the game logic and the entity composition
just a nice way of organizing entities by type
methods can be overriden if you want to use other containers
can be reduced to an enum as it is now but who cares lol
use the id for everything - get the id from the ENTITY_TYPE enum

TODO:
extend this to accept custom getters and setters for indexed entities, ex:
setPosition(arg, x, y){
	custom code here
}
]]

entityType = {}
entityType.__index = entityType

setmetatable(entityType, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function entityType.new (id, name)
	local self = setmetatable ({}, entityType)
		
		self.id = id
		self.name = name
		
		self.entityDatabase = nil
	return self
end

function entityType:setEntityDatabase(databaseObj)
	self.entityDatabase = databaseObj
end

function entityType:getEntityList(tableIndex)
	if self.entityDatabase ~= nil then
		return self.entityDatabase:getTableRows(tableIndex)
	end
	return {}
end