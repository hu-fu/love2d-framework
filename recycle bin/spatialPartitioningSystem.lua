-------------------------------------
--Spatial Partitioning System Module:
-------------------------------------

--[[
Global system id = 

How to get spriteboxes:
	get hitboxes (sp entities) in area (area a bit larger than camera)
	add methods to get the sprite object from the hitbox (by type)
	return something like this: [TYPE] -> spritebox
]]

local spatialPartitioningSystem = {}

---------------
--Dependencies:
---------------

require 'spatialGrid'
require 'spatialPartitioningObjects'
require 'spatialPartitioningQuery'
require 'collisionPairsManager'
spatialPartitioningSystem.collisionMethods = require 'collisionMethods'
spatialPartitioningSystem.mapToQuadsConverter = require 'mapToQuadsConverter'
spatialPartitioningSystem.projectileSpatialIndexing = require 'projectileSpatialIndexing'

spatialPartitioningSystem.ENTITY_TYPES = require 'ENTITY_TYPE'
spatialPartitioningSystem.ENTITY_ROLES = require 'ENTITY_ROLE'
spatialPartitioningSystem.QUERY_TYPE = require 'SPATIAL_QUERY'
spatialPartitioningSystem.EVENT_OBJECT = require 'EVENT_OBJECT'

-------------------
--Static Variables:
-------------------

-------------------
--System Variables:
-------------------

spatialPartitioningSystem.areas = {}			--sorted by visiting order, [1] is current
spatialPartitioningSystem.maxAreas = 2

spatialPartitioningSystem.preloadedAreas = {}	--unsorted
spatialPartitioningSystem.maxPreloaded = 1

spatialPartitioningSystem.eventDispatcher = nil
spatialPartitioningSystem.eventListenerList = {}

spatialPartitioningSystem.spatialQueryStack = {}

----------------
--Event Methods:
----------------

spatialPartitioningSystem.eventMethods = {
	
	[1] = {
		[1] = function(spatialRequest)
			--add query to query stack
			table.insert(spatialPartitioningSystem.spatialQueryStack, spatialRequest[1])
		end
	}
}

---------------
--Init Methods:
---------------

function spatialPartitioningSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function spatialPartitioningSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

---------------
--Exec Methods:
---------------

function spatialPartitioningSystem:setMaxAreas(maxAreas)
	if maxAreas <= 0 then maxAreas = 1 end
	self.maxAreas = maxAreas
	for i=#self.areas, maxAreas, -1 do
		self:removeArea()
	end
end

function spatialPartitioningSystem:setAreaAsCurrent(areaIndex)
	--moves areas[index] to areas[1]
	if areaIndex > 1 and areaIndex <= #self.areas then
		local area = self.areas[areaIndex]
		self:insertArea(area)
		table.remove(self.areas, areaIndex)
	end
end

function spatialPartitioningSystem:insertArea(areaSpatialObject)
	table.insert(self.areas, 1, areaSpatialObject)
end

function spatialPartitioningSystem:removeArea()
	table.remove(self.areas)
end

function spatialPartitioningSystem:removeOlderAreas()
	self:setMaxAreas(self.maxAreas)
end

function spatialPartitioningSystem:getAreaIndexByAreaId(areaId)
	for i=1, #self.areas do
		if self.areas[i].areaId == areaId then
			return i
		end
	end
	return -1
end

function spatialPartitioningSystem:getAreaById(areaId)
	local areaIndex = self:getAreaIndexByAreaId(areaId)
	if areaIndex > 0 then
		return self.areas[areaIndex]
	end
	return false
end 

function spatialPartitioningSystem:isAreaPreloaded(areaId)
	for i=1, #self.preloadedAreas do
		if self.preloadedAreas[i].id == areaId then
			return true
		end
	end
	return false
end

function spatialPartitioningSystem:getPreloadedAreaById(areaId)
	for i=1, #self.preloadedAreas do
		if self.preloadedAreas[i].areaId == areaId then
			return self.preloadedAreas[i]
		end
	end
	return false
end

function spatialPartitioningSystem:getPreloadedAreaIndexByAreaId(areaId)
	for i=1, #self.preloadedAreas do
		if self.preloadedAreas[i].areaId == areaId then
			return i
		end
	end
	return -1
end

function spatialPartitioningSystem:addAreaToPreloaded(areaSpatialObject)
	table.insert(self.preloadedAreas, areaSpatialObject)
end

function spatialPartitioningSystem:removeAreaFromPreloaded(areaId)
	local index = self:getPreloadedAreaIndexByAreaId(areaId)
	table.remove(self.preloadedAreas, index)
end

function spatialPartitioningSystem:removeAreaFromPreloadedByIndex(index)
	table.remove(self.preloadedAreas, index)
end

function spatialPartitioningSystem:setMaxPreloadedAreas(maxPreloaded)
	if maxPreloaded < 0 then maxPreloaded = 0 end
	self.maxPreloaded = maxPreloaded
	for i=#self.preloadedAreas, maxPreloaded, -1 do
		table.remove(self.preloadedAreas)
	end
end

function spatialPartitioningSystem:addArea(area, current)
	--change the area argument for an area subset if needed (ex: area.spatialInfo)
	
	local areaIndex = self:getAreaIndexByAreaId(area.areaId)
	local preloadedAreaIndex = self:getPreloadedAreaIndexByAreaId(area.areaId)
	
	if areaIndex > 0 then
		self:setAreaAsCurrent(areaIndex)
	elseif preloadedAreaIndex > 0 then
		self:insertArea(self.preloadedAreas[preloadedAreaIndex])
		self:removeAreaFromPreloadedByIndex(preloadedAreaIndex)
		self:removeOlderAreas()
	else
		--area isn't in memory:
		local areaSpatialObject = self:createAreaSpatialEntity(area)
		
		if current then
			self:insertArea(areaSpatialObject)
			self:removeOlderAreas()
		else
			self:addAreaToPreloaded(areaSpatialObject)
			self:setMaxPreloadedAreas(self.maxPreloaded)
		end
	end
end

function spatialPartitioningSystem:createAreaSpatialEntity(area)
	local areaSpatialObject = areaSpatialEntity.new(area.areaId, nil)
	
	self:createAreaSpatialEntityList(area.entityList, areaSpatialObject)
	
	local grid = spatialGrid.new(area.minimumNodeWidth, area.minimumNodeHeight, 
		area.nodeSizeMultiplier)
	areaSpatialObject.grid = grid
	areaSpatialObject.grid:buildGrid(area.limitX, area.limitY)
	areaSpatialObject.grid:createSpatialEntityTables(self:getEntityRoles())
	
	return areaSpatialObject
end

function spatialPartitioningSystem:createAreaSpatialEntityList(areaEntityList, areaSpatialObject)
	--ALPHA VERSION
	--areaEntityList = [TYPE] -> database -> tables -> list
	--areaSpatialObject.entityList -> [TYPE] -> spatial object list
	
	areaSpatialObject.entityList = {}
	
	for index, entityDatabase in pairs(areaEntityList) do
		areaSpatialObject.entityList[entityDatabase.entityType] = {}
		
		local entityList = self:getEntityListFromEntityDatabase(entityDatabase)
		
		for i=1, #entityList do
			local spatialEntity = self:createSpatialEntity(entityList[i])
			table.insert(areaSpatialObject.entityList[entityDatabase.entityType], spatialEntity)
			spatialEntity.id = i
			self:registerSpatialEntityOnEntity(entityList[i], entityDatabase.entityType, spatialEntity)
		end
	end
end

function spatialPartitioningSystem:createSpatialEntity(entity)
	local entityRole = 0
	local spatialLevel = -1
	local spatialIndexX, spatialIndexY = -1, -1
	local xOverlap = false
	local yOverlap = false
	local id = 0
	
	local spatialEntityObject = spatialEntity.new(id, entity, entityRole, spatialLevel, spatialIndexX, 
		spatialIndexY, xOverlap, yOverlap)
	
	return spatialEntityObject
end

function spatialPartitioningSystem:updateSpatialEntity(entity, spatialIndexX, spatialIndexY, 
	xOverlap, yOverlap)
	entity.spatialIndexX = spatialIndexX
	entity.spatialIndexY = spatialIndexY
	entity.xOverlap = xOverlap
	entity.yOverlap = yOverlap
end

function spatialPartitioningSystem:registerSpatialEntityOnEntity(entity, entityType, spatialEntity)
	--TODO: by type
	entity.spatialEntity = spatialEntity
end

function spatialPartitioningSystem:registerAllEntitiesInArea(areaId)
	local area = self:getAreaById(areaId)
	if area then
		for entityType, list in pairs(area.entityList) do
			for i=1, #list do
				if list[i].spatialLevel > 0 then
					--if already registered:
					--area.grid.subGrids[list[i].spatialLevel].entityTables[entityRole]
						--:unregisterEntity(list[i])
				end
				
				local entityRole = self:entityToRole(entityType, list[i].parentEntity)
				self:registerSpatialEntity(entityType, list[i], area.grid, entityRole)
			end
		end
	end
end

function spatialPartitioningSystem:getEntityRoles()
	local roles = {}
	for role, id in pairs(self.ENTITY_ROLES) do 
		table.insert(roles, id)
	end
	return roles
end

function spatialPartitioningSystem:entityToRole(entityType, entity)
	--TODO: by type
	return entity.componentTable.scene.role
end

---------------
--Query System:
---------------

spatialPartitioningSystem.spatialQueryMethods = {
	
	[spatialPartitioningSystem.QUERY_TYPE.UPDATE_ENTITY] = function(spatialRequest)
		spatialPartitioningSystem.defaultUpdatePositionMethods[spatialRequest.queryType]()
		return nil
	end,
	
	[spatialPartitioningSystem.QUERY_TYPE.GET_NEAREST_ENTITY_BY_AREA_AND_ROLE] = function(spatialRequest)
		return spatialPartitioningSystem:getNearestEntityByAreaAndRole(spatialPartitioningSystem.areas[1].grid, 
			spatialRequest.x, spatialRequest.y, spatialRequest.areaX, spatialRequest.areaY, 
			spatialRequest.areaW, spatialRequest.areaH, spatialRequest.searchRadius, 
			spatialRequest.targetRoles, spatialRequest.numberOfResults)
	end
}

function spatialPartitioningSystem:runQueries()
	for i=#self.spatialQueryStack, 1, -1 do
		local results = self.spatialQueryMethods[self.spatialQueryStack[i].queryType](self.spatialQueryStack[i])
		self.spatialQueryStack[i].responseCallback(self.spatialQueryStack[i], results)	--(self, results)
		table.remove(self.spatialQueryStack)
	end
end

----------------
--Query methods:
----------------

function spatialPartitioningSystem:getEntityListFromEntityDatabase(entityDatabase)
	return self.getEntityListFromEntityTypeMethods[entityDatabase.entityType](entityDatabase)
end

spatialPartitioningSystem.getEntityListFromEntityTypeMethods = {
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(entityDatabase)
		return entityDatabase:getTableRows('entityHitboxTable')
	end,
	
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL] = function(entityDatabase)
		return entityDatabase:getTableRows('entityHitboxTable')
	end
}

function spatialPartitioningSystem:getSpriteboxFromSpatialEntity(spatialEntity)
	--use with an area query to get all the objects on screen, and send them to the renderer
	--get hitboxes on area -> transform into spritebox -> send to renderer
	return spatialEntity.parentEntity.componentTable.spritebox
end

function spatialPartitioningSystem:registerSpatialEntity(entityType, entity, grid, entityRole)
	self.defaultRegisterSpatialEntityMethods[entityType](entity, grid, entityRole)
end

spatialPartitioningSystem.defaultRegisterSpatialEntityMethods = {
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(spatialEntity, grid, entityRole)
		local gridLevel = grid:getEntityGridLevel(spatialEntity.parentEntity.w, spatialEntity.parentEntity.h)
		local subGrid = grid.subGrids[gridLevel]
		
		local spatialIndexX, spatialIndexY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x, 
			spatialEntity.parentEntity.y)
		
		local node = subGrid.nodes[spatialIndexY][spatialIndexX]
		local xOverlap = grid:nodeRightRangeCheck(node, spatialEntity.parentEntity.x + spatialEntity.parentEntity.w)
		local yOverlap = grid:nodeBottomRangeCheck(node, spatialEntity.parentEntity.y + spatialEntity.parentEntity.h)
		
		spatialEntity.entityRole = entityRole
		spatialEntity.entityType = spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY
		spatialEntity.spatialLevel = gridLevel
		spatialEntity.spatialIndexX = spatialIndexX
		spatialEntity.spatialIndexY = spatialIndexY
		spatialEntity.xOverlap = xOverlap
		spatialEntity.yOverlap = yOverlap
		
		subGrid.entityTables[spatialEntity.entityRole]:registerEntity(spatialEntity)
	end,
	
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL] = function(spatialEntity, grid, entityRole)
		local gridLevel = grid:getEntityGridLevel(1, 1) 	--lowest level (grid:getLowestGridLevel)
		local subGrid = grid.subGrids[gridLevel]
		
		local topLeftX, topLeftY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x, 
			spatialEntity.parentEntity.y)
		
		--subtract br coordinates by one so it doesn't register in adjacent nodes (may be a bad idea)
		local bottomRightX, bottomRightY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x + 
			spatialEntity.parentEntity.w - 1, spatialEntity.parentEntity.y + spatialEntity.parentEntity.h - 1)
		
		local xOverlap, yOverlap = true, true
		
		spatialEntity.entityRole = entityRole
		spatialEntity.entityType = spatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL
		spatialEntity.spatialLevel = gridLevel
		spatialEntity.spatialIndexX = topLeftX
		spatialEntity.spatialIndexY = topLeftY
		spatialEntity.xOverlap = xOverlap
		spatialEntity.yOverlap = yOverlap
		
		subGrid.entityTables[spatialEntity.entityRole]:registerEntityInArea(spatialEntity, topLeftX, topLeftY, 
			bottomRightX, bottomRightY)
	end,
	
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = function(spatialEntity, grid, entityRole)
		spatialPartitioningSystem.projectileSpatialIndexing:indexProjectile(spatialEntity, grid, entityRole)
	end
}

function spatialPartitioningSystem:unregisterSpatialEntity(entityType, entity, grid)
	self.defaultUnregisterSpatialEntityMethods[entityType](entity, grid)
end

spatialPartitioningSystem.defaultUnregisterSpatialEntityMethods = {
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(spatialEntity, grid)
		
	end,
	
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_WALL] = function(spatialEntity, grid)
		local subGrid = grid.subGrids[spatialEntity.spatialLevel]
		
		local topLeftX, topLeftY = grid:getSubGridIndex(subGrid, spatialEntity.parentEntity.x, 
			spatialEntity.parentEntity.y)
		local bottomRightX, bottomRightY = grid:getSubGridIndex(subGrid, 
			spatialEntity.parentEntity.x + spatialEntity.parentEntity.w, 
			spatialEntity.parentEntity.y + spatialEntity.parentEntity.h)
		
		subGrid.entityTables[spatialEntity.entityRole]:unregisterEntityInArea(spatialEntity, topLeftX,
			topLeftY, bottomRightX, bottomRightY)
	end,
	
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = function(spatialEntity, grid)
		spatialPartitioningSystem.projectileSpatialIndexing:unregisterProjectile(spatialEntity, grid)
	end,
}

function spatialPartitioningSystem:updateEntityPosition(entityType, spatialEntity, grid)
	self.defaultUpdatePositionMethods[entityType](spatialEntity, grid)
end

spatialPartitioningSystem.defaultUpdatePositionMethods = {
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(spatialEntity, grid)
		
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

		if changeHorizontal ~= 0 then
			
			if changeVertical ~= 0 then
				subGrid.entityTables[spatialEntity.entityRole]:unregisterEntity(spatialEntity)
				spatialPartitioningSystem:updateSpatialEntity(spatialEntity, currentIndexX, 
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
					spatialPartitioningSystem:updateSpatialEntity(spatialEntity, currentIndexX, 
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
				spatialPartitioningSystem:updateSpatialEntity(spatialEntity, currentIndexX, 
					currentIndexY, currentXOverlap, currentYOverlap)
				subGrid.entityTables[spatialEntity.entityRole]:registerEntity(spatialEntity)
			end
			
		elseif currentXOverlap ~= spatialEntity.xOverlap then
			
			if currentYOverlap ~= spatialEntity.yOverlap then
				subGrid.entityTables[spatialEntity.entityRole]:unregisterEntity(spatialEntity)
				spatialPartitioningSystem:updateSpatialEntity(spatialEntity, currentIndexX, 
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
		
		spatialPartitioningSystem:updateSpatialEntity(spatialEntity, currentIndexX, 
			currentIndexY, currentXOverlap, currentYOverlap)
		
		--fail safe removal -> 100 iterations @ 53fps avg (moving), 0.015% time (anonymous func)
		--this -> 200 iterations at 58fps avg
		
	end,
	
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_PROJECTILE] = function(spatialEntity, grid)
		spatialPartitioningSystem.projectileSpatialIndexing:updateProjectile(spatialEntity, grid)
	end
}

function spatialPartitioningSystem:getCollisionPairsInArea(queryType, grid, x, y, w, h, entityRoleA, 
	entityRoleB, pairsManager)
	
	self.defaultGetCollisionPairsInAreaMethods[queryType](grid, x, y, w, h, entityRoleA, entityRoleB, 
		pairsManager)
end

spatialPartitioningSystem.defaultGetCollisionPairsInAreaMethods = {
	
	[1] = function(grid, x, y, w, h, entityRoleA, entityRoleB, pairsManager)
		--DEBUG; tries to get all pairs; unnoptimized;
		
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

function spatialPartitioningSystem:getNearestEntityByAreaAndRole(grid, x, y, areaX, areaY, areaW, areaH, 
	searchRadius, targetRoles, numberOfResults)
	--can (and should) be optimised - this one covers all situations, looks really ugly but does the job
	--we can use a different type of algorithm (like checking for obstacles with ray casting, etc)
	--possible problem(?) in this function, profiler acting weird - solved I think
	
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
						
						entityDistance = spatialPartitioningSystem.getDistanceToPointMethods
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
							
							if spatialPartitioningSystem.collisionMethods:rectToRectDetection(areaX, areaY, areaX + areaW, 
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

spatialPartitioningSystem.getDistanceToPointMethods = {
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(x, y, spatialEntity)
		return math.ceil(
			math.abs((x - (spatialEntity.parentEntity.x + spatialEntity.parentEntity.w/2))^2 + 
				(y - (spatialEntity.parentEntity.y + spatialEntity.parentEntity.h/2))^2)
		)
	end
}

spatialPartitioningSystem.getEntityQuadMethods = {
	[spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(spatialEntity)
		return spatialEntity.parentEntity.x, spatialEntity.parentEntity.y,
			spatialEntity.parentEntity.w, spatialEntity.parentEntity.h
	end
}

function spatialPartitioningSystem:getAllEntitiesInArea(area, subGrids, entityRoles, 
	x, y, w, h)
	
	--[[
		THIS IS JUST FOR TESTING - JUST SHOWS HOW TO LOOP THE GRIDS!
		useless without a hash table to avoid returning duplicate entities
		
		--get grid index tl
			--loop everything
				--grids | entityTypes -> array
				
				grid:getSubGridIndex(subGrid, x, y)
				systemTest.spatialPartitioningSystem.areas[1].entityList[1]
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

--[[
	To do list:
]]

----------------
--Return Module:
----------------

return spatialPartitioningSystem