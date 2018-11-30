-----------------------
--Game entity database:
-----------------------

EntityDatabase = {}
EntityDatabase.__index = EntityDatabase

setmetatable(EntityDatabase, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EntityDatabase.new (id, ENTITY_TYPE, ENTITY_COMPONENT)
	local self = setmetatable ({}, EntityDatabase)
		self.id = id
		
		self.globalTables = {}		--['entity type'] = globalTable
		self.componentTables = {}	--['entity type']['component id'] = componentTable
		
		self:buildGlobalTables(ENTITY_TYPE)
		self:buildComponentTables(ENTITY_TYPE, ENTITY_COMPONENT)
	return self
end

function EntityDatabase:indexGlobalTable(entityType, tbl)
	self.globalTables[entityType] = tbl
end

function EntityDatabase:indexComponentTable(entityType, componentId, tbl)
	self.componentTables[entityType][componentId] = tbl
end

function EntityDatabase:getComponentTable(entityType, componentId)
	return self.componentTables[entityType][componentId]
end

function EntityDatabase:getComponentTableRows(entityType, componentId)
	local tbl = self.componentTables[entityType][componentId]
	if tbl ~= nil then
		return tbl
	end
	return {}
end

function EntityDatabase:getGlobalTable(entityType)
	return self.globalTables[entityType]
end

function EntityDatabase:buildGlobalTables(ENTITY_TYPE)
	for typeName, typeId in pairs(ENTITY_TYPE) do
		self.globalTables[typeId] = {}
	end
end

function EntityDatabase:buildComponentTables(ENTITY_TYPE, ENTITY_COMPONENT)
	for typeName, typeId in pairs(ENTITY_TYPE) do
		self.componentTables[typeId] = {}
		for componentName, componentId in pairs(ENTITY_COMPONENT) do
			self.componentTables[typeId][componentId] = nil
		end
	end
end