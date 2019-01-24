--------------------------
--Entity Targeting System:
--------------------------

local EntityTargetingSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
require '/event/EventObjectPool'
EntityTargetingSystem.EVENT_TYPES = require '/event/EVENT_TYPE'
EntityTargetingSystem.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
EntityTargetingSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityTargetingSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityTargetingSystem.ENTITY_ROLE = require '/entity/ENTITY_ROLE'
EntityTargetingSystem.ENTITY_ROLE_GROUP = require '/entity/ENTITY_ROLE_GROUP'
EntityTargetingSystem.ENTITY_ROLE_TRANSFORM = require '/entity/ENTITY_ROLE_TRANSFORM'
EntityTargetingSystem.ENTITY_DIRECTION = require '/entity state/ENTITY_DIRECTION'
EntityTargetingSystem.TARGETING_REQUEST = require '/target/TARGETING_REQUEST'

-------------------
--System Variables:
-------------------

EntityTargetingSystem.id = SYSTEM_ID.TARGETING

function EntityTargetingSystem:spatialQueryDefaultCallbackMethod() return function () end end
EntityTargetingSystem.spatialSystemRequestPool = EventObjectPool.new(EntityTargetingSystem.EVENT_TYPES.SPATIAL_REQUEST, 50)
EntityTargetingSystem.spatialQueryPool = SpatialQueryPool.new(50, EntityTargetingSystem.QUERY_TYPES.GET_NEAREST_ENTITY_BY_AREA_AND_ROLE, 
	SpatialQueryBuilder.new(), EntityTargetingSystem:spatialQueryDefaultCallbackMethod())

EntityTargetingSystem.targetingComponentTable = {}	

EntityTargetingSystem.requestStack = {}

EntityTargetingSystem.eventDispatcher = nil
EntityTargetingSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

EntityTargetingSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--set entity component table (request.entityDb)
			EntityTargetingSystem:setTargetingComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--request into stack
			EntityTargetingSystem:addRequestToStack(request)
		end
	}
}

---------------
--Init Methods:
---------------

function EntityTargetingSystem:setTargetingComponentTable(entityDb)
	self.targetingComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.TARGETING)
end

function EntityTargetingSystem:init()
	
end

---------------
--Exec Methods:
---------------

function EntityTargetingSystem:update()
	for i=1, #self.targetingComponentTable do
		if self.targetingComponentTable[i].state then
			self:runState(self.targetingComponentTable[i])
			self:setSpriteboxQuadByTarget(self.targetingComponentTable[i])
		elseif self.targetingComponentTable[i].directionLock then
			self:setSpriteboxQuadByLock(self.targetingComponentTable[i])
		end
	end
	
	self:resolveRequestStack()
	
	self.spatialSystemRequestPool:resetCurrentIndex()
	self.spatialQueryPool:resetCurrentIndex()
end

function EntityTargetingSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function EntityTargetingSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

function EntityTargetingSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function EntityTargetingSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

EntityTargetingSystem.resolveRequestMethods = {
	[EntityTargetingSystem.TARGETING_REQUEST.SET_STATE] = function(self, request)
		if not request.targetingComponent.state then
			self:activateState(request.targetingComponent)
			self:searchNewTarget(request.targetingComponent)
		else
			self:resetState(request.targetingComponent)
		end
	end,
		
	[EntityTargetingSystem.TARGETING_REQUEST.SEARCH] = function(self, request)
		self:activateState(request.targetingComponent)
		self:searchNewTarget(request.targetingComponent)
	end,
	
	[EntityTargetingSystem.TARGETING_REQUEST.SET_TARGET] = function(self, request)
		self:activateState(request.targetingComponent)
		self:setTargetOnComponent(request.targetingComponent, request.targetHitbox)
	end,
	
	[EntityTargetingSystem.TARGETING_REQUEST.REMOVE_TARGET] = function(self, request)
		self:removeTarget(request.targetHitbox)
	end,
	
	[EntityTargetingSystem.TARGETING_REQUEST.SET_DIRECTION_LOCK] = function(self, request)
		self:setDirectionLock(request.targetingComponent, request.lockState, request.direction)
	end,
	
	[EntityTargetingSystem.TARGETING_REQUEST.SET_LOCK_DIRECTION] = function(self, request)
		self:setLockDirection(request.targetingComponent, request.direction)
	end,
}

function EntityTargetingSystem:runState(targetingComponent)
	if targetingComponent.targetHitbox and targetingComponent.areaRadius >= 0 then
		local hitbox = targetingComponent.componentTable.hitbox
		local targetHitbox = targetingComponent.targetHitbox
		local x, y = hitbox.x + (hitbox.w/2), hitbox.y + (hitbox.h/2)
		local targetX, targetY = targetHitbox.x + (targetHitbox.w/2), targetHitbox.y + (targetHitbox.h/2)
		local distanceToTarget = self:getDistanceSquaredBetweenPoints(x, y, targetX, targetY)
		
		if distanceToTarget > targetingComponent.areaRadius^2 then
			targetingComponent.targetHitbox = nil
			self:searchNewTarget(targetingComponent)
		else
			targetingComponent.distanceToTarget = distanceToTarget
		end
	elseif targetingComponent.areaRadius < 0 then
		--still not tested! - maybe not a great idea, too resource intensive perhaps
			--delete the whole elseif statement to revert back to the older version
		local hitbox = targetingComponent.componentTable.hitbox
		local targetHitbox = targetingComponent.targetHitbox
		local x, y = hitbox.x + (hitbox.w/2), hitbox.y + (hitbox.h/2)
		local targetX, targetY = targetHitbox.x + (targetHitbox.w/2), targetHitbox.y + (targetHitbox.h/2)
		local distanceToTarget = self:getDistanceSquaredBetweenPoints(x, y, targetX, targetY)
		targetingComponent.distanceToTarget = distanceToTarget
	else
		if targetingComponent.auto then
			self:searchNewTarget(targetingComponent)
		else
			self:resetState(targetingComponent)
		end
	end
end

function EntityTargetingSystem:activateState(targetingComponent)
	targetingComponent.state = true
end

function EntityTargetingSystem:resetState(targetingComponent)
	targetingComponent.state = false
	targetingComponent.targetHitbox = nil
end

function EntityTargetingSystem:setTargetOnComponent(targetingComponent, targetHitbox)
	targetingComponent.targetHitbox = targetHitbox
end

function EntityTargetingSystem:searchNewTarget(targetingComponent)
	--a total mess, refactor please
	--bug where calling this in certain circumstances is dreadfully slow
		--origin might be the spatial sys request
	
	local hitbox = targetingComponent.componentTable.hitbox
	local entityRole = targetingComponent.componentTable.scene.role
	local x, y = math.floor(hitbox.x + (hitbox.w/2)), 
		math.floor(hitbox.y + (hitbox.h/2))
	
	local direction = 5
	if targetingComponent.componentTable.movement then
		direction = targetingComponent.componentTable.spritebox.direction
	end
	
	local areaX, areaY, areaW, areaH = self:getSearchAreaByDirection(x, y, targetingComponent.areaRadius, 
		direction)
	
	local targetRoles = self.ENTITY_ROLE_TRANSFORM:transformRole(self.ENTITY_ROLE_GROUP.ENEMY, entityRole)
	local nResults = 2
	
	local spatialQuery = self:createSpatialQuery(targetingComponent, x, y, areaX, areaY, areaW, areaH,
		targetingComponent.areaRadius, targetRoles, nResults)
	self:sendSpatialQuery(spatialQuery)
end

function EntityTargetingSystem:removeTarget(targetHitbox)
	for i=1, #self.targetingComponentTable do
		local component = self.targetingComponentTable[i]
		
		if component.state and component.targetHitbox == targetHitbox then
			
			if component.auto then
				component.targetHitbox = nil
				self:searchNewTarget(component)
			else
				self:resetState(component)
			end
		end
	end
end

function EntityTargetingSystem:createSpatialQuery(targetingComponent, x, y, areaX, areaY, areaW, 
	areaH, areaRadius, targetRoles, nResults)
	local spatialQuery = self.spatialQueryPool:getCurrentAvailableObjectDefault()
	self.spatialQueryPool:incrementCurrentIndex()
	
	spatialQuery.responseCallback = self:getSpatialQueryCallbackMethod(targetingComponent)
	spatialQuery.x = x
	spatialQuery.y = y
	spatialQuery.areaX = areaX
	spatialQuery.areaY = areaY
	spatialQuery.areaW = areaW
	spatialQuery.areaH = areaH
	spatialQuery.searchRadius = areaRadius
	spatialQuery.targetRoles = targetRoles
	spatialQuery.numberOfResults = nResults
	
	return spatialQuery
end

function EntityTargetingSystem:sendSpatialQuery(spatialQuery)
	local spatialSystemRequest = self.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = spatialQuery
	self.eventDispatcher:postEvent(1, 1, spatialSystemRequest)
	self.spatialSystemRequestPool:incrementCurrentIndex()
end

function EntityTargetingSystem:getQueryResults(spatialSystem, spatialQuery, results, targetingComponent)
	if not targetingComponent.state then return nil end
	
	for i=1, #results do
		if targetingComponent.targetHitbox ~= results[i].parentEntity
			and self:isEntityActive(results[i].parentEntity) then
			targetingComponent.targetHitbox = results[i].parentEntity
			return nil
		end
	end
	
	if targetingComponent.auto then
		self:searchNewTarget(targetingComponent)
	else 
		self:resetState(targetingComponent)
	end
end

function EntityTargetingSystem:getSpatialQueryCallbackMethod(targetingComponent)
	return function (spatialSystem, spatialQuery, results)
		self:getQueryResults(spatialSystem, spatialQuery, results, targetingComponent) 
	end
end

function EntityTargetingSystem:getSearchAreaByAngle(x, y, radius, angle)
	--calculate search area using the movement directional angle
end

function EntityTargetingSystem:getSearchAreaByDirection(x, y, radius, direction)
	return self.getSearchAreaByDirectionMethods[direction](x, y, radius)
end

EntityTargetingSystem.getSearchAreaByDirectionMethods = {
	[EntityTargetingSystem.ENTITY_DIRECTION.UP] = function(x, y, radius)
		x, y = x - radius, y - radius
		return x, y, radius*2, radius
	end,
	
	[EntityTargetingSystem.ENTITY_DIRECTION.UP_LEFT] = function(x, y, radius)
		x, y = x - radius, y - radius
		return x, y, radius, radius
	end,
	
	[EntityTargetingSystem.ENTITY_DIRECTION.LEFT] = function(x, y, radius)
		x, y = x - radius, y - radius
		return x, y, radius, radius*2
	end,
	
	[EntityTargetingSystem.ENTITY_DIRECTION.DOWN_LEFT] = function(x, y, radius)
		x = x - radius
		return x, y, radius, radius
	end,
	
	[EntityTargetingSystem.ENTITY_DIRECTION.DOWN] = function(x, y, radius)
		x = x - radius
		return x, y, radius*2, radius
	end,
	
	[EntityTargetingSystem.ENTITY_DIRECTION.DOWN_RIGHT] = function(x, y, radius)
		return x, y, radius, radius
	end,
	
	[EntityTargetingSystem.ENTITY_DIRECTION.RIGHT] = function(x, y, radius)
		y = y - radius
		return x, y, radius, radius*2
	end,
	
	[EntityTargetingSystem.ENTITY_DIRECTION.UP_RIGHT] = function(x, y, radius)
		y = y - radius
		return x, y, radius, radius
	end
}

function EntityTargetingSystem:getRadiusDistanceSquared(x, y, radius)
	return math.ceil(math.abs((x - (x + radius))^2 + (y - (y + radius))^2))
end

function EntityTargetingSystem:getDistanceSquaredBetweenPoints(aX, aY, bX, bY)
	return math.ceil(math.abs((aX - (bX))^2 + (aY - (bY))^2))
end

function EntityTargetingSystem:setDirectionLock(targetingComponent, state, direction)
	targetingComponent.directionLock = state
	targetingComponent.direction = direction
end

function EntityTargetingSystem:setLockDirection(targetingComponent, direction)
	if targetingComponent.directionLock then
		targetingComponent.direction = direction
	end
end

function EntityTargetingSystem:setSpriteboxQuadByTarget(targetingComponent)
	if targetingComponent.animationChange then
		if targetingComponent.targetHitbox then
			targetingComponent.componentTable.spritebox.direction = 
				self.ENTITY_DIRECTION:getDirection(self:getDirectionToTarget(
				targetingComponent.componentTable.hitbox.x, 
				targetingComponent.componentTable.hitbox.y,
				targetingComponent.targetHitbox))
		elseif targetingComponent.directionLock and targetingComponent.direction then
			targetingComponent.componentTable.spritebox.direction = 
				self.ENTITY_DIRECTION:getDirection(targetingComponent.direction)
		end
	end
end

function EntityTargetingSystem:setSpriteboxQuadByLock(targetingComponent)
	if targetingComponent.animationChange and targetingComponent.directionLock and
		targetingComponent.direction then
		targetingComponent.componentTable.spritebox.direction = 
			self.ENTITY_DIRECTION:getDirection(targetingComponent.direction)
	end
end

function EntityTargetingSystem:getDirectionToTarget(x, y, targetEntity)
	local targetX, targetY = (targetEntity.x + targetEntity.w/2), (targetEntity.y + targetEntity.h/2)
	local atanVal = math.atan2((targetY - y)*-1,(targetX - x))
	if atanVal < 0 then atanVal = (math.pi*2) + atanVal end
	return atanVal
end

function EntityTargetingSystem:isEntityActive(component)
	--modify this to check the entity state
	if component.componentTable.health.healthPoints <= 0 then
		return false
	else
		return true
	end
end

----------------
--Return Module:
----------------

return EntityTargetingSystem