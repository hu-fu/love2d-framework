require 'misc'

---------------------
--Area Spatial Entity
---------------------

AreaSpatialEntity = {}
AreaSpatialEntity.__index = AreaSpatialEntity

setmetatable(AreaSpatialEntity, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function AreaSpatialEntity.new (areaId, grid)
	local self = setmetatable ({}, AreaSpatialEntity)
		self.areaId = areaId
		self.grid = grid
		
		self.currentEntityId = 0
		--self.entityList = {}
	return self
end

function AreaSpatialEntity:getCurrentEntityId()
	local id = self.currentEntityId
	self.currentEntityId = self.currentEntityId + 1
	return id
end

--------------------------
--Spatial Entity Database:
--------------------------
--stores spatial entities (don't know if I should use this - might be useful)

SpatialEntityDatabase = {}
SpatialEntityDatabase.__index = SpatialEntityDatabase

setmetatable(SpatialEntityDatabase, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialEntityDatabase.new (entityType)
	local self = setmetatable ({}, SpatialEntityDatabase)
		
		self.entityType = entityType
		
		self.entityList = {}
	return self
end

-----------------
--Spatial Entity:
-----------------

SpatialEntity = {}
SpatialEntity.__index = SpatialEntity

setmetatable(SpatialEntity, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialEntity.new (id, parentEntity, entityRole, entityType, spatialLevel, spatialIndexX, 
	spatialIndexY, xOverlap, yOverlap)
	local self = setmetatable ({}, SpatialEntity)
		
		self.id = id
		self.parentEntity = parentEntity
		
		self.entityRole = entityRole
		self.entityType = entityType
		self.spatialLevel = spatialLevel
		self.spatialIndexX = spatialIndexX
		self.spatialIndexY = spatialIndexY
		self.xOverlap = xOverlap
		self.yOverlap = yOverlap
		
	return self
end

-----------------------------
--Spatial Entity Object Pool:
-----------------------------

SpatialEntityObjectPool = {}
SpatialEntityObjectPool.__index = SpatialEntityObjectPool

setmetatable(SpatialEntityObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialEntityObjectPool.new (defaultNumberOfObjects)
	local self = setmetatable ({}, SpatialEntityObjectPool)
		
		self.objectPool = {}
		self.currentIndex = 1
		
		self.defaultNumberOfObjects = defaultNumberOfObjects
	return self
end

function SpatialEntityObjectPool:createNewObject()
	local objectId = #self.objectPool + 1
	local object = spatialEntity.new(objectId, nil, false, 0, 0, false, false, 1)
	table.insert(self.objectPool, object)
end

function SpatialEntityObjectPool:buildObjectPool()
	for i=1, self.defaultNumberOfObjects do
		self:createNewObject()
	end
end

function SpatialEntityObjectPool:getCurrentAvailableObject()
	return self.objectPool[self.currentIndex]
end

function SpatialEntityObjectPool:getLength()
	return self.currentIndex - 1
end

function SpatialEntityObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function SpatialEntityObjectPool:incrementCurrentIndex()
	if self.currentIndex == #self.objectPool then
		self:createNewObject()
	end
	self.currentIndex = self.currentIndex + 1
end

function SpatialEntityObjectPool:resetObjectPoolSize()
	for i=#self.objectPool, self.defaultNumberOfObjects, -1 do
		table.remove(self.objectPool)
	end
end

-----------------------
--Spatial Entity Table:
-----------------------
--hash table for spatial entities

SpatialEntityTable = {}
SpatialEntityTable.__index = SpatialEntityTable

setmetatable(SpatialEntityTable, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialEntityTable.new ()
	local self = setmetatable ({}, SpatialEntityTable)
		
		self.entityTable = {}
		
	return self
end

function SpatialEntityTable:buildEntityTable(maxXIndex, maxYIndex)
	for i=1, maxYIndex do
		local listRow = {}
		for j=1, maxXIndex do
			local listColumn = {}
			table.insert(listRow, listColumn)
		end
		table.insert(self.entityTable, listRow)
	end
	
	self:createEntityTableDefaultValue()
end

function SpatialEntityTable:createEntityTableDefaultValue()
	--TODO: expand on this
	
	local defaultContainerY = {}
	local defaultContainerX = {}
	
	setDefaultTableValue(defaultContainerY, defaultContainerX)
	setDefaultTableValue(self.entityTable, defaultContainerY)
	
	for i=1, #self.entityTable do
		setDefaultTableValue(self.entityTable[i], defaultContainerX)
	end
end

function SpatialEntityTable:addEntityToTable(xIndex, yIndex, entity)
	table.insert(self.entityTable[yIndex][xIndex], entity)
end

function SpatialEntityTable:removeEntityFromTable(xIndex, yIndex, entity)
	local list = self.entityTable[yIndex][xIndex]
	for i=1, #list do
		if list[i].id == entity.id then
			list[i] = list[#list]
			table.remove(list)
			break
		end
	end
end

function SpatialEntityTable:registerEntity(entity)
	self:addEntityToTable(entity.spatialIndexX, entity.spatialIndexY, entity)
	
	if entity.xOverlap then
		self:addEntityToTable(entity.spatialIndexX+1, entity.spatialIndexY, entity)
	end
	if entity.yOverlap then
		self:addEntityToTable(entity.spatialIndexX, entity.spatialIndexY+1, entity)
	end
	if entity.xOverlap and entity.yOverlap then
		self:addEntityToTable(entity.spatialIndexX+1, entity.spatialIndexY+1, entity)
	end
end

function SpatialEntityTable:unregisterEntity(entity)
	self:removeEntityFromTable(entity.spatialIndexX, entity.spatialIndexY, entity)
	
	if entity.xOverlap then
		self:removeEntityFromTable(entity.spatialIndexX+1, entity.spatialIndexY, entity)
	end
	if entity.yOverlap then
		self:removeEntityFromTable(entity.spatialIndexX, entity.spatialIndexY+1, entity)
	end
	if entity.xOverlap and entity.yOverlap then
		self:removeEntityFromTable(entity.spatialIndexX+1, entity.spatialIndexY+1, entity)
	end
end

function SpatialEntityTable:registerEntityInArea(entity, topLeftX, topLeftY, bottomRightX, bottomRightY)
	--registers entity in all nodes specified by tl, br parameters
	for i=topLeftY, bottomRightY do
		for j=topLeftX, bottomRightX do
			self:addEntityToTable(j, i, entity)
		end
	end
end

function SpatialEntityTable:unregisterEntityInArea(entity, topLeftX, topLeftY, bottomRightX, 
	bottomRightY)
	for i=topLeftY, bottomRightY do
		for j=topLeftX, bottomRightX do
			self:removeEntityFromTable(j, i, entity)
		end
	end
end