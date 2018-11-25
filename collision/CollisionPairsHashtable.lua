--------------------------
--collision pairs manager:
--------------------------
--this is my favorite part of the code
--hashtable impementation for collision pairs storage
--best if you use several instances of this, each for a specific collision type
--everything works. write some sort of guide to using this. (reset, loop, reset)
--this is just a hashtable not a 'manager'. change the name
--suggestion: change the chainedPairHash method of table traversal to something less shit

CollisionPairsHashtable = {}
CollisionPairsHashtable.__index = CollisionPairsHashtable

setmetatable(CollisionPairsHashtable, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function CollisionPairsHashtable.new (maxPairs, hashing, resizable)
	local self = setmetatable ({}, CollisionPairsHashtable)
		
		self.pairsTable = {}
		self.maxPairs = maxPairs
		
		self.resizable = resizable		--bool
		self.hashing = hashing			--bool (true->hashtable mode, false->array mode)
		
		self.pairsTableLength = 0		--number of used slots in array mode
		self.lastUsedHash = 0			--used for linear hash traversal (?)
	return self
end

function CollisionPairsHashtable:setTableMode(hashing)
	self.hashing = hashing
end

function CollisionPairsHashtable:buildPairsTable()
	self.pairsTable = {}
	for i=1, self.maxPairs do
		table.insert(self.pairsTable, collisionPair.new())
	end
end

function CollisionPairsHashtable:setMaxPairs(maxPairs)
	--reset the hash chain before setting it to a lower value

	self.maxPairs = maxPairs
	
	if self.maxPairs >= #self.pairsTable then
		for i = #self.pairsTable, maxPairs-1 do
			table.insert(self.pairsTable, collisionPair.new(0, 0))
		end
	else
		for i = #self.pairsTable, self.maxPairs+1, -1 do
			self.pairsTable[i] = nil
		end
	end
end

function CollisionPairsHashtable:hashIdPair(idA, idB)
	return ((idA + idB) % self.maxPairs) + 1
end

function CollisionPairsHashtable:insertPairIntoPairsTable(idA, idB, entityA, entityB)
	if self.hashing then
		self:hashInsertion(idA, idB, entityA, entityB)
	else
		self:linearInsertion(entityA, entityB)
	end
end

function CollisionPairsHashtable:linearInsertion(entityA, entityB)
	if self.pairsTableLength == #self.pairsTable then
		if self.resizable then
			self:setMaxPairs(self.pairsTableLength + 1)
		else
			return 0	--pair not registered / return another value?
		end
	end
	
	self.pairsTableLength = self.pairsTableLength + 1
	self:registerEntitiesIntoPairObject(self.pairsTable[self.pairsTableLength], 0, entityA, entityB)
	return self.pairsTableLength
end

function CollisionPairsHashtable:hashInsertion(idA, idB, entityA, entityB)
	local originalHash = self:hashIdPair(idA, idB)
	local finalHash = originalHash
	local collisionPair = self.pairsTable[finalHash]
	
	while self:checkForHashCollision(collisionPair) do
		
		if self:checkForDuplicatePair(collisionPair, entityA, entityB) then
			return 0	--duplicate pair; 0 -> pair not registered
		end
		
		finalHash = self:getNewHash(finalHash)
		
		if finalHash == originalHash then
			if self.resizable then
				self:setMaxPairs(self.maxPairs + 1)
				finalHash = self.maxPairs
			else
				return 0
			end
		end
		
		collisionPair = self.pairsTable[finalHash]
	end
	
	self:registerEntitiesIntoPairObject(collisionPair, finalHash, entityA, entityB)
	return finalHash
end

function CollisionPairsHashtable:getNewHash(hash)
	--simple linear probing:
	return ((hash + 1) % self.maxPairs) + 1
end

function CollisionPairsHashtable:checkForHashCollision(collisionPair)
	if collisionPair.chainedPairHash ~= nil then
		return true
	end
	return false
end

function CollisionPairsHashtable:checkForDuplicatePair(pair, entityA, entityB)
	--table objects are compared by reference, there should be no problem here
	if entityA == pair.entityA or entityA == pair.entityB then
		if entityB == pair.entityA or entityB == pair.entityB then
			return true
		end
	end
	return false
end

function CollisionPairsHashtable:registerEntitiesIntoPairObject(pair, hash, entityA, entityB)
	pair.chainedPairHash = self.lastUsedHash
	pair.entityA = entityA
	pair.entityB = entityB
	self.lastUsedHash = hash
end

function CollisionPairsHashtable:getListLength()
	return self.pairsTableLength
end

function CollisionPairsHashtable:getLastUsedHash()
	--last used hash -> firstPair.chainedPairHash -> next pair -> lastPair.chainedPairHash == 0
	return self.lastUsedHash
end

function CollisionPairsHashtable:resetTable()
	self.pairsTableLength = 0
	self.lastUsedHash = 0
end

function CollisionPairsHashtable:resetHashChain()
	while self.lastUsedHash > 0 do
		local pair = self.pairsTable[self.lastUsedHash]
		self.lastUsedHash = pair.chainedPairHash
		pair.chainedPairHash = nil
	end
end

--[[below: these iterators reset the array/hashtable when accessing the element
use getListLength(), getLastUsedHash() to access without reseting -> dangerous
resetTable() must be used at main loop end if used]]

function CollisionPairsHashtable:getNextPairOnList()
	--array iterator
	if self.pairsTableLength > 0 then
		local pair = self.pairsTable[self.pairsTableLength] 
		self.pairsTableLength = self.pairsTableLength - 1
		return pair
	end
	return false
end

function CollisionPairsHashtable:getNextPairOnHashChain()
	--hash table iterator
	if self.lastUsedHash > 0 then
		local pair = self.pairsTable[self.lastUsedHash]
		self.lastUsedHash = pair.chainedPairHash
		pair.chainedPairHash = nil
		return pair
	end
	return false
end

--[[
--loop hash table without reseting it:
	local currentHash = pairsHashTable.lastUsedHash
	local collisionPair = pairsHashTable.pairsTable[currentHash]
	while currentHash > 0 do
		self:detectCollision(collisionPair.entityA, collisionPair.entityB)
		currentHash = pair.chainedPairHash
		collisionPair = pairsHashTable.pairsTable[currentHash]
	end
	
	resetHashChain() -> use to reset!
]]

--debug methods

function CollisionPairsHashtable:getHashChainLength()
	local hashChainLength = 0
	local currentHash = self.lastUsedHash
	
	local pair = self:getNextPairOnHashChain()
	while pair ~= false do
		hashChainLength = hashChainLength + 1
		pair = self:getNextPairOnHashChain()
	end
	
	return hashChainLength
end

function CollisionPairsHashtable:printHashChain()
	local currentHash = self.lastUsedHash
	local collisionPair = self.pairsTable[currentHash]
	while currentHash > 0 do
		debugger.debugStrings[2] = debugger.debugStrings[2] .. '(' .. collisionPair.entityA.id .. 
			',' .. collisionPair.entityB.id .. '), '
		currentHash = collisionPair.chainedPairHash
		collisionPair = self.pairsTable[currentHash]
	end
end

-----------------------
--collision pair class:
-----------------------

collisionPair = {}
collisionPair.__index = collisionPair

setmetatable(collisionPair, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function collisionPair.new (entityA, entityB)
	local self = setmetatable ({}, collisionPair)
		self.chainedPairHash = nil
		self.entityA = entityA
		self.entityB = entityB
	return self
end