--------------------------
--Entity Targeting System:
--------------------------
--[[
	needs ingame testing. make it auto search when activated maybe
]]

local entityTargetingSystem = {}

---------------
--Dependencies:
---------------

require 'misc'
entityTargetingSystem.ENTITY_ACTION = require 'ENTITY_ACTION'
entityTargetingSystem.ENTITY_TYPES = require '/entity/ENTITY_TYPE'
entityTargetingSystem.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
entityTargetingSystem.EVENT_OBJECT = require 'EVENT_OBJECT'
entityTargetingSystem.ENTITY_DIRECTION = require 'ENTITY_DIRECTION'
entityTargetingSystem.TARGET_MAPPING = require 'TARGET_MAPPING'
local SYSTEM_ID = require '/system/SYSTEM_ID'

entityTargetingSystem.id = SYSTEM_ID.TARGETING

entityTargetingSystem.actionRequestStack = {}

entityTargetingSystem.spatialSystemRequestPool = eventDataObjectPool.new(1, {'spatialRequest'}, 3)
entityTargetingSystem.spatialSystemRequestPool:buildObjectPool()

entityTargetingSystem.targetingActionRequestPool = eventDataObjectPool.new(5, {'TARGETING_REQUEST_TYPE', 
	{'TARGETING_SELECTOR_ENTITY_TYPE', 'TARGETING_SELECTOR_ENTITY_ID', 'TARGETING_STATE', 
	'TARGETING_TARGET_ENTITY_LIST'}}, 3)
entityTargetingSystem.targetingActionRequestPool:buildObjectPool()

entityTargetingSystem.spatialQueryPool = SpatialQueryPool.new(5, entityTargetingSystem.QUERY_TYPES.GET_NEAREST_ENTITY_BY_AREA_AND_ROLE, 
	SpatialQueryBuilder.new())

-------------------
--Static Variables:
-------------------

-------------------
--System Variables:
-------------------

entityTargetingSystem.genericEntityTargetingTable = {}

entityTargetingSystem.targetTable = {}

entityTargetingSystem.eventDispatcher = nil
entityTargetingSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

entityTargetingSystem.eventMethods = {

	[1] = {
		[1] = function(targetingActionRequest)
			table.insert(entityTargetingSystem.actionRequestStack, targetingActionRequest)
		end
	}
}

---------------
--Init Methods:
---------------

function entityTargetingSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function entityTargetingSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function entityTargetingSystem:createSpatialQueryPool(maxObjects)
	self.spatialQueryPool =	SpatialQueryPool.new(maxObjects, entityTargetingSystem.QUERY_TYPES.GET_NEAREST_ENTITY_BY_AREA_AND_ROLE, 
		SpatialQueryBuilder.new(), self:getTargetingChangeRequestResultsFunctionWrapper())
end

function entityTargetingSystem:buildTargetTable(entityDatabaseList)
	for index, entityDatabase in pairs(entityDatabaseList) do
		self.targetTable[entityDatabase.entityType] = self.getTargetListFromEntityTypeMethods[entityDatabase.entityType](entityDatabase)
	end
end

---------------
--Exec Methods:
---------------

function entityTargetingSystem:main()
	self.spatialSystemRequestPool:resetCurrentIndex()
	self.targetingActionRequestPool:resetCurrentIndex()
	self.spatialQueryPool:resetCurrentIndex()
	
	for i=1, #self.genericEntityTargetingTable do
		if self.genericEntityTargetingTable[i].state == true then
			self:runState(self.genericEntityTargetingTable[i])
		end
	end
	
	for i=#self.actionRequestStack, 1, -1 do
		self.targetingActionMethods[self.actionRequestStack[i][self.EVENT_OBJECT.TARGETING_REQUEST_TYPE]](self.actionRequestStack[i])
		table.remove(self.actionRequestStack)
	end
end

function entityTargetingSystem:getTargetEntity(targetEntityTypeId, targetEntityIndex)
	return self.targetTable[targetEntityTypeId][targetEntityIndex]
end

entityTargetingSystem.getTargetListFromEntityTypeMethods = {
	[entityTargetingSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(entityDatabase)
		return entityDatabase:getTableRows('entityHitboxTable')
	end,
	
	[entityTargetingSystem.ENTITY_TYPES.GENERIC_WALL] = function(entityDatabase)
		return entityDatabase:getTableRows('entityHitboxTable')
	end
}

function entityTargetingSystem:setTargetMapping(entityType, entityIndex, mappingType)
	self.setTargetMappingMethods[entityType](entityIndex, mappingType)
end

entityTargetingSystem.setTargetMappingMethods = {
	[entityTargetingSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(entityIndex, mappingType)
		local entity = self.genericEntityTargetingTable[entityIndex]
		entity.targetingType = mappingType
	end
}

entityTargetingSystem.targetingActionMethods = {
	
	[entityTargetingSystem.ENTITY_ACTION.TARGETING_SET_STATE] = function(actionRequest)
		local targetingEntity = actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY]
		
		if not targetingEntity.state then
			targetingEntity.state = true
			entityTargetingSystem.targetingActionMethods[entityTargetingSystem.ENTITY_ACTION.TARGETING_SEARCH](actionRequest)
		else
			entityTargetingSystem:resetTargetingEntityState(targetingEntity)
		end
	end,
		
	[entityTargetingSystem.ENTITY_ACTION.TARGETING_SEARCH] = function(actionRequest)
		
		local targetingEntity = actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY]
		local entityHitbox = targetingEntity.componentTable.hitbox
		local entityRole = targetingEntity.componentTable.scene.role
		
		local entityX, entityY = math.floor(entityHitbox.x + (entityHitbox.w/2)), 
			math.floor(entityHitbox.y + (entityHitbox.h/2))
		
		local direction = 0
		if targetingEntity.componentTable.movement then
			direction = targetingEntity.componentTable.movement.direction
		end
		
		local areaX, areaY, areaW, areaH = entityTargetingSystem:getSearchArea(entityX, entityY, 
			targetingEntity.areaRadius, direction)
		
		local targetRoles = entityTargetingSystem.TARGET_MAPPING.TYPES[targetingEntity.targetingType][entityRole]
		
		local nResults = 2
		
		local queryObj = entityTargetingSystem.spatialQueryPool:getCurrentAvailableObjectDefault()
		entityTargetingSystem.spatialQueryPool.queryBuilder:setSpatialQueryParameters(queryObj, 
			actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY_TYPE], 
			actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY], entityX, 
			entityY, areaX, areaY, areaW, areaH, targetingEntity.areaRadius, targetRoles, nResults)
		
		local spatialSystemRequest = entityTargetingSystem.spatialSystemRequestPool:getCurrentAvailableObject()
		spatialSystemRequest.spatialQuery = queryObj
		entityTargetingSystem.eventDispatcher:postEvent(1, 1, spatialSystemRequest)
		entityTargetingSystem.spatialSystemRequestPool:incrementCurrentIndex()
	end,
	
	[entityTargetingSystem.ENTITY_ACTION.TARGETING_SET_TARGET] = function(actionRequest)
		local targetRow = actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY]
		local currentTarget = targetRow.targetEntityRef
		
		if currentTarget == nil then
			if #actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_TARGET_ENTITY_LIST] > 0 then
				targetRow.targetEntityType, targetRow.targetEntityRef = 
					actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_TARGET_ENTITY_LIST][1].entityType,
					actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_TARGET_ENTITY_LIST][1].parentEntity
				return nil
			else
				--nothing previously set and nothing found, deactivate state
				entityTargetingSystem:resetTargetingEntityState(targetRow)
				return nil
			end
		end
		
		for i=1, #actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_TARGET_ENTITY_LIST] do
			if currentTarget ~= actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_TARGET_ENTITY_LIST][i].parentEntity then
				targetRow.targetEntityType, targetRow.targetEntityRef = 
					actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_TARGET_ENTITY_LIST][i].entityType,
					actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_TARGET_ENTITY_LIST][i].parentEntity
				break
			end
		end
	end,
	
	[entityTargetingSystem.ENTITY_ACTION.TARGETING_RESET_STATE] = function(actionRequest)
		local targetingEntity = actionRequest[entityTargetingSystem.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY]
		entityTargetingSystem:resetTargetingEntityState(targetingEntity)
	end
}

function entityTargetingSystem:runState(entity)
	
	local x, y = math.floor(entity.componentTable.hitbox.x + (entity.componentTable.hitbox.w/2)), 
		math.floor(entity.componentTable.hitbox.y + (entity.componentTable.hitbox.h/2))
	
	if entity.targetEntityRef ~= nil then
		local targetX, targetY = entityTargetingSystem.getTargetEntityCoordinates[entity.targetEntityType](entity.targetEntityRef)
	
		if getDistanceSquaredBetweenPoints(x, y, targetX, targetY) > entity.areaRadius^2 then
			
			entity.targetEntityRef = nil
			
			local targetingActionRequest = self.targetingActionRequestPool:getCurrentAvailableObject()
				targetingActionRequest[self.EVENT_OBJECT.TARGETING_REQUEST_TYPE],
				targetingActionRequest[self.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY_TYPE],
				targetingActionRequest[self.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY] = 
				self.ENTITY_ACTION.TARGETING_SEARCH, self.ENTITY_TYPES.GENERIC_ENTITY, entity
				
			table.insert(self.actionRequestStack, targetingActionRequest)
			self.targetingActionRequestPool:incrementCurrentIndex()
		else
			local angle = getAngle(x, y, targetX, targetY)
			local direction = self.ENTITY_DIRECTION.DEGREE_TO_DIRECTION_MAP:getValue(angle)
			
			--debugger.debugStrings[1] = angle .. ', ' .. direction
			
			--direction modifier and angle have to be available for other systems
		end
	else
		--state == true and targetEntityRef == nil
			--due to order of operations, currently not a concern
			--the state is always deactivated when the lock is broken (1 frame delay)
	end
end

function entityTargetingSystem:resetTargetingEntityState(entity)
	entity.state = false
	entity.targetingType = entity.defaultTargetingType
	entity.targetEntityRef = nil
end

function entityTargetingSystem:getSearchArea(x, y, radius, direction)
	return self.getSearchAreaMethods[direction](x, y, radius)
end

entityTargetingSystem.getSearchAreaMethods = {
	[entityTargetingSystem.ENTITY_DIRECTION.UP] = function(x, y, radius)
		x, y = x - radius, y - radius
		return x, y, radius*2, radius
	end,
	
	[entityTargetingSystem.ENTITY_DIRECTION.UP_LEFT] = function(x, y, radius)
		x, y = x - radius, y - radius
		return x, y, radius, radius
	end,
	
	[entityTargetingSystem.ENTITY_DIRECTION.LEFT] = function(x, y, radius)
		x, y = x - radius, y - radius
		return x, y, radius, radius*2
	end,
	
	[entityTargetingSystem.ENTITY_DIRECTION.DOWN_LEFT] = function(x, y, radius)
		x = x - radius
		return x, y, radius, radius
	end,
	
	[entityTargetingSystem.ENTITY_DIRECTION.DOWN] = function(x, y, radius)
		x = x - radius
		return x, y, radius*2, radius
	end,
	
	[entityTargetingSystem.ENTITY_DIRECTION.DOWN_RIGHT] = function(x, y, radius)
		return x, y, radius, radius
	end,
	
	[entityTargetingSystem.ENTITY_DIRECTION.RIGHT] = function(x, y, radius)
		y = y - radius
		return x, y, radius, radius*2
	end,
	
	[entityTargetingSystem.ENTITY_DIRECTION.UP_RIGHT] = function(x, y, radius)
		y = y - radius
		return x, y, radius, radius
	end
}

entityTargetingSystem.getDistanceSquaredToEntity = {
	[entityTargetingSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(x, y, entity)
		local targetEntityX, targetEntityY = math.floor(entity.x + (entity.w/2)), 
			math.floor(entity.y + (entity.h/2))
		return math.ceil(math.abs((x - (targetEntityX))^2 + (y - (targetEntityY))^2))
	end
}

entityTargetingSystem.getTargetEntityCoordinates = {
	[entityTargetingSystem.ENTITY_TYPES.GENERIC_ENTITY] = function(entity)
		return math.floor(entity.x + (entity.w/2)), math.floor(entity.y + (entity.h/2))
	end
}

function entityTargetingSystem:getRadiusDistanceSquared(x, y, radius)
	return math.ceil(math.abs((x - (x + radius))^2 + (y - (y + radius))^2))
end

function entityTargetingSystem:getTargetingChangeRequestResultsFunctionWrapper()
	return function (spatialQuery, results)
		
		local targetingActionRequest = self.targetingActionRequestPool:getCurrentAvailableObject()
		targetingActionRequest[self.EVENT_OBJECT.TARGETING_REQUEST_TYPE], 
		targetingActionRequest[self.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY_TYPE],
		targetingActionRequest[self.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY],
		targetingActionRequest[self.EVENT_OBJECT.TARGETING_TARGET_ENTITY_LIST] = 
		entityTargetingSystem.ENTITY_ACTION.TARGETING_SET_TARGET, spatialQuery.originEntityType, 
		spatialQuery.originEntityRef, results
		
		table.insert(self.actionRequestStack, targetingActionRequest)
		self.targetingActionRequestPool:incrementCurrentIndex()
	end
end

--debug:
function entityTargetingSystem:drawTargetingArea(entityType, entityIndex, camera)
	local areaX, areaY, areaW, areaH = self.targetingActionMethods[entityType][6]({entityIndex})
	love.graphics.rectangle('line', areaX - camera.x, areaY - camera.y, areaW, areaH)
end

function entityTargetingSystem:drawEntityQuad(targetingEntity, camera)
	if targetingEntity.targetEntityRef ~= nil then
		local entityHitbox = targetingEntity.targetEntityRef
		love.graphics.rectangle('fill', entityHitbox.x - camera.x, entityHitbox.y - camera.y, entityHitbox.w, entityHitbox.h)
	end
end

----------------
--Return Module:
----------------

return entityTargetingSystem