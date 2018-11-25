require '/spatial update/SpatialUpdater'
require '/collision/CollisionPairsHashtable'

local UPDATE_AREA = require '/spatial update/UPDATE_AREA'
local ENTITY_ROLE = require '/entity/ENTITY_ROLE'

local EntityEventUpdater = SpatialUpdater.new('entity_event')

EntityEventUpdater.COLLISION_TYPE = {
	playerEvent = 1,
	hostileEvent = 2
}

EntityEventUpdater.collisonPairsHashtables = {
	[EntityEventUpdater.COLLISION_TYPE.playerEvent] = CollisionPairsHashtable.new(100, true, true),
	[EntityEventUpdater.COLLISION_TYPE.hostileEvent] = CollisionPairsHashtable.new(100, true, true),
}

EntityEventUpdater.collisionRolePairs = {
	[EntityEventUpdater.COLLISION_TYPE.playerEvent] = {ENTITY_ROLE.PLAYER, ENTITY_ROLE.ENTITY_EVENT},
	[EntityEventUpdater.COLLISION_TYPE.hostileEvent] = {ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.ENTITY_EVENT},
}

EntityEventUpdater.updateAreaQueue = {
	UPDATE_AREA.NORMAL, UPDATE_AREA.NORMAL
}

EntityEventUpdater.updateCollisionTypeQueue = {
	{
		EntityEventUpdater.COLLISION_TYPE.playerEvent,
	},
	{
		EntityEventUpdater.COLLISION_TYPE.playerEvent,
		EntityEventUpdater.COLLISION_TYPE.hostileEvent,
	}
}

function EntityEventUpdater:resetHashtables()
	for colId, hashTbl in pairs(self.collisonPairsHashtables) do
		hashTbl:resetHashChain()
	end
end

function EntityEventUpdater:update(updateSystem)
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

function EntityEventUpdater:createSpatialQuery(updateSystem, area, hashtable, roleA, roleB)
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

function EntityEventUpdater:sendSpatialQuery(updateSystem, spatialQuery)
	local spatialSystemRequest = updateSystem.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = spatialQuery
	updateSystem.eventDispatcher:postEvent(1, 1, spatialSystemRequest)
	updateSystem.spatialSystemRequestPool:incrementCurrentIndex()
end

function EntityEventUpdater:getQueryResults(spatialSystem, spatialQuery, results)
	--do nothing
end

function EntityEventUpdater:getSpatialQueryCallbackMethod()
	return function (spatialSystem, spatialQuery, results)
		self:getQueryResults(spatialSystem, spatialQuery, results) 
	end
end

function EntityEventUpdater:getHashtable(collisionType)
	return self.collisonPairsHashtables[collisionType]
end

function EntityEventUpdater:getCollisionRolePairs(collisionType)
	return self.collisionRolePairs[collisionType]
end

function EntityEventUpdater:getCurrentUpdateCollisionTypes()
	return self.updateCollisionTypeQueue[self.currentFrame]
end

function EntityEventUpdater:initHashtables()
	for colId, hashTbl in pairs(self.collisonPairsHashtables) do
		hashTbl:buildPairsTable()
	end
end

EntityEventUpdater:initHashtables()
return EntityEventUpdater