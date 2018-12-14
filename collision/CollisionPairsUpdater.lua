require '/spatial update/SpatialUpdater'
require '/collision/CollisionPairsHashtable'

local UPDATE_AREA = require '/spatial update/UPDATE_AREA'
local ENTITY_ROLE = require '/entity/ENTITY_ROLE'

local CollisionPairsUpdater = SpatialUpdater.new('collision')

CollisionPairsUpdater.COLLISION_TYPE = {
	playerHostile = 1,
	playerObstacle = 2,
	hostileObstacle = 3,
	hostileHostile = 4,
	hostileProjectile = 5,
	friendProjectile = 6,
	obstacleFriendProjectile = 7,
	obstacleHostileProjectile = 8,
}

CollisionPairsUpdater.collisonPairsHashtables = {
	[CollisionPairsUpdater.COLLISION_TYPE.playerHostile] = CollisionPairsHashtable.new(100, true, true),
	[CollisionPairsUpdater.COLLISION_TYPE.playerObstacle] = CollisionPairsHashtable.new(100, true, true),
	[CollisionPairsUpdater.COLLISION_TYPE.hostileObstacle] = CollisionPairsHashtable.new(100, true, true),
	[CollisionPairsUpdater.COLLISION_TYPE.hostileHostile] = CollisionPairsHashtable.new(100, true, true),
	[CollisionPairsUpdater.COLLISION_TYPE.hostileProjectile] = CollisionPairsHashtable.new(100, true, true),
	[CollisionPairsUpdater.COLLISION_TYPE.friendProjectile] = CollisionPairsHashtable.new(100, true, true),
	[CollisionPairsUpdater.COLLISION_TYPE.obstacleFriendProjectile] = CollisionPairsHashtable.new(100, true, true),
	[CollisionPairsUpdater.COLLISION_TYPE.obstacleHostileProjectile] = CollisionPairsHashtable.new(100, true, true),
}

CollisionPairsUpdater.collisionRolePairs = {
	[CollisionPairsUpdater.COLLISION_TYPE.playerHostile] = {ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC},
	[CollisionPairsUpdater.COLLISION_TYPE.playerObstacle] = {ENTITY_ROLE.PLAYER, ENTITY_ROLE.OBSTACLE},
	[CollisionPairsUpdater.COLLISION_TYPE.hostileObstacle] = {ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.OBSTACLE},
	[CollisionPairsUpdater.COLLISION_TYPE.hostileHostile] = {ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.HOSTILE_NPC},
	[CollisionPairsUpdater.COLLISION_TYPE.hostileProjectile] = {ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.FRIEND_PROJECTILE},
	[CollisionPairsUpdater.COLLISION_TYPE.friendProjectile] = {ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_PROJECTILE},
	[CollisionPairsUpdater.COLLISION_TYPE.obstacleHostileProjectile] = {ENTITY_ROLE.OBSTACLE, ENTITY_ROLE.HOSTILE_PROJECTILE},
	[CollisionPairsUpdater.COLLISION_TYPE.obstacleFriendProjectile] = {ENTITY_ROLE.OBSTACLE, ENTITY_ROLE.FRIEND_PROJECTILE},
}

CollisionPairsUpdater.updateAreaQueue = {
	UPDATE_AREA.NORMAL, UPDATE_AREA.NORMAL, UPDATE_AREA.NORMAL, UPDATE_AREA.NORMAL, UPDATE_AREA.MEDIUM
}

--BUG: crash when the obstacleFriendProjectile/hostile collisions are retrieved in sequent frames
	--the problem is that the spatial collision update query runs first than the projectile spatial
	--unregistration query, due to the spatial req stack running as LIFO
	--can be solved by calling the spatial query update system right after the projectile system
	--can also add a simple check if the entities exist in the system before colliding them
CollisionPairsUpdater.updateCollisionTypeQueue = {
	{
		CollisionPairsUpdater.COLLISION_TYPE.playerHostile,
		CollisionPairsUpdater.COLLISION_TYPE.playerObstacle,
		CollisionPairsUpdater.COLLISION_TYPE.hostileHostile,
		CollisionPairsUpdater.COLLISION_TYPE.hostileProjectile,
		CollisionPairsUpdater.COLLISION_TYPE.obstacleFriendProjectile,
	},
	{
		CollisionPairsUpdater.COLLISION_TYPE.playerHostile,
		CollisionPairsUpdater.COLLISION_TYPE.playerObstacle,
		CollisionPairsUpdater.COLLISION_TYPE.hostileObstacle,
		CollisionPairsUpdater.COLLISION_TYPE.friendProjectile,
		CollisionPairsUpdater.COLLISION_TYPE.obstacleHostileProjectile,
	},
	{
		CollisionPairsUpdater.COLLISION_TYPE.playerHostile,
		CollisionPairsUpdater.COLLISION_TYPE.playerObstacle,
		CollisionPairsUpdater.COLLISION_TYPE.hostileHostile,
		CollisionPairsUpdater.COLLISION_TYPE.hostileProjectile,
		CollisionPairsUpdater.COLLISION_TYPE.obstacleFriendProjectile,
	},
	{
		CollisionPairsUpdater.COLLISION_TYPE.playerHostile,
		CollisionPairsUpdater.COLLISION_TYPE.playerObstacle,
		CollisionPairsUpdater.COLLISION_TYPE.hostileObstacle,
		CollisionPairsUpdater.COLLISION_TYPE.friendProjectile,
		CollisionPairsUpdater.COLLISION_TYPE.obstacleHostileProjectile,
	},
	{
		CollisionPairsUpdater.COLLISION_TYPE.playerHostile,
		CollisionPairsUpdater.COLLISION_TYPE.playerObstacle,
		CollisionPairsUpdater.COLLISION_TYPE.hostileObstacle,
	}
}

function CollisionPairsUpdater:resetHashtables()
	for colId, hashTbl in pairs(self.collisonPairsHashtables) do
		hashTbl:resetHashChain()
	end
end

function CollisionPairsUpdater:update(updateSystem)
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

function CollisionPairsUpdater:createSpatialQuery(updateSystem, area, hashtable, roleA, roleB)
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

function CollisionPairsUpdater:sendSpatialQuery(updateSystem, spatialQuery)
	local spatialSystemRequest = updateSystem.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = spatialQuery
	updateSystem.eventDispatcher:postEvent(1, 1, spatialSystemRequest)
	updateSystem.spatialSystemRequestPool:incrementCurrentIndex()
end

function CollisionPairsUpdater:getQueryResults(spatialSystem, spatialQuery, results)
	--do nothing
end

function CollisionPairsUpdater:getSpatialQueryCallbackMethod()
	return function (spatialSystem, spatialQuery, results)
		self:getQueryResults(spatialSystem, spatialQuery, results) 
	end
end

function CollisionPairsUpdater:getHashtable(collisionType)
	return self.collisonPairsHashtables[collisionType]
end

function CollisionPairsUpdater:getCollisionRolePairs(collisionType)
	return self.collisionRolePairs[collisionType]
end

function CollisionPairsUpdater:getCurrentUpdateCollisionTypes()
	return self.updateCollisionTypeQueue[self.currentFrame]
end

function CollisionPairsUpdater:initHashtables()
	for colId, hashTbl in pairs(self.collisonPairsHashtables) do
		hashTbl:buildPairsTable()
	end
end

CollisionPairsUpdater:initHashtables()
return CollisionPairsUpdater