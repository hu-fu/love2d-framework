-----------------------
--Game entity database:
-----------------------
--expand on this

entityDatabase = {}
entityDatabase.__index = entityDatabase

setmetatable(entityDatabase, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function entityDatabase.new (id, name, entityType)
	local self = setmetatable ({}, entityDatabase)
		
		self.id = id
		self.name = name
		
		self.entityType = entityType
		
		self.tables = {}	--['table name string'] = componentTable
	return self
end

function entityDatabase:indexTable(index, tbl)
	self.tables[index] = tbl
end

function entityDatabase:getTable(tableIndex)
	return self.tables[tableIndex]
end

function entityDatabase:getTableRows(tableIndex)
	local tbl = self.tables[tableIndex]
	if tbl ~= nil then
		return tbl
	end
	return {}
end

---------------------------------
--Game entity database hashtable:
---------------------------------
--I need this for the areaEntityFile

EntityDatabaseHashtable = {}
EntityDatabaseHashtable.__index = EntityDatabaseHashtable

setmetatable(EntityDatabaseHashtable, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EntityDatabaseHashtable.new ()
	local self = setmetatable ({}, EntityDatabaseHashtable)
		
		self.databases = {}
	return self
end

function EntityDatabaseHashtable:indexDatabase(database)
	if database.entityType ~= nil then
		self.databases[database.entityType] = database
	end
end

function EntityDatabaseHashtable:getDatabase(entityType)
	if self.databases[entityType] ~= nil then
		return self.databases[entityType]
	end
	return nil
end

function EntityDatabaseHashtable:removeDatabase(entityType)
	if self.databases[entityType] ~= nil then
		self.databases[entityType] = nil
	end
end

function EntityDatabaseHashtable:resetHashtable()
	self.databases = {}
end