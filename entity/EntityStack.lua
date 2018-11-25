-------------
--Entity Stack:
-------------

EntityDatabaseStack = {}
EntityDatabaseStack.__index = EntityDatabaseStack

setmetatable(EntityDatabaseStack, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EntityDatabaseStack.new (maxEntities)
	local self = setmetatable ({}, EntityDatabaseStack)
		self.stack = {}
		self.maxEntities = maxEntities
	return self
end

function EntityDatabaseStack:pushEntity(entity)
	self:removeEntityById(entity.id)
	
	table.insert(self.stack, 1, entity)
	
	if #self.stack > self.maxEntities then
		self:popEntity()
	end
end

function EntityDatabaseStack:popEntity()
	table.remove(self.stack)
end

function EntityDatabaseStack:getCurrent()
	if #self.stack > 0 then
		return self.stack[1]
	end
	return nil	--default empty entity
end

function EntityDatabaseStack:getEntity(entityId)
	for i=2, #self.stack do
		if self.stack[i].id == entityId then
			return self.stack[i]
		end
	end
	return nil
end

function EntityDatabaseStack:clear()
	for i=#self.stack, -1, 1 do
		self:destroyEntity(self.stack[i])
		table.remove(self.stack)
	end
end

function EntityDatabaseStack:removeEntity(entity)
	for i=1, #self.stack do
		if self.stack[i] == entity then
			table.remove(self.stack, i)
			return nil
		end
	end
end

function EntityDatabaseStack:removeEntityById(entityId)
	for i=1, #self.stack do
		if self.stack[i].id == entityId then
			table.remove(self.stack, i)
			return nil
		end
	end
end

function EntityDatabaseStack:destroyEntity(entity)
	--do stuff
end