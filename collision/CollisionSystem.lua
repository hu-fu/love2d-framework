------------------
--Collision system
------------------

local CollisionSystem = {}

---------------
--Dependencies:
---------------

CollisionSystem.COLLISION_RESPONSE_TYPES = require '/collision/COLLISION_RESPONSE_TYPE'
CollisionSystem.ENTITY_TYPES = require '/entity/ENTITY_TYPE'
CollisionSystem.ENTITY_ROLES = require '/entity/ENTITY_ROLE'
CollisionSystem.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
CollisionSystem.EVENT_TYPES = require '/event/EVENT_TYPE'
CollisionSystem.PROJECTILE_DESTRUCTION_TYPE = require '/projectile/PROJECTILE_DESTRUCTION_TYPE'
CollisionSystem.PROJECTILE_REQUEST = require '/projectile/PROJECTILE_REQUEST'
local SYSTEM_ID = require '/system/SYSTEM_ID'

CollisionSystem.collisionMethods = require '/collision/CollisionMethods'
CollisionSystem.collisionPairsUpdater = require '/collision/CollisionPairsUpdater'

-------------------
--System Variables:
-------------------

CollisionSystem.id = SYSTEM_ID.COLLISION

CollisionSystem.spatialUpdaterRequestPool = EventObjectPool.new(CollisionSystem.EVENT_TYPES.SPATIAL_UPDATER, 2)
CollisionSystem.projectileRequestPool = EventObjectPool.new(CollisionSystem.EVENT_TYPES.PROJECTILE, 100)

CollisionSystem.eventDispatcher = nil
CollisionSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

CollisionSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			
		end,
		
		[2] = function(request)
		
		end,
	}
}

---------------
--Init Methods:
---------------

function CollisionSystem:setUpdaterOnSpatialUpdaterSystem()
	local updaterSystemRequest = self.spatialUpdaterRequestPool:getCurrentAvailableObject()
	updaterSystemRequest.updaterObj = self.collisionPairsUpdater
	self.eventDispatcher:postEvent(2, 2, updaterSystemRequest)
	self.spatialUpdaterRequestPool:incrementCurrentIndex()
end

function CollisionSystem:init()
	
end

---------------
--Exec Methods:
---------------

function CollisionSystem:update()
	for colId, hashTbl in pairs(self.collisionPairsUpdater.collisonPairsHashtables) do
		self:detectCollisions(hashTbl)
	end
	
	self.projectileRequestPool:resetCurrentIndex()
end

function CollisionSystem:detectCollisions(pairsHashTable)
	--loop pairs table without reseting it:
	
	if pairsHashTable.hashing then
		local currentHash = pairsHashTable.lastUsedHash
		local collisionPair = nil
		while currentHash > 0 do
			collisionPair = pairsHashTable.pairsTable[currentHash]
			self:detectCollision(collisionPair.entityA, collisionPair.entityB)
			currentHash = collisionPair.chainedPairHash
		end
	else
		--TODO: array iteration (not needed (?) the hash table is pretty fast)
	end
end

function CollisionSystem:detectCollision(spatialEntityA, spatialEntityB)
	self.collisionDetectionMethods[spatialEntityA.entityType]
		[spatialEntityB.entityType](spatialEntityA.parentEntity, spatialEntityB.parentEntity)
end

CollisionSystem.collisionDetectionMethods = {
	[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY] = {
		[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(entityA, entityB)
			
			if CollisionSystem.collisionMethods:rectToRectDetection(entityA.x, entityA.y, 
				entityA.x + entityA.w, entityA.y + entityA.h, entityB.x, entityB.y, 
				entityB.x + entityB.w, entityB.y + entityB.h) and 
				entityA ~= entityB then
				
				local mtvX, mtvY = CollisionSystem.collisionMethods:rectToRectResolution(
					entityA.x, entityA.y, entityA.x + entityA.w, entityA.y + entityA.h, entityB.x,
					entityB.y, entityB.x + entityB.w, entityB.y + entityB.h)
				
				--TODO: has to support hitbox vs. spritebox
				CollisionSystem.collisionResponseMethods[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY]
					[entityA.collisionType](entityA, entityB.collisionType, mtvX*-1, mtvY*-1)
				CollisionSystem.collisionResponseMethods[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY]
					[entityB.collisionType](entityB, entityA.collisionType, mtvX, mtvY)
			end
		end,
		
		[CollisionSystem.ENTITY_TYPES.GENERIC_WALL] = function(entityA, entityB)
			
			if CollisionSystem.collisionMethods:rectToRectDetection(entityA.x, entityA.y, 
				entityA.x + entityA.w, entityA.y + entityA.h, entityB.x, entityB.y,
				entityB.x + entityB.w, entityB.y + entityB.h) then
				
				local mtvX, mtvY = CollisionSystem.collisionMethods:rectToRectResolution(
					entityA.x, entityA.y, entityA.x + entityA.w, entityA.y + entityA.h, entityB.x, entityB.y,
					entityB.x + entityB.w, entityB.y + entityB.h)
				
				CollisionSystem.collisionResponseMethods[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY]
					[entityA.collisionType](entityA, CollisionSystem.COLLISION_RESPONSE_TYPES.FIXED, mtvX*-1, mtvY*-1)
			end
		end,
		
		[CollisionSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = function(entityA, entityB)
			if CollisionSystem.collisionMethods:pointToRectDetection(entityB.x, entityB.y, entityA.x, 
				entityA.y, entityA.x + entityA.w, entityA.y + entityA.h) then
				
				CollisionSystem.collisionResponseMethods[CollisionSystem.ENTITY_TYPES.GENERIC_PROJECTILE](entityA, 
					entityB)
			end
		end
	},
	
	[CollisionSystem.ENTITY_TYPES.GENERIC_WALL] = {
		[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(entityA, entityB)
			CollisionSystem.collisionDetectionMethods[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY]
			[CollisionSystem.ENTITY_TYPES.GENERIC_WALL](entityB, entityA)
		end,
		
		[CollisionSystem.ENTITY_TYPES.GENERIC_WALL] = function(entityA, entityB)
			
		end,
		
		[CollisionSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = function(entityA, entityB)
			CollisionSystem.collisionDetectionMethods[CollisionSystem.ENTITY_TYPES.GENERIC_PROJECTILE]
			[CollisionSystem.ENTITY_TYPES.GENERIC_WALL](entityB, entityA)
		end
	},
	
	[CollisionSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = {
		[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(entityA, entityB)
			CollisionSystem.collisionDetectionMethods[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY]
			[CollisionSystem.ENTITY_TYPES.GENERIC_PROJECTILE](entityB, entityA)
		end,
		
		[CollisionSystem.ENTITY_TYPES.GENERIC_WALL] = function(entityA, entityB)
			--deprecated entity type
		end,
	}
}

CollisionSystem.collisionResponseMethods = {
	
	[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY] = {
		[CollisionSystem.COLLISION_RESPONSE_TYPES.PUSH] = function(entity, pairCollisionType, mtvX, mtvY)
			
			if pairCollisionType == CollisionSystem.COLLISION_RESPONSE_TYPES.PUSH then
				mtvX, mtvY = math.ceil(mtvX*0.5), math.ceil(mtvY*0.5)
			end
			
			local spriteBoxRow = entity.componentTable.spritebox
			
			entity.x = entity.x + mtvX
			entity.y = entity.y + mtvY
			
			spriteBoxRow.x = spriteBoxRow.x + mtvX
			spriteBoxRow.y = spriteBoxRow.y + mtvY
			
			--scholars argue that it is profitable to spatially reindex the entity here, but I don't agree
		end,
		
		[CollisionSystem.COLLISION_RESPONSE_TYPES.FIXED] = function(entity, pairCollisionType, mtvX, mtvY)
			--do nothing
		end,
		
		[CollisionSystem.COLLISION_RESPONSE_TYPES.NONE] = function(entity, pairCollisionType, mtvX, mtvY)
			--do nothing
		end,
	},
	
	[CollisionSystem.ENTITY_TYPES.GENERIC_WALL] = {
		
	},
	
	[CollisionSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = function(entity, projectile)
		--entity got hit by projectile, alert the presses:
		local projectileSystemRequest = CollisionSystem.projectileRequestPool:getCurrentAvailableObject()
		projectileSystemRequest.requestType = CollisionSystem.PROJECTILE_REQUEST.END_PROJECTILE
		projectileSystemRequest.projectileObject = projectile.self
		projectileSystemRequest.entityObject = entity
		projectileSystemRequest.destructionType = CollisionSystem:getRequestDestructionType(entity)
		CollisionSystem.eventDispatcher:postEvent(3, 1, projectileSystemRequest)
		CollisionSystem.projectileRequestPool:incrementCurrentIndex()
	end
}

function CollisionSystem:getRequestDestructionType(entity)
	if entity.componentTable.actionState then
		return self.PROJECTILE_DESTRUCTION_TYPE.ENTITY_COLLISION
	else
		return self.PROJECTILE_DESTRUCTION_TYPE.WALL_COLLISION
	end
end

function CollisionSystem:setDefaultTableValues(requestTable)
	local defaultTable = function() return nil end
	local mt = {__index = function (requestTable) return requestTable.___ end}
	requestTable.___ = defaultTable
	setmetatable(requestTable, mt)
end

CollisionSystem:setDefaultTableValues(CollisionSystem.collisionDetectionMethods)
CollisionSystem:setDefaultTableValues(CollisionSystem.collisionDetectionMethods[CollisionSystem.ENTITY_TYPES.GENERIC_ENTITY])
CollisionSystem:setDefaultTableValues(CollisionSystem.collisionDetectionMethods[CollisionSystem.ENTITY_TYPES.GENERIC_PROJECTILE])
CollisionSystem:setDefaultTableValues(CollisionSystem.collisionResponseMethods)

return CollisionSystem