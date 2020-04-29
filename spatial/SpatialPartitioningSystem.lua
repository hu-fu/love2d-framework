-------------------------------------
--Spatial Partitioning System Module:
-------------------------------------

--[[
FILE MAP (CTRL+F):
	spatialQueryMethods
	registerSpatialEntityOnEntityMethods
	getEntityListFromEntityTypeMethods
	getSpriteboxFromSpatialEntityMethods
	defaultRegisterSpatialEntityMethods
	defaultUnregisterSpatialEntityMethods
	defaultUpdatePositionMethods
	defaultGetCollisionPairsInAreaMethods
	getNearestEntityByAreaAndRole
	getDistanceToPointMethods
	getEntityQuadMethods
	getAllEntitiesInArea
]]

local SpatialPartitioningSystem = {}

---------------
--Dependencies:
---------------

require '/spatial/SpatialGrid'
require '/spatial/SpatialPartitioningObjects'
require '/spatial/SpatialPartitioningQuery'

SpatialPartitioningSystem.collisionMethods = require '/collision/CollisionMethods'
SpatialPartitioningSystem.COLLISION_RESPONSE_TYPES = require '/collision/COLLISION_RESPONSE_TYPE'

SpatialPartitioningSystem.ENTITY_TYPES = require '/entity/ENTITY_TYPE'
SpatialPartitioningSystem.ENTITY_ROLES = require '/entity/ENTITY_ROLE'
SpatialPartitioningSystem.QUERY_TYPE = require '/spatial/SPATIAL_QUERY'
SpatialPartitioningSystem.EVENT_OBJECT = require '/event/EVENT_OBJECT'

local SYSTEM_ID = require '/system/SYSTEM_ID'

-------------------
--Static Variables:
-------------------

-------------------
--System Variables:
-------------------

SpatialPartitioningSystem.id = SYSTEM_ID.SPATIAL_PARTITIONING

SpatialPartitioningSystem.area = area

SpatialPartitioningSystem.eventDispatcher = nil
SpatialPartitioningSystem.eventListenerList = {}

SpatialPartitioningSystem.spatialQueryStack = {}

----------------
--Event Methods:
----------------

SpatialPartitioningSystem.eventMethods = {
	
	[1] = {
		[1] = function(spatialRequest)
			--add query to query stack
			table.insert(SpatialPartitioningSystem.spatialQueryStack, spatialRequest.spatialQuery)
		end,
		
		[2] = function(request)
			--set area
			SpatialPartitioningSystem:setArea(request.area)
		end,
		
		[3] = function(request)
			--set entityDb
			SpatialPartitioningSystem:registerEntityDb(request.entityDb)
		end
	}
}

---------------
--Init Methods:
---------------

function SpatialPartitioningSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function SpatialPartitioningSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function SpatialPartitioningSystem:init()
	
end

---------------
--Exec Methods:
---------------

function SpatialPartitioningSystem:setArea(area)
	self:clearArea()
	local areaSpatialObject = self:createAreaSpatialObject(area)
	self.area = areaSpatialObject
end

function SpatialPartitioningSystem:createAreaSpatialObject(area)
	local areaSpatialInfo = area.spatial
	local areaSpatialObject = AreaSpatialEntity.new(area.main.id, nil)
	self:resetAreaCurrentEntityId(areaSpatialObject)
	
	local grid = SpatialGrid.new(areaSpatialInfo.minimumNodeWidth, areaSpatialInfo.minimumNodeHeight, 
		areaSpatialInfo.nodeSizeMultiplier)
	areaSpatialObject.grid = grid
	areaSpatialObject.grid:buildGrid(areaSpatialInfo.w, areaSpatialInfo.h)
	areaSpatialObject.grid:createSpatialEntityTables(self.ENTITY_ROLES)
	
	return areaSpatialObject
end

function SpatialPartitioningSystem:clearArea()
	self.area = nil
end

function SpatialPartitioningSystem:resetAreaCurrentEntityId(areaSpatialObject)
	areaSpatialObject.currentEntityId = 0
end

function SpatialPartitioningSystem:createSpatialEntity()
	local entityRole = self.ENTITY_ROLES.UNDEFINED		--BUG: crash @start if this isn't nil. WHY???
	local entityType = self.ENTITY_TYPES.UNDEFINED		--BUG: crash @start if this isn't nil. WHY???
	local spatialLevel = -1
	local spatialIndexX, spatialIndexY = -1, -1
	local xOverlap = false
	local yOverlap = false
	local id = 0
	
	local spatialEntityObject = SpatialEntity.new(id, nil, entityRole, entityType, spatialLevel, 
		spatialIndexX, spatialIndexY, xOverlap, yOverlap)
	
	return spatialEntityObject
end

function SpatialPartitioningSystem:updateSpatialEntity(entity, spatialIndexX, spatialIndexY, 
	xOverlap, yOverlap)
	entity.spatialIndexX = spatialIndexX
	entity.spatialIndexY = spatialIndexY
	entity.xOverlap = xOverlap
	entity.yOverlap = yOverlap
end

function SpatialPartitioningSystem:resetSpatialEntity(spatialEntity)
	spatialEntity.entityRole = self.ENTITY_ROLES.UNDEFINED
	spatialEntity.entityType = self.ENTITY_TYPES.UNDEFINED
	spatialEntity.spatialLevel = -1
	spatialEntity.spatialIndexX = -1
	spatialEntity.spatialIndexY = -1
	spatialEntity.xOverlap = false
	spatialEntity.yOverlap = false
end

function SpatialPartitioningSystem:registerEntityDb(entityDb)
	for entityType, list in pairs(entityDb.globalTables) do
		for i=1, #list do
			local entity = list[i]
			local spatialEntity = self:createSpatialEntity()
			self:registerSpatialEntityOnEntity(entity, entityType, spatialEntity)
			spatialEntity.id = self.area:getCurrentEntityId()
			
			self.defaultRegisterSpatialEntityMethods[entityType]
				[entity.components.scene.role](spatialEntity, self.area.grid, entity.components.scene.role)
		end
	end
end

function SpatialPartitioningSystem:entityToRole(entityType, entity)
	--we can set default role transformations here. I'd rather not but we could
	return entity.componentTable.scene.role
end

function SpatialPartitioningSystem:runQueries()
	for i=#self.spatialQueryStack, 1, -1 do
		local results = self.spatialQueryMethods[self.spatialQueryStack[i].queryType](self.spatialQueryStack[i])
		self.spatialQueryStack[i].responseCallback(self, self.spatialQueryStack[i], results)
		table.remove(self.spatialQueryStack)
	end
end

function SpatialPartitioningSystem:getSpatialEntityByEntityId(entityType, id)
	for i=1, #list do
		--spatialQueryMethods[SpatialPartitioningSystem.QUERY_TYPE.REINDEX_ENTITY]
		--...
	end
end

----------------
--Query methods:
----------------

function SpatialPartitioningSystem:registerSpatialEntityOnEntity(entity, entityType, spatialEntity)
	self.registerSpatialEntityOnEntityMethods[entityType](entity, spatialEntity)
end

function SpatialPartitioningSystem:getEntityListFromEntityDatabase(entityDatabase)
	return self.getEntityListFromEntityTypeMethods[entityDatabase.entityType](entityDatabase)
end

function SpatialPartitioningSystem:getSpriteboxFromSpatialEntity(spatialEntity)
	--use with an area query to get all the objects on screen, and send them to the renderer
	--get hitboxes on area -> transform into spritebox -> send to renderer
	return spatialEntity.parentEntity.componentTable.spritebox
end

function SpatialPartitioningSystem:registerSpatialEntity(entityType, spatialEntity, grid, entityRole)
	self.defaultRegisterSpatialEntityMethods[entityType][entityRole](spatialEntity, grid, entityRole)
end

function SpatialPartitioningSystem:unregisterSpatialEntity(entityType, entityRole, entity, grid)
	self.defaultUnregisterSpatialEntityMethods[entityType][entityRole](entity, grid)
end

function SpatialPartitioningSystem:updateEntityPosition(entityType, spatialEntity, grid)
	self.defaultUpdatePositionMethods[entityType](spatialEntity, grid)
end

function SpatialPartitioningSystem:getCollisionPairsInArea(queryType, x, y, w, h, entityRoleA, 
	entityRoleB, pairsManager)
	
	self.defaultGetCollisionPairsInAreaMethods[queryType](x, y, w, h, entityRoleA, entityRoleB, 
		pairsManager)
end

SpatialPartitioningSystem.spatialQueryMethods = {
	
	[SpatialPartitioningSystem.QUERY_TYPE.UPDATE_ENTITY] = function(spatialRequest)
		--this doesn't work, obviously. Remove pls
		SpatialPartitioningSystem.defaultUpdatePositionMethods[spatialRequest.queryType]()
		return nil
	end,
	
	[SpatialPartitioningSystem.QUERY_TYPE.GET_NEAREST_ENTITY_BY_AREA_AND_ROLE] = function(spatialRequest)
		return SpatialPartitioningSystem:getNearestEntityByAreaAndRole(SpatialPartitioningSystem.area.grid, 
			spatialRequest.x, spatialRequest.y, spatialRequest.areaX, spatialRequest.areaY, 
			spatialRequest.areaW, spatialRequest.areaH, spatialRequest.searchRadius, 
			spatialRequest.targetRoles, spatialRequest.numberOfResults)
	end,
	
	[SpatialPartitioningSystem.QUERY_TYPE.GET_COLLISION_PAIRS_IN_AREA] = function(spatialRequest)
		SpatialPartitioningSystem.defaultGetCollisionPairsInAreaMethods[spatialRequest.querySubType](
		spatialRequest.x, spatialRequest.y, spatialRequest.w, spatialRequest.h, spatialRequest.entityRoleA, 
		spatialRequest.entityRoleB, spatialRequest.pairsManager)
		return nil
	end,
	
	[SpatialPartitioningSystem.QUERY_TYPE.GET_ENTITIES_IN_AREA_FOR_RENDERING] = function(spatialRequest)
		SpatialPartitioningSystem.defaultGetEntitiesInAreaForRendering[spatialRequest.querySubType](spatialRequest)
		return nil
	end,
	
	[SpatialPartitioningSystem.QUERY_TYPE.REGISTER_ENTITY] = function(spatialRequest)
		--WARNING: DO NOT USE FOR REINDEXING SINCE IT CREATES A NEW SPATIAL ENTITY OBJECT!
			--spatialRequest.entity is a main entity, not a hitbox
		
		if self.area then
			local spatialEntity = SpatialPartitioningSystem:createSpatialEntity()
			SpatialPartitioningSystem:registerSpatialEntityOnEntity(spatialRequest.entity, spatialRequest.entityType, spatialEntity)
			spatialEntity.id = self.area:getCurrentEntityId()
			
			SpatialPartitioningSystem.defaultRegisterSpatialEntityMethods[spatialRequest.entityType]
				[spatialRequest.entityRole](spatialEntity, self.area.grid, spatialRequest.entityRole)
		end
		
		return nil
	end,
	
	[SpatialPartitioningSystem.QUERY_TYPE.GET_ENTITIES_IN_AREA_BY_ROLE_LEGACY] = function(spatialRequest)
		return SpatialPartitioningSystem:getEntitiesInAreaByRoles_legacy(SpatialPartitioningSystem.area.grid, 
			spatialRequest.roles, spatialRequest.areaX, spatialRequest.areaY, spatialRequest.areaW, 
			spatialRequest.areaH)
	end,
	
	[SpatialPartitioningSystem.QUERY_TYPE.GET_ENTITIES_IN_AREA_BY_ROLE] = function(spatialRequest)
		return SpatialPartitioningSystem:getEntitiesInAreaByRoles(SpatialPartitioningSystem.area.grid, 
			spatialRequest.hashtable, spatialRequest.roles, spatialRequest.areaX, spatialRequest.areaY,
			spatialRequest.areaW, spatialRequest.areaH)
	end,
	
	[SpatialPartitioningSystem.QUERY_TYPE.UNREGISTER_ENTITY] = function(spatialRequest)
		--spatialRequest.entity is an hitbox/spritebox or whatever has a pointer to the spatEntity
		local spatialEntity = spatialRequest.entity.spatialEntity	--may be problematic due to different entity types
		
		if spatialEntity.entityRole then
			SpatialPartitioningSystem:unregisterSpatialEntity(spatialRequest.entityType, spatialEntity.entityRole,
				spatialRequest.entity, SpatialPartitioningSystem.area.grid)
		end
		
		return nil
	end,
	
	[SpatialPartitioningSystem.QUERY_TYPE.REINDEX_ENTITY] = function(spatialRequest)
		--spatialRequest.entity is an hitbox/spritebox
		
		local spatialEntity = spatialRequest.entity.spatialEntity	--may be problematic due to different entity types
																	--get spatial entity by entity type
		
		if not spatialEntity then
			spatialEntity = SpatialPartitioningSystem:createSpatialEntity()
			SpatialPartitioningSystem:registerSpatialEntityOnEntity(spatialRequest.entity, spatialRequest.entityType, spatialEntity)
			spatialEntity.id = SpatialPartitioningSystem.area:getCurrentEntityId()
		end
		
		if spatialEntity.entityRole then
			SpatialPartitioningSystem:unregisterSpatialEntity(spatialRequest.entityType, spatialEntity.entityRole,
				spatialRequest.entity, SpatialPartitioningSystem.area.grid)
		end
		
		SpatialPartitioningSystem.defaultRegisterSpatialEntityMethods[spatialRequest.entityType]
			[spatialRequest.newRole](spatialEntity, SpatialPartitioningSystem.area.grid, spatialRequest.newRole)
	end,
}

SpatialPartitioningSystem.getEntityListFromEntityTypeMethods = {
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(entityDatabase)
		return entityDatabase:getTableRows('entityHitboxTable')
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL] = function(entityDatabase)
		return entityDatabase:getTableRows('entityHitboxTable')
	end,
}

SpatialPartitioningSystem.registerSpatialEntityOnEntityMethods = {
	[SpatialPartitioningSystem.ENTITY_TYPES.UNDEFINED] = function(entity, spatialEntity)
	
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(entity, spatialEntity)
		if entity.components then
			--for main entities:
			local hitbox = entity.components.hitbox
			local spritebox = entity.components.spritebox
			
			if hitbox then
				hitbox.spatialEntity = spatialEntity
				spatialEntity.parentEntity = hitbox
			elseif spritebox then
				spritebox.spatialEntity = spatialEntity
				spatialEntity.parentEntity = spritebox
			end
		else
			--for components:
			local hitbox = entity.componentTable.hitbox
			local spritebox = entity.componentTable.spritebox
			
			if hitbox then
				hitbox.spatialEntity = spatialEntity
				spatialEntity.parentEntity = hitbox
			elseif spritebox then
				spritebox.spatialEntity = spatialEntity
				spatialEntity.parentEntity = spritebox
			end
		end
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL] = function(entity, spatialEntity)
		SpatialPartitioningSystem.registerSpatialEntityOnEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY](entity, spatialEntity)
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = function(entity, spatialEntity)
		entity.spatialEntity = spatialEntity
		spatialEntity.parentEntity = entity
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.VISUAL_EFFECT] = function(entity, spatialEntity)
		entity.spatialEntity = spatialEntity
		spatialEntity.parentEntity = entity
	end
}

SpatialPartitioningSystem.defaultGetEntitiesInAreaForRendering = {
	
	SUBGRIDS = {1,2,3},		--change this to a system var
	
	[1] = function(spatialRequest)
		local topLeftX, topLeftY = 0, 0
		local bottomRightX, bottomRightY = 0, 0
		local subGrids = SpatialPartitioningSystem.defaultGetEntitiesInAreaForRendering.SUBGRIDS
		local entityRoles = spatialRequest.roles
		local area = SpatialPartitioningSystem.area
		
		for i=1, #subGrids do
			local subGrid = area.grid.subGrids[subGrids[i]]
			topLeftX, topLeftY = area.grid:getSubGridIndex(subGrid, spatialRequest.areaX, spatialRequest.areaY)
			bottomRightX, bottomRightY = area.grid:getSubGridIndex(subGrid, spatialRequest.areaX + spatialRequest.areaW, 
				spatialRequest.areaY + spatialRequest.areaH)
			
			for j=1, #entityRoles do
				local entityTable = subGrid.entityTables[entityRoles[j]].entityTable
				
				for k=bottomRightY, topLeftY, -1 do
					for l=topLeftX, bottomRightX do
						for m=1, #entityTable[k][l] do
							spatialRequest.spatialEntityHashtable:addEntity(entityTable[k][l][m])
						end
					end
				end
			end
		end
	end
}

SpatialPartitioningSystem.getSpriteboxFromSpatialEntityMethods = {

}

SpatialPartitioningSystem.defaultRegisterSpatialEntityMethods = {
	
	[SpatialPartitioningSystem.ENTITY_TYPES.UNDEFINED] = {
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(spatialEntity, grid, entityRole)
			
		end,
	},
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = {
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(spatialEntity, grid, entityRole)
			
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.PLAYER] = function(spatialEntity, grid, entityRole)
			local gridLevel = grid:getEntityGridLevel(spatialEntity.parentEntity.w, spatialEntity.parentEntity.h)
			local subGrid = grid.subGrids[gridLevel]
			
			local spatialIndexX, spatialIndexY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x, 
				spatialEntity.parentEntity.y)
			
			local node = subGrid.nodes[spatialIndexY][spatialIndexX]
			local xOverlap = grid:nodeRightRangeCheck(node, spatialEntity.parentEntity.x + spatialEntity.parentEntity.w)
			local yOverlap = grid:nodeBottomRangeCheck(node, spatialEntity.parentEntity.y + spatialEntity.parentEntity.h)
			
			spatialEntity.entityRole = entityRole
			spatialEntity.entityType = SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY
			spatialEntity.spatialLevel = gridLevel
			spatialEntity.spatialIndexX = spatialIndexX
			spatialEntity.spatialIndexY = spatialIndexY
			spatialEntity.xOverlap = xOverlap
			spatialEntity.yOverlap = yOverlap
			
			subGrid.entityTables[spatialEntity.entityRole]:registerEntity(spatialEntity)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.HOSTILE_NPC] = function(spatialEntity, grid, entityRole)
			SpatialPartitioningSystem.defaultRegisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY]
				[SpatialPartitioningSystem.ENTITY_ROLES.PLAYER](spatialEntity, grid, entityRole)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.OBSTACLE] = function(spatialEntity, grid, entityRole)
			local gridLevel = grid:getEntityGridLevel(1, 1) 	--lowest level (grid:getLowestGridLevel)
			local subGrid = grid.subGrids[gridLevel]
			
			local topLeftX, topLeftY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x, 
				spatialEntity.parentEntity.y)
			
			--subtract br coordinates by one so it doesn't register in adjacent nodes (may be a bad idea)
			local bottomRightX, bottomRightY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x + 
				spatialEntity.parentEntity.w - 1, spatialEntity.parentEntity.y + spatialEntity.parentEntity.h - 1)
			
			local xOverlap, yOverlap = true, true
			
			spatialEntity.entityRole = entityRole
			spatialEntity.entityType = SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL	--I just don't know
			spatialEntity.spatialLevel = gridLevel
			spatialEntity.spatialIndexX = topLeftX
			spatialEntity.spatialIndexY = topLeftY
			spatialEntity.xOverlap = xOverlap
			spatialEntity.yOverlap = yOverlap
			
			--if collision type diagonal, set m and b:
			if spatialEntity.parentEntity.collisionType == 
				SpatialPartitioningSystem.COLLISION_RESPONSE_TYPES.HALF_TOP_LEFT or 
				spatialEntity.parentEntity.collisionType == 
				SpatialPartitioningSystem.COLLISION_RESPONSE_TYPES.HALF_BOTTOM_RIGHT 
				then
				
				spatialEntity.parentEntity.m = 
					SpatialPartitioningSystem.collisionMethods:getLineSlope(spatialEntity.parentEntity.x, 
						(spatialEntity.parentEntity.y + spatialEntity.parentEntity.h), 
						(spatialEntity.parentEntity.x + spatialEntity.parentEntity.w),
						spatialEntity.parentEntity.y)
				spatialEntity.parentEntity.b = 
					SpatialPartitioningSystem.collisionMethods:getLineLineYIntercept(spatialEntity.parentEntity.m, 
						(spatialEntity.parentEntity.x + spatialEntity.parentEntity.w), 
						spatialEntity.parentEntity.y)
				
			elseif spatialEntity.parentEntity.collisionType == 
				SpatialPartitioningSystem.COLLISION_RESPONSE_TYPES.HALF_BOTTOM_LEFT or 
				spatialEntity.parentEntity.collisionType == 
				SpatialPartitioningSystem.COLLISION_RESPONSE_TYPES.HALF_TOP_RIGHT then
				
				spatialEntity.parentEntity.m = 
					SpatialPartitioningSystem.collisionMethods:getLineSlope(spatialEntity.parentEntity.x, 
						spatialEntity.parentEntity.y, (spatialEntity.parentEntity.x + spatialEntity.parentEntity.w),
						(spatialEntity.parentEntity.y + spatialEntity.parentEntity.h))
				spatialEntity.parentEntity.b = 
					SpatialPartitioningSystem.collisionMethods:getLineLineYIntercept(spatialEntity.parentEntity.m, 
						spatialEntity.parentEntity.x, spatialEntity.parentEntity.y)
			end
			
			subGrid.entityTables[spatialEntity.entityRole]:registerEntityInArea(spatialEntity, topLeftX, topLeftY, 
				bottomRightX, bottomRightY)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.BACKGROUND_OBJECT] = function(spatialEntity, grid, entityRole)
			local gridLevel = grid:getEntityGridLevel(1, 1) 	--lowest level (grid:getLowestGridLevel)
			local subGrid = grid.subGrids[gridLevel]
			
			local topLeftX, topLeftY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x, 
				spatialEntity.parentEntity.y)
			
			--subtract br coordinates by one so it doesn't register in adjacent nodes (may be a bad idea)
			local bottomRightX, bottomRightY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x + 
				spatialEntity.parentEntity.w - 1, spatialEntity.parentEntity.y + spatialEntity.parentEntity.h - 1)
			
			local xOverlap, yOverlap = true, true
			
			spatialEntity.entityRole = entityRole
			spatialEntity.entityType = SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY
			spatialEntity.spatialLevel = gridLevel
			spatialEntity.spatialIndexX = topLeftX
			spatialEntity.spatialIndexY = topLeftY
			spatialEntity.xOverlap = xOverlap
			spatialEntity.yOverlap = yOverlap
			
			subGrid.entityTables[spatialEntity.entityRole]:registerEntityInArea(spatialEntity, topLeftX, topLeftY, 
				bottomRightX, bottomRightY)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.FOREGROUND_OBJECT] = function(spatialEntity, grid, entityRole)
			SpatialPartitioningSystem.defaultRegisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY]
				[SpatialPartitioningSystem.ENTITY_ROLES.BACKGROUND_OBJECT](spatialEntity, grid, entityRole)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.ENTITY_EVENT] = function(spatialEntity, grid, entityRole)
			SpatialPartitioningSystem.defaultRegisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY]
				[SpatialPartitioningSystem.ENTITY_ROLES.BACKGROUND_OBJECT](spatialEntity, grid, entityRole)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.ITEM] = function(spatialEntity, grid, entityRole)
			SpatialPartitioningSystem.defaultRegisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY]
				[SpatialPartitioningSystem.ENTITY_ROLES.PLAYER](spatialEntity, grid, entityRole)
		end
	},
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL] = {
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(spatialEntity, grid, entityRole)
			
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.OBSTACLE] = function(spatialEntity, grid, entityRole)
			
		end
	},
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = {
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(spatialEntity, grid, entityRole)
			
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.FRIEND_PROJECTILE] = function(spatialEntity, grid, entityRole)
			SpatialPartitioningSystem.defaultRegisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE]
				[SpatialPartitioningSystem.ENTITY_ROLES.HOSTILE_PROJECTILE](spatialEntity, grid, entityRole)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.HOSTILE_PROJECTILE] = function(spatialEntity, grid, entityRole)
			local gridLevel = grid:getEntityGridLevel(spatialEntity.parentEntity.w, 
				spatialEntity.parentEntity.h)
			local subGrid = grid.subGrids[gridLevel]
			
			local spatialIndexX, spatialIndexY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x, 
				spatialEntity.parentEntity.y)
			
			local node = subGrid.nodes[spatialIndexY][spatialIndexX]
			
			spatialEntity.entityRole = entityRole
			spatialEntity.entityType = SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE
			spatialEntity.spatialLevel = gridLevel
			spatialEntity.spatialIndexX = spatialIndexX
			spatialEntity.spatialIndexY = spatialIndexY
			
			subGrid.entityTables[spatialEntity.entityRole]:registerEntity(spatialEntity)
		end,
	},
	
	[SpatialPartitioningSystem.ENTITY_TYPES.VISUAL_EFFECT] = {
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(spatialEntity, grid, entityRole)
			
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.VISUAL_EFFECT] = function(spatialEntity, grid, entityRole)
			SpatialPartitioningSystem.defaultRegisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY]
				[SpatialPartitioningSystem.ENTITY_ROLES.PLAYER](spatialEntity, grid, entityRole)
		end,
	}
}

SpatialPartitioningSystem.defaultUnregisterSpatialEntityMethods = {
	[SpatialPartitioningSystem.ENTITY_TYPES.UNDEFINED] = {
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(entity, grid)
		
		end,
	},
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = {
		[SpatialPartitioningSystem.ENTITY_ROLES.PLAYER] = function(entity, grid)
			local spatialEntity = entity.spatialEntity
			
			local subGrid = grid.subGrids[spatialEntity.spatialLevel]
			
			local topLeftX, topLeftY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x, 
				spatialEntity.parentEntity.y)
			local bottomRightX, bottomRightY = grid:getSubGridIndex(subGrid, 
				spatialEntity.parentEntity.x + spatialEntity.parentEntity.w, 
				spatialEntity.parentEntity.y + spatialEntity.parentEntity.h)
			
			subGrid.entityTables[spatialEntity.entityRole]:unregisterEntityInArea(spatialEntity, topLeftX,
				topLeftY, bottomRightX, bottomRightY)
			
			SpatialPartitioningSystem:resetSpatialEntity(entity.spatialEntity)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.HOSTILE_NPC] = function(entity, grid)
			SpatialPartitioningSystem.defaultUnregisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY]
				[SpatialPartitioningSystem.ENTITY_ROLES.PLAYER](entity, grid)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.ITEM] = function(entity, grid)
			SpatialPartitioningSystem.defaultUnregisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY]
				[SpatialPartitioningSystem.ENTITY_ROLES.PLAYER](entity, grid)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(entity, grid)
		
		end,
	},
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL] = {
		[SpatialPartitioningSystem.ENTITY_ROLES.OBSTACLE] = function(entity, grid)
			SpatialPartitioningSystem.defaultUnregisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY]
				[SpatialPartitioningSystem.ENTITY_ROLES.PLAYER](entity, grid)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(entity, grid)
		
		end,
	},
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = {
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(entity, grid)
			
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.FRIEND_PROJECTILE] = function(entity, grid)
			SpatialPartitioningSystem.defaultUnregisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE]
				[SpatialPartitioningSystem.ENTITY_ROLES.HOSTILE_PROJECTILE](entity, grid)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.HOSTILE_PROJECTILE] = function(entity, grid)
			local spatialEntity = entity.spatialEntity
			
			local subGrid = grid.subGrids[spatialEntity.spatialLevel]
			
			subGrid.entityTables[spatialEntity.entityRole]:unregisterEntity(spatialEntity)
			
			SpatialPartitioningSystem:resetSpatialEntity(spatialEntity)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(entity, grid)
		
		end,
	},
	
	[SpatialPartitioningSystem.ENTITY_TYPES.VISUAL_EFFECT] = {
		[SpatialPartitioningSystem.ENTITY_ROLES.VISUAL_EFFECT] = function(entity, grid)
			SpatialPartitioningSystem.defaultUnregisterSpatialEntityMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY]
				[SpatialPartitioningSystem.ENTITY_ROLES.PLAYER](entity, grid)
		end,
		
		[SpatialPartitioningSystem.ENTITY_ROLES.UNDEFINED] = function(entity, grid)
		
		end,
	}
}

SpatialPartitioningSystem.defaultUpdatePositionMethods = {
	[SpatialPartitioningSystem.ENTITY_TYPES.UNDEFINED] = function(spatialEntity, grid)
	
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(spatialEntity, grid)
		
		local subGrid = grid.subGrids[spatialEntity.spatialLevel]
		
		local currentIndexX , currentIndexY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x, 
			spatialEntity.parentEntity.y)
		
		local node = subGrid.nodes[currentIndexY][currentIndexX]
		
		local currentXOverlap = grid:nodeRightRangeCheck(node, spatialEntity.parentEntity.x + 
			spatialEntity.parentEntity.w)
		local currentYOverlap = grid:nodeBottomRangeCheck(node, spatialEntity.parentEntity.y + 
			spatialEntity.parentEntity.h)
		
		local changeHorizontal = currentIndexX - spatialEntity.spatialIndexX
		local changeVertical = currentIndexY - spatialEntity.spatialIndexY
		
		--needs optimization (also - move this to another file):
			--it's as optimized as it will ever be // leave it here
			
		if changeHorizontal ~= 0 then
			
			if changeVertical ~= 0 then
				subGrid.entityTables[spatialEntity.entityRole]:unregisterEntity(spatialEntity)
				SpatialPartitioningSystem:updateSpatialEntity(spatialEntity, currentIndexX, 
					currentIndexY, currentXOverlap, currentYOverlap)
				subGrid.entityTables[spatialEntity.entityRole]:registerEntity(spatialEntity)
			else
			
				if changeHorizontal == 1 then
					subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX, 
						spatialEntity.spatialIndexY, spatialEntity)
					
					if spatialEntity.yOverlap then
						subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX, 
							spatialEntity.spatialIndexY + 1, spatialEntity)
						
						if spatialEntity.xOverlap then
							if currentYOverlap == false then
								subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(currentIndexX, 
									currentIndexY + 1, spatialEntity)
							end
						end
					end
					
					if spatialEntity.xOverlap == false then
						subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX, currentIndexY, 
							spatialEntity)
					end
					
					if currentYOverlap and currentXOverlap then
						subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX + 1, 
							currentIndexY + 1, spatialEntity)
					end
					
					if spatialEntity.yOverlap == false or spatialEntity.xOverlap == false then
						if currentYOverlap then
							subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX, 
								currentIndexY + 1, spatialEntity)
						end
					end
					
				elseif changeHorizontal == -1 then
					subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX, currentIndexY, 
						spatialEntity)
					
					if spatialEntity.xOverlap then
						subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX + 1, 
							spatialEntity.spatialIndexY, spatialEntity)
						
						if spatialEntity.yOverlap then
							subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX + 1, 
								spatialEntity.spatialIndexY + 1, spatialEntity)
						end
					end
					
					if spatialEntity.yOverlap == true then
						if currentXOverlap == false or currentYOverlap == false then
							subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX, 
								spatialEntity.spatialIndexY + 1, spatialEntity)
						end
					end
					
					if currentYOverlap then
						subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX, currentIndexY + 1, 
							spatialEntity)
					
						if currentXOverlap then
							if spatialEntity.yOverlap == false then
								subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX + 1, 
									currentIndexY + 1, spatialEntity)
							end
						end
					else
						if spatialEntity.yOverlap then
							subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX, 
								spatialEntity.spatialIndexY + 1, spatialEntity)
						end
					end
					
					if currentXOverlap == false then
						subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX, 
							spatialEntity.spatialIndexY, spatialEntity)
					end
				else
					subGrid.entityTables[spatialEntity.entityRole]:unregisterEntity(spatialEntity)
					SpatialPartitioningSystem:updateSpatialEntity(spatialEntity, currentIndexX, 
						currentIndexY, currentXOverlap, currentYOverlap)
					subGrid.entityTables[spatialEntity.entityRole]:registerEntity(spatialEntity)
				end
				
			end
			
		elseif changeVertical ~= 0 then
			
			if changeVertical == 1 then
				
				subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX, 
						spatialEntity.spatialIndexY, spatialEntity)
				
				if spatialEntity.xOverlap then
					subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX + 1, 
						spatialEntity.spatialIndexY, spatialEntity)
					
					if spatialEntity.yOverlap then
						if currentXOverlap == false then
							subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX + 1, 
								spatialEntity.spatialIndexY + 1, spatialEntity)
						end
					end
				end
				
				if spatialEntity.yOverlap == false then
					subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX, 
						currentIndexY, spatialEntity)
				end
				
				if currentXOverlap then
					if currentYOverlap then
						subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX + 1, 
							currentIndexY + 1, spatialEntity)
					end
					
					if spatialEntity.xOverlap == false or spatialEntity.yOverlap == false then
						subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX + 1, 
							currentIndexY, spatialEntity)
					end
				end
				
				if currentYOverlap then
					subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX, 
						currentIndexY + 1, spatialEntity)
				end
				
			elseif changeVertical == -1 then
				
				subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX, currentIndexY, 
					spatialEntity)
				
				if spatialEntity.xOverlap then
					if spatialEntity.yOverlap then
						subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX + 1, 
							spatialEntity.spatialIndexY + 1, spatialEntity)
					end
					
					if currentXOverlap == false or currentYOverlap == false then
						subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX + 1, 
							spatialEntity.spatialIndexY, spatialEntity)
					end
				end
				
				if spatialEntity.yOverlap then
					subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX, 
							spatialEntity.spatialIndexY + 1, spatialEntity)
				end
				
				if currentYOverlap == false then
					subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX, 
						spatialEntity.spatialIndexY, spatialEntity)
				end
				
				if currentXOverlap then
					subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX + 1, currentIndexY, 
						spatialEntity)
					
					if currentYOverlap then
						if spatialEntity.xOverlap == false then
							subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX + 1, currentIndexY + 1, 
								spatialEntity)
						end
					end
				end
				
			else
				subGrid.entityTables[spatialEntity.entityRole]:unregisterEntity(spatialEntity)
				SpatialPartitioningSystem:updateSpatialEntity(spatialEntity, currentIndexX, 
					currentIndexY, currentXOverlap, currentYOverlap)
				subGrid.entityTables[spatialEntity.entityRole]:registerEntity(spatialEntity)
			end
			
		elseif currentXOverlap ~= spatialEntity.xOverlap then
			
			if currentYOverlap ~= spatialEntity.yOverlap then
				subGrid.entityTables[spatialEntity.entityRole]:unregisterEntity(spatialEntity)
				SpatialPartitioningSystem:updateSpatialEntity(spatialEntity, currentIndexX, 
					currentIndexY, currentXOverlap, currentYOverlap)
				subGrid.entityTables[spatialEntity.entityRole]:registerEntity(spatialEntity)
				
			else
			
				if currentXOverlap == true then
					subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX + 1, 
						currentIndexY, spatialEntity)
						
					if currentYOverlap == true then
						subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX + 1, 
							currentIndexY + 1, spatialEntity)
					end
						
				else
					subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(currentIndexX + 1, 
						currentIndexY, spatialEntity)
						
					if currentYOverlap == true then
						subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(currentIndexX + 1, 
							currentIndexY + 1, spatialEntity)
					end
				end
			
			end
			
		elseif currentYOverlap ~= spatialEntity.yOverlap then
			
			if currentYOverlap == true then
				subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX, 
					currentIndexY + 1, spatialEntity)
				
				if currentXOverlap == true then
					subGrid.entityTables[spatialEntity.entityRole]:addEntityToTable(currentIndexX + 1, 
						currentIndexY + 1, spatialEntity)
				end
			else
				subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(currentIndexX, 
					currentIndexY + 1, spatialEntity)
				
				if currentXOverlap == true then
					subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(currentIndexX + 1, 
						currentIndexY + 1, spatialEntity)
				end
			end
			
		else
			--do nothing
		end
		
		SpatialPartitioningSystem:updateSpatialEntity(spatialEntity, currentIndexX, 
			currentIndexY, currentXOverlap, currentYOverlap)
		
		--fail safe removal -> 100 iterations @ 53fps avg (moving), 0.015% time (anonymous func)
		--this -> 200 iterations at 58fps avg
		
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL] = function(spatialEntity, grid)
		SpatialPartitioningSystem.defaultUpdatePositionMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY](spatialEntity, grid)
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = function(spatialEntity, grid)
		local subGrid = grid.subGrids[spatialEntity.spatialLevel]
		
		local currentIndexX , currentIndexY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x, 
			spatialEntity.parentEntity.y)
		
		if currentIndexX ~= spatialEntity.spatialIndexX or 
			currentIndexY ~= spatialEntity.spatialIndexY then
			
			subGrid.entityTables[spatialEntity.entityRole]:removeEntityFromTable(spatialEntity.spatialIndexX, spatialEntity.spatialIndexY, spatialEntity)
			
			spatialEntity.spatialIndexX = currentIndexX
			spatialEntity.spatialIndexY = currentIndexY
			
			subGrid.entityTables[spatialEntity.entityRole]:registerEntity(spatialEntity)
		end
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.VISUAL_EFFECT] = function(spatialEntity, grid)
		SpatialPartitioningSystem.defaultUpdatePositionMethods[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY](spatialEntity, grid)
	end
}

SpatialPartitioningSystem.defaultGetCollisionPairsInAreaMethods = {
	
	[1] = function(x, y, w, h, entityRoleA, entityRoleB, pairsManager)
		--DEBUG; tries to get all pairs; unnoptimized;
		
		local grid = SpatialPartitioningSystem.area.grid
		local subGrid, subGridB = nil, nil
		local entityTableA, entityTableB = nil, nil
		local topLeftX, topLeftY = 0
		local bottomRightX, bottomRightY = 0
		local indexXB, indexYB = 0, 0
		
		for i=1, #grid.subGrids do
		
			subGrid = grid.subGrids[i]
			entityTableA = subGrid.entityTables[entityRoleA].entityTable
			
			topLeftX, topLeftY = grid:getSubGridIndex(subGrid, x, y)
			bottomRightX, bottomRightY = grid:getSubGridIndex(subGrid, x + w, y + h)
			
			for j=topLeftY, bottomRightY do
				for k=topLeftX, bottomRightX do
					
					for l=1, #entityTableA[j][k] do
						
						indexXB, indexYB = k, j
						
						for n=1, #grid.subGrids do
							
							subGridB = grid.subGrids[n]
							
							entityTableB = subGridB.entityTables[entityRoleB].entityTable
							
							for m=1, #entityTableB[indexYB][indexXB] do
								
								pairsManager:insertPairIntoPairsTable(entityTableA[j][k][l].id,
									entityTableB[indexYB][indexXB][m].id, entityTableA[j][k][l],
									entityTableB[indexYB][indexXB][m])
								
							end
							
							indexXB, indexYB = grid:getNextSubGridIndex(indexXB, indexYB)
						end
					end
				end
			end
		end
	end
	
	--...
}

function SpatialPartitioningSystem:getNearestEntityByAreaAndRole(grid, x, y, areaX, areaY, areaW, areaH, 
	searchRadius, targetRoles, numberOfResults)
	--can (and should) be optimised - this one covers all situations, looks really ugly but does the job
	--we can use a different type of algorithm (like checking for obstacles with ray tracing, etc)
	--possible problem(?) the profiler is acting weird - solved I think
	
	local searchRadiusSq = searchRadius^2
	
	local results = {}
	local distances = {}
	
	for h=1, numberOfResults do
		results[h] = false
		distances[h] = searchRadiusSq
	end
	
	local subGrid = nil
	local entityTable = nil
	local topLeftX, topLeftY, bottomRightX, bottomRightY = 0
	local entityX, entityY, entityW, entityH = 0, 0, 0, 0
	local entityDistance = 0
	local resultIndex = 0
	
	for i=1, #grid.subGrids do
		subGrid = grid.subGrids[i]
		
		topLeftX, topLeftY = grid:getSubGridIndex(subGrid, areaX, areaY)
		bottomRightX, bottomRightY = grid:getSubGridIndex(subGrid, areaX + areaW, areaY + areaH)
		
		for j=1, #targetRoles do
			entityTable = subGrid.entityTables[targetRoles[j]].entityTable
			
			for k=topLeftY, bottomRightY do
				for l=topLeftX, bottomRightX do
					for m=1, #entityTable[k][l] do
						
						resultIndex = 0
						
						entityDistance = SpatialPartitioningSystem.getDistanceToPointMethods
							[entityTable[k][l][m].entityType](x, y, entityTable[k][l][m])
						
						for n=#distances, 1, -1 do
							if entityDistance < distances[n] then
								resultIndex = n
							else
								break
							end
						end
						
						for o=1, #results do
							if entityTable[k][l][m] == results[o] then
								resultIndex = 0
							end
						end
						
						if resultIndex > 0 then
							entityX, entityY, entityW, entityH = self.getEntityQuadMethods[entityTable[k][l][m].entityType](entityTable[k][l][m])
							
							if SpatialPartitioningSystem.collisionMethods:rectToRectDetection(areaX, areaY, areaX + areaW, 
								areaY + areaH, entityX, entityY, entityX + entityW, entityY + entityH) then
								
								table.insert(results, resultIndex, entityTable[k][l][m])
								table.insert(distances, resultIndex, entityDistance)
								table.remove(results)
								table.remove(distances)
							end
						end
						
					end
				end
			end
		end
	end

	for i=#results, 1, -1 do
		if results[i] == false then
			table.remove(results)
		end
	end
	
	for i=1, #distances do
		--debugger.debugStrings[1] = debugger.debugStrings[1] .. distances[i] .. ' '
	end
	
	return results
end

function SpatialPartitioningSystem:getEntitiesInAreaByRoles_legacy(grid, roles, x, y, w, h)
	local results = {}
	
	local subGrid = nil
	local entityTable = nil
	local topLeftX, topLeftY, bottomRightX, bottomRightY = 0
	local entityX, entityY, entityW, entityH = 0, 0, 0, 0
	local added = false
	
	for i=1, #grid.subGrids do
		subGrid = grid.subGrids[i]
		
		topLeftX, topLeftY = grid:getSubGridIndex(subGrid, x, y)
		bottomRightX, bottomRightY = grid:getSubGridIndex(subGrid, x + w, y + h)
		
		for j=1, #roles do
			entityTable = subGrid.entityTables[roles[j]].entityTable
			
			for k=topLeftY, bottomRightY do
				for l=topLeftX, bottomRightX do
					for m=1, #entityTable[k][l] do
						
						if self.areaCollisionCheckMethods[entityTable[k][l][m].entityType](
							entityTable[k][l][m].parentEntity, x, y, w, h) then
							
							added = false
							
							for n=1, #results do
								if entityTable[k][l][m].parentEntity == results[n] then
									added = true
									break
								end
							end
							
							if not added then
								table.insert(results, entityTable[k][l][m].parentEntity)
							end
						end
						
					end
				end
			end
		end
	end
	
	return results
end

function SpatialPartitioningSystem:getEntitiesInAreaByRoles(grid, hashtable, roles, areaX, areaY, areaW, areaH)
	local topLeftX, topLeftY = 0, 0
	local bottomRightX, bottomRightY = 0, 0
	local subGrids = 3	--this has to go
	local entityRoles = roles
	local area = SpatialPartitioningSystem.area
	
	for i=1, subGrids do
		local subGrid = area.grid.subGrids[i]
		topLeftX, topLeftY = area.grid:getSubGridIndex(subGrid, areaX, areaY)
		bottomRightX, bottomRightY = area.grid:getSubGridIndex(subGrid, areaX + areaW, areaY + areaH)
			
		for j=1, #entityRoles do
			local entityTable = subGrid.entityTables[entityRoles[j]].entityTable
			
			for k=topLeftY, bottomRightY do
				for l=topLeftX, bottomRightX do
					for m=1, #entityTable[k][l] do
						hashtable:addEntity(entityTable[k][l][m])
					end
				end
			end
		end
	end
	
	return hashtable
end

SpatialPartitioningSystem.areaCollisionCheckMethods = {
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(parentEntity, areaX, areaY,
		areaW, areaH)
		if parentEntity.y + parentEntity.h <= areaY then
			return false
		elseif parentEntity.y >= areaY + areaH then
			return false
		elseif parentEntity.x + parentEntity.w <= areaX then
			return false
		elseif parentEntity.x >= areaX + areaW then
			return false
		else
			return true
		end
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL] = function(parentEntity, areaX, areaY,
		areaW, areaH)
		if parentEntity.y + parentEntity.h <= areaY then
			return false
		elseif parentEntity.y >= areaY + areaH then
			return false
		elseif parentEntity.x + parentEntity.w <= areaX then
			return false
		elseif parentEntity.x >= areaX + areaW then
			return false
		else
			return true
		end
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = function(parentEntity, areaX, areaY,
		areaW, areaH)
		--TODO
		return false
	end
}

SpatialPartitioningSystem.getDistanceToPointMethods = {
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(x, y, spatialEntity)
		return math.ceil(
			math.abs((x - (spatialEntity.parentEntity.x + spatialEntity.parentEntity.w/2))^2 + 
				(y - (spatialEntity.parentEntity.y + spatialEntity.parentEntity.h/2))^2)
		)
	end,
	
	[SpatialPartitioningSystem.ENTITY_TYPES.UNDEFINED] = function(x, y, spatialEntity)
		return 0	--possible bug?
	end,
}

SpatialPartitioningSystem.getEntityQuadMethods = {
	[SpatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(spatialEntity)
		return spatialEntity.parentEntity.x, spatialEntity.parentEntity.y,
			spatialEntity.parentEntity.w, spatialEntity.parentEntity.h
	end
}

function SpatialPartitioningSystem:getAllEntitiesInArea(area, subGrids, entityRoles, 
	x, y, w, h)
	
	--[[
		THIS IS JUST FOR TESTING - JUST SHOWS HOW TO LOOP THE GRIDS!
		useless without a hash table to avoid returning duplicate entities
		
		--get grid index tl
			--loop everything
				--grids | entityTypes -> array
				
				grid:getSubGridIndex(subGrid, x, y)
				systemTest.SpatialPartitioningSystem.area.entityList[1]
				subgrid.entityTables[entityRole]
				
				huge ass inner loops lmao, shouldn't be too expensive but it looks awful
	]]
	
	local entityList = {}
	local topLeftX, topLeftY = 0, 0
	local bottomRightX, bottomRightY = 0, 0
	
	for i=1, #subGrids do
		local subGrid = area.grid.subGrids[subGrids[i]]
		topLeftX, topLeftY = area.grid:getSubGridIndex(subGrid, x, y)
		bottomRightX, bottomRightY = area.grid:getSubGridIndex(subGrid, x + w, y + h)
		
		for j=1, #entityRoles do
			local entityTable = subGrid.entityTables[entityRoles[j]].entityTable
			
			for k=topLeftY, bottomRightY do
				for l=topLeftX, bottomRightX do
					for m=1, #entityTable[k][l] do
						table.insert(entityList, entityTable[k][l][m])
					end
				end
			end
		end
	end
	
	return entityList
end

function SpatialPartitioningSystem:setDefaultTableValues(requestTable)
	local defaultTable = function() return nil end
	local mt = {__index = function (requestTable) return requestTable.___ end}
	requestTable.___ = defaultTable
	setmetatable(requestTable, mt)
end

----------------
--Return Module:
----------------

SpatialPartitioningSystem:setDefaultTableValues(SpatialPartitioningSystem.defaultUpdatePositionMethods)
--...

return SpatialPartitioningSystem