---------------------
--Entity Idle System:
----------------------

local EntityDespawnSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
EntityDespawnSystem.EVENT_TYPE = require '/event/EVENT_TYPE'
EntityDespawnSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityDespawnSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityDespawnSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
EntityDespawnSystem.ACTION_METHODS = require '/action/ACTION_METHOD'
EntityDespawnSystem.ENTITY_DESPAWN_TYPE = require '/despawn/ENTITY_DESPAWN_TYPE'
EntityDespawnSystem.ENTITY_DESPAWN = require '/despawn/ENTITY_DESPAWN'
EntityDespawnSystem.DESPAWN_REQUEST = require '/despawn/DESPAWN_REQUEST'
EntityDespawnSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
EntityDespawnSystem.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'

-------------------
--System Variables:
-------------------

EntityDespawnSystem.id = SYSTEM_ID.ENTITY_DESPAWN

EntityDespawnSystem.animationRequestPool = EventObjectPool.new(EntityDespawnSystem.EVENT_TYPE.ANIMATION, 25)
EntityDespawnSystem.actionLoaderRequestPool = EventObjectPool.new(EntityDespawnSystem.EVENT_TYPE.ACTION, 25)
EntityDespawnSystem.entityInputRequestPool = EventObjectPool.new(EntityDespawnSystem.EVENT_TYPE.ENTITY_INPUT, 100)
EntityDespawnSystem.targetingRequestPool = EventObjectPool.new(EntityDespawnSystem.EVENT_TYPE.TARGETING, 25)

function EntityDespawnSystem:spatialQueryDefaultCallbackMethod() return function () end end
EntityDespawnSystem.spatialSystemRequestPool = EventObjectPool.new(EntityDespawnSystem.EVENT_TYPE.SPATIAL_REQUEST, 25)
EntityDespawnSystem.unregisterEntitySpatialQueryPool = SpatialQueryPool.new(25, EntityDespawnSystem.QUERY_TYPES.UNREGISTER_ENTITY, 
	SpatialQueryBuilder.new(), EntityDespawnSystem:spatialQueryDefaultCallbackMethod())

EntityDespawnSystem.despawnComponentTable = {}
EntityDespawnSystem.requestStack = {}

EntityDespawnSystem.eventDispatcher = nil
EntityDespawnSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

EntityDespawnSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--set entity component table (request.entityDb)
			EntityDespawnSystem:setDespawnComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--request into stack
			EntityDespawnSystem:addRequestToStack(request)
		end
	}
}

---------------
--Init Methods:
---------------

function EntityDespawnSystem:setDespawnComponentTable(entityDb)
	self.despawnComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.DESPAWN)
end

function EntityDespawnSystem:init()
	
end

---------------
--Exec Methods:
---------------

function EntityDespawnSystem:update(dt)
	self:resolveRequestStack()
	
	for i=1, #self.despawnComponentTable do
		if self.despawnComponentTable[i].state then
			self:updateEntity(dt, self.despawnComponentTable[i])
		end
	end
	
	self.animationRequestPool:resetCurrentIndex()
	self.actionLoaderRequestPool:resetCurrentIndex()
	self.entityInputRequestPool:resetCurrentIndex()
	self.spatialSystemRequestPool:resetCurrentIndex()
	self.unregisterEntitySpatialQueryPool:resetCurrentIndex()
	self.targetingRequestPool:resetCurrentIndex()
end

function EntityDespawnSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function EntityDespawnSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function EntityDespawnSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function EntityDespawnSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

EntityDespawnSystem.resolveRequestMethods = {
	[EntityDespawnSystem.DESPAWN_REQUEST.DESPAWN_ENTITY] = function(self, request)
		self:despawnEntity(request.despawnComponent, request.actionSetId, request.actionId)
	end
}

function EntityDespawnSystem:getAction(actionSetId, actionId, despawnComponent)
	local eventObj = self.actionLoaderRequestPool:getCurrentAvailableObject()
	
	eventObj.actionSetId = actionSetId
	eventObj.actionId = actionId
	eventObj.component = despawnComponent
	eventObj.callback = self:getActionRequestCallbackMethod()
	
	self.eventDispatcher:postEvent(1, 1, eventObj)
	self.actionLoaderRequestPool:incrementCurrentIndex()
end

function EntityDespawnSystem:getActionRequestCallbackMethod()
	return function (component, actionObject)
		if actionObject then
			self:setActionOnComponent(component, actionObject)
			self.ACTION_METHODS:resetAction(component)
			self:startAnimation(component)
		else
			self:onActionEnd(component)
		end
	end
end

function EntityDespawnSystem:setActionOnComponent(component, actionObject)
	component.action = actionObject
end

function EntityDespawnSystem:setComponentState(despawnComponent, state)
	despawnComponent.state = state
end

function EntityDespawnSystem:despawnEntity(despawnComponent, actionSetId, actionId)
	self:setComponentState(despawnComponent, true)
	self:startAction(despawnComponent, actionSetId, actionId)
end

function EntityDespawnSystem:runScript(despawnComponent)
	if despawnComponent.scriptId then
		self.ENTITY_DESPAWN[despawnComponent.scriptId](self, despawnComponent)
	end
end

function EntityDespawnSystem:startAction(despawnComponent, actionSetId, actionId)
	--test this please:
	
	if not despawnComponent.action then
		if actionSetId and actionId then
			self:getAction(actionSetId, actionId, despawnComponent)
		elseif despawnComponent.actionSetId and despawnComponent.actionId then
			self:getAction(despawnComponent.actionSetId, despawnComponent.actionId, despawnComponent)
		else
			self:onActionEnd(despawnComponent)
		end
	else
		--do nothing, action already started / maybe overwrite or reset action / 2muchwork
	end
end

function EntityDespawnSystem:endState(despawnComponent)
	self:setComponentState(despawnComponent, false)
	self:runScript(despawnComponent)
end

function EntityDespawnSystem:onActionEnd(despawnComponent)
	self:endState(despawnComponent)
end

function EntityDespawnSystem:updateEntity(dt, despawnComponent)
	self.ACTION_METHODS:playAction(dt, self, despawnComponent)
end

function EntityDespawnSystem:startAnimation(despawnComponent)
	if despawnComponent.action then
		local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
		animationRequest.animationSetId = despawnComponent.action.animationSetId
		animationRequest.animationId = despawnComponent.action.animationId
		animationRequest.spritebox = despawnComponent.componentTable.spritebox
		
		self.eventDispatcher:postEvent(2, 2, animationRequest)
		self.animationRequestPool:incrementCurrentIndex()
	end
end

function EntityDespawnSystem:stopAnimation(despawnComponent)
	--not needed
end

function EntityDespawnSystem:disableEntity(despawnComponent)
	--removes entity from all systems (wip)
	self:unregisterEntityInSpatialSystem(despawnComponent)
	self:disableEntityInTargetingSystem(despawnComponent)
end

function EntityDespawnSystem:unregisterEntityInSpatialSystem(component)
	local queryObj = self.unregisterEntitySpatialQueryPool:getCurrentAvailableObjectDefault()
	
	queryObj.entityType = self.ENTITY_TYPE.GENERIC_ENTITY
	queryObj.entityRole = component.componentTable.scene.role
	queryObj.entity = component.componentTable.hitbox
	
	local spatialSystemRequest = self.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = queryObj
	self.eventDispatcher:postEvent(3, 1, spatialSystemRequest)
	
	self.unregisterEntitySpatialQueryPool:incrementCurrentIndex()
	self.spatialSystemRequestPool:incrementCurrentIndex()
end

function EntityDespawnSystem:disableEntityInTargetingSystem(component)
	local targetingSystemRequest = self.targetingRequestPool:getCurrentAvailableObject()
	targetingSystemRequest.requestType = 4
	targetingSystemRequest.targetHitbox = component.componentTable.hitbox
	self.eventDispatcher:postEvent(4, 2, targetingSystemRequest)
	self.targetingRequestPool:incrementCurrentIndex()
end

----------------
--Return module:
----------------

return EntityDespawnSystem