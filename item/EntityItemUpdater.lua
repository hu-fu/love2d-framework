require '/spatial update/SpatialUpdater'
require '/collision/CollisionPairsHashtable'

local UPDATE_AREA = require '/spatial update/UPDATE_AREA'
local ENTITY_ROLE = require '/entity/ENTITY_ROLE'

local EntityItemUpdater = SpatialUpdater.new('entity_item')

EntityItemUpdater.COLLISION_TYPE = {
	playerItem = 1
}

EntityItemUpdater.collisonPairsHashtables = {
	[EntityItemUpdater.COLLISION_TYPE.playerItem] = CollisionPairsHashtable.new(5, true, true)
}

EntityItemUpdater.collisionRolePairs = {
	[EntityItemUpdater.COLLISION_TYPE.playerItem] = {ENTITY_ROLE.PLAYER, ENTITY_ROLE.ITEM},
}

EntityItemUpdater.updateAreaQueue = {
	UPDATE_AREA.NORMAL
}

EntityItemUpdater.updateCollisionTypeQueue = {
	{
		EntityItemUpdater.COLLISION_TYPE.playerItem,
	}
}

function EntityItemUpdater:resetHashtables()
	for colId, hashTbl in pairs(self.collisonPairsHashtables) do
		hashTbl:resetHashChain()
	end
end

function EntityItemUpdater:update(updateSystem)
	self:resetHashtables()
	
	local area = updateSystem.updateAreaTable[self:getCurrentUpdateArea()]
	local collisionTypes = self:getCurrentUpdateCollisionTypes()
	
	for i=1, #collisionTypes do
		local hashtable = self:getHashtable(collisionTypes[i])
		local roles = self:getCollisionRolePairs(collisionTypes[i])
		local spatialQuery = self:createSpatialQuery(updateSystem, area, hashtable, roles[1], roles[2])
		self:sendSpatialQuery(updateSystem, spatialQuery)
	end
end

function EntityItemUpdater:createSpatialQuery(updateSystem, area, hashtable, roleA, roleB)
	local spatialQuery = updateSystem.getCollisionPairsQueryPool:getCurrentAvailableObjectDefault()
	updateSystem.getCollisionPairsQueryPool:incrementCurrentIndex()
	
	spatialQuery.x = area.x
	spatialQuery.y = area.y
	spatialQuery.w = area.w
	spatialQuery.h = area.h
	spatialQuery.entityRoleA = roleA
	spatialQuery.entityRoleB = roleB
	spatialQuery.pairsManager = hashtable
	spatialQuery.responseCallback = self:getSpatialQueryCallbackMethod()
	
	return spatialQuery
end

function EntityItemUpdater:sendSpatialQuery(updateSystem, spatialQuery)
	local spatialSystemRequest = updateSystem.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = spatialQuery
	updateSystem.eventDispatcher:postEvent(1, 1, spatialSystemRequest)
	updateSystem.spatialSystemRequestPool:incrementCurrentIndex()
end

function EntityItemUpdater:getQueryResults(spatialSystem, spatialQuery, results)
	--do nothing
end

function EntityItemUpdater:getSpatialQueryCallbackMethod()
	return function (spatialSystem, spatialQuery, results)
		self:getQueryResults(spatialSystem, spatialQuery, results) 
	end
end

function EntityItemUpdater:getHashtable(collisionType)
	return self.collisonPairsHashtables[collisionType]
end

function EntityItemUpdater:getCollisionRolePairs(collisionType)
	return self.collisionRolePairs[collisionType]
end

function EntityItemUpdater:getCurrentUpdateCollisionTypes()
	return self.updateCollisionTypeQueue[self.currentFrame]
end

function EntityItemUpdater:initHashtables()
	for colId, hashTbl in pairs(self.collisonPairsHashtables) do
		hashTbl:buildPairsTable()
	end
end

EntityItemUpdater:initHashtables()
return EntityItemUpdater