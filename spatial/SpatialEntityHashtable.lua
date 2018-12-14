-------------------------------
--SpatialEntityHashtable class:
-------------------------------

SpatialEntityHashtable = {}
SpatialEntityHashtable.__index = SpatialEntityHashtable

setmetatable(SpatialEntityHashtable, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialEntityHashtable.new (maxEntities, resizable)
	local self = setmetatable ({}, SpatialEntityHashtable)
		
		self.entityTable = {}
		
		self.maxEntities = maxEntities
		self.resizable = resizable		--bool
		self.lastUsedHash = 0			--used for linear hash traversal (?)
	return self
end

function SpatialEntityHashtable:buildEntityTable()
	self.entityTable = {}
	for i=1, self.maxEntities do
		table.insert(self.entityTable, HashedSpatialEntity.new(nil))
	end
end

function SpatialEntityHashtable:setMaxEntities(maxEntities)
	--reset the hash chain before setting it to a lower value

	self.maxEntities = maxEntities
	
	if self.maxEntities >= #self.entityTable then
		for i = #self.entityTable, maxEntities-1 do
			table.insert(self.entityTable, HashedSpatialEntity.new(nil))
		end
	else
		for i = #self.entityTable, self.maxEntities+1, -1 do
			self.entityTable[i] = nil
		end
	end
end

function SpatialEntityHashtable:hashId(id)
	return (id % self.maxEntities) + 1
end

function SpatialEntityHashtable:insertSpatialEntity(id, entity)
	local originalHash = self:hashId(id)
	local finalHash = originalHash
	local hashedSpatialEntity = self.entityTable[finalHash]
	
	while self:checkForHashCollision(hashedSpatialEntity) do
		
		if self:checkForDuplicateEntity(hashedSpatialEntity, entity) then
			return 0	--duplicate pair; 0 -> pair not registered
		end
		
		finalHash = self:getNewHash(finalHash)
		
		if finalHash == originalHash then
			if self.resizable then
				self:setMaxEntities(self.maxEntities + 1)
				finalHash = self.maxEntities
			else
				return 0
			end
		end
		
		hashedSpatialEntity = self.entityTable[finalHash]
	end
	
	self:registerEntityIntoHashedEntity(hashedSpatialEntity, finalHash, entity)
	return finalHash
end

function SpatialEntityHashtable:getNewHash(hash)
	--simple linear probing:
	return ((hash + 1) % self.maxEntities) + 1
end

function SpatialEntityHashtable:checkForHashCollision(hashedSpatialEntity)
	if hashedSpatialEntity.chainedHash ~= nil then
		return true
	end
	return false
end

function SpatialEntityHashtable:checkForDuplicateEntity(hashedEntity, spatialEntity)
	if spatialEntity == hashedEntity.spatialEntity then
		return true
	end
	return false
end

function SpatialEntityHashtable:registerEntityIntoHashedEntity(hashedEntity, hash, spatialEntity)
	hashedEntity.chainedHash = self.lastUsedHash
	hashedEntity.spatialEntity = spatialEntity
	self.lastUsedHash = hash
end

function SpatialEntityHashtable:getLastUsedHash()
	return self.lastUsedHash
end

function SpatialEntityHashtable:resetTable()
	self.lastUsedHash = 0
end

function SpatialEntityHashtable:resetHashChain()
	while self.lastUsedHash > 0 do
		local hashedEntity = self.entityTable[self.lastUsedHash]
		self.lastUsedHash = hashedEntity.chainedHash
		hashedEntity.chainedHash = nil
	end
end

function SpatialEntityHashtable:getNextHashedEntityOnHashChain()
	--hash table iterator (resets the table while iterating)
	if self.lastUsedHash > 0 then
		local hashedEntity = self.entityTable[self.lastUsedHash]
		self.lastUsedHash = hashedEntity.chainedHash
		hashedEntity.chainedHash = nil
		return hashedEntity
	end
	return false
end

function SpatialEntityHashtable:getNextSpatialEntityOnHashChain()
	--hash table iterator (resets the table while iterating)
	if self.lastUsedHash > 0 then
		local hashedEntity = self.entityTable[self.lastUsedHash]
		self.lastUsedHash = hashedEntity.chainedHash
		hashedEntity.chainedHash = nil
		return hashedEntity.spatialEntity
	end
	return false
end

----------------------------
--HashedSpatialEntity class:
----------------------------

HashedSpatialEntity = {}
HashedSpatialEntity.__index = HashedSpatialEntity

setmetatable(HashedSpatialEntity, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function HashedSpatialEntity.new (spatialEntity)
	local self = setmetatable ({}, HashedSpatialEntity)
		self.chainedHash = nil
		self.spatialEntity = spatialEntity
	return self
end

---------------------------------
--Spatial Entity Hashtable Simple
---------------------------------
--this one is much simpler, use it

SpatialEntityHashtableSimple = {}
SpatialEntityHashtableSimple.__index = SpatialEntityHashtableSimple

setmetatable(SpatialEntityHashtableSimple, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialEntityHashtableSimple.new ()
	local self = setmetatable ({}, SpatialEntityHashtableSimple)
		self.entityTable = {}
		self.indexTable = {}
	return self
end

function SpatialEntityHashtableSimple:addEntity(spatialEntity)
	if not self.entityTable[spatialEntity.id] then
		self.entityTable[spatialEntity.id] = spatialEntity
		table.insert(self.indexTable, spatialEntity.id)
	end
end

function SpatialEntityHashtableSimple:reset()
	for i=#self.indexTable, 1, -1 do
		self.entityTable[self.indexTable[i]] = nil
		table.remove(self.indexTable)
	end
end

function SpatialEntityHashtableSimple:getCurrentEntity()
	local entity = false
	if #self.indexTable > 0 then
		entity = self.entityTable[self.indexTable[#self.indexTable]]
	end
	return entity
end

function SpatialEntityHashtableSimple:getLength()
	return #self.indexTable
end

function SpatialEntityHashtableSimple:sortEntities()
	--?
end

--------------------------------
--Spatial Entity Depth Hashtable
--------------------------------
--sorts by y values / includes collision
--I haven't tested this completely, it seems to work

SpatialEntityDepthHashtable = {}
SpatialEntityDepthHashtable.__index = SpatialEntityDepthHashtable

setmetatable(SpatialEntityDepthHashtable, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialEntityDepthHashtable.new ()
	local self = setmetatable ({}, SpatialEntityDepthHashtable)
		self.entityTable = {}
		self.indexTable = {}
	return self
end

function SpatialEntityDepthHashtable:getHash(spatialEntity)
	return math.ceil(spatialEntity.parentEntity.y + spatialEntity.parentEntity.h)
end

function SpatialEntityDepthHashtable:addEntity(spatialEntity)
	local currentHash = self:getHash(spatialEntity)
	
	while self.entityTable[currentHash] ~= nil do
		if self.entityTable[currentHash] == spatialEntity then
			return false
		end
		
		currentHash = currentHash + 1
	end
	
	self.entityTable[currentHash] = spatialEntity
	self:addEntityIndex(currentHash)
end

function SpatialEntityDepthHashtable:addEntityIndex(hash)
	local currentIndex = 1
	
	for i=1, #self.indexTable do
		if hash < self.indexTable[i] then
			break
		else
			currentIndex = currentIndex + 1
		end
	end
	
	table.insert(self.indexTable, currentIndex, hash)
end

function SpatialEntityDepthHashtable:reset()
	for i=#self.indexTable, 1, -1 do
		self.entityTable[self.indexTable[i]] = nil
		table.remove(self.indexTable)
	end
end

function SpatialEntityDepthHashtable:getCurrentEntity()
	local entity = false
	if #self.indexTable > 0 then
		entity = self.entityTable[self.indexTable[#self.indexTable]]
	end
	return entity
end

function SpatialEntityDepthHashtable:getLength()
	return #self.indexTable
end

function SpatialEntityDepthHashtable:sortEntities()
	--?
end