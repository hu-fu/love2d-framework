---------------------
--Entity Idle System:
----------------------

local EntityIdleSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
EntityIdleSystem.EVENT_TYPE = require '/event/EVENT_TYPE'
EntityIdleSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityIdleSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityIdleSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
EntityIdleSystem.IDLE_REQUEST = require '/entity idle/IDLE_REQUEST'
EntityIdleSystem.ACTION_METHODS = require '/action/ACTION_METHOD'

-------------------
--System Variables:
-------------------

EntityIdleSystem.id = SYSTEM_ID.IDLE

EntityIdleSystem.animationRequestPool = EventObjectPool.new(EntityIdleSystem.EVENT_TYPE.ANIMATION, 100)
EntityIdleSystem.actionLoaderRequestPool = EventObjectPool.new(EntityIdleSystem.EVENT_TYPE.ACTION, 100)

EntityIdleSystem.idleComponentTable = {}
EntityIdleSystem.requestStack = {}

EntityIdleSystem.eventDispatcher = nil
EntityIdleSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

EntityIdleSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--set entity component table (request.entityDb)
			EntityIdleSystem:setIdleComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--request into stack
			EntityIdleSystem:addRequestToStack(request)
		end
	}
}

---------------
--Init Methods:
---------------

function EntityIdleSystem:setIdleComponentTable(entityDb)
	self.idleComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.IDLE)
end

function EntityIdleSystem:init()
	
end

---------------
--Exec Methods:
---------------

function EntityIdleSystem:update(dt)
	self:resolveRequestStack()
	
	for i=1, #self.idleComponentTable do
		if self.idleComponentTable[i].state and self.idleComponentTable[i].action then
			self:updateEntity(dt, self.idleComponentTable[i])
		end
	end
	
	self.animationRequestPool:resetCurrentIndex()
	self.actionLoaderRequestPool:resetCurrentIndex()
end

function EntityIdleSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function EntityIdleSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function EntityIdleSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function EntityIdleSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

EntityIdleSystem.resolveRequestMethods = {
	[EntityIdleSystem.IDLE_REQUEST.START_IDLE] = function(self, request)
		self:startIdle(request.idleComponent)
	end,
	
	[EntityIdleSystem.IDLE_REQUEST.STOP_IDLE] = function(self, request)
		self:stopIdle(request.idleComponent)
	end,
	
	[EntityIdleSystem.IDLE_REQUEST.START_IDLE_CUSTOM] = function(self, request)
		if request.actionSetId then
			self:startIdleCustom(request.idleComponent, request.actionSetId, request.actionId)
		else
			self:startIdle(request.idleComponent)
		end
	end,
	
	[EntityIdleSystem.IDLE_REQUEST.STOP_IDLE_CUSTOM] = function(self, request)
		self:stopIdle(request.idleComponent)
	end,
	
	[EntityIdleSystem.IDLE_REQUEST.RESET_IDLE_ACTION] = function(self, request)
		self:resetIdle(request.idleComponent)
	end,
	
	[EntityIdleSystem.IDLE_REQUEST.RESET_IDLE_ACTION_CUSTOM] = function(self, request)
		if request.actionSetId then
			self:resetIdleCustom(request.idleComponent, request.actionSetId, request.actionId)
		else
			self:resetIdle(request.idleComponent)
		end
	end,
}

function EntityIdleSystem:getAction(actionSetId, actionId, idleComponent)
	local eventObj = self.actionLoaderRequestPool:getCurrentAvailableObject()
	
	eventObj.actionSetId = actionSetId
	eventObj.actionId = actionId
	eventObj.component = idleComponent
	eventObj.callback = self:getActionRequestCallbackMethod()
	
	self.eventDispatcher:postEvent(1, 1, eventObj)
	self.actionLoaderRequestPool:incrementCurrentIndex()
end

function EntityIdleSystem:getActionRequestCallbackMethod()
	return function (component, actionObject)
		if actionObject then
			self:setActionOnComponent(component, actionObject) 
			self.ACTION_METHODS:resetAction(component)
			self:startAnimation(component)
		end
	end
end

function EntityIdleSystem:setActionOnComponent(component, actionObject)
	component.action = actionObject
end

function EntityIdleSystem:resetIdle(idleComponent)
	if idleComponent.state then
		self:startIdle(idleComponent)
	end
end

function EntityIdleSystem:resetIdleCustom(idleComponent, actionSetId, actionId)
	if idleComponent.state then
		self:startIdleCustom(idleComponent, actionSetId, actionId)
	end
end

function EntityIdleSystem:startIdleCustom(idleComponent, actionSetId, actionId)
	idleComponent.state = true
	idleComponent.actionSetId = actionSetId
	idleComponent.actionId = actionId
	
	self:getAction(idleComponent.actionSetId, idleComponent.actionId, idleComponent)
end

function EntityIdleSystem:startIdle(idleComponent)
	idleComponent.state = true
	idleComponent.actionSetId = idleComponent.defaultActionSetId
	idleComponent.actionId = idleComponent.defaultActionId
	
	self:getAction(idleComponent.actionSetId, idleComponent.actionId, idleComponent)
end

function EntityIdleSystem:stopIdle(idleComponent)
	idleComponent.state = false
	self:stopAction(idleComponent)
	self:stopAnimation(idleComponent)
end

function EntityIdleSystem:stopAction(idleComponent)
	self.ACTION_METHODS:resetComponent(idleComponent)
end

function EntityIdleSystem:onActionEnd(idleComponent)
	--do nothing
end

function EntityIdleSystem:updateEntity(dt, idleComponent)
	self.ACTION_METHODS:playAction(dt, self, idleComponent)
end

function EntityIdleSystem:startAnimation(idleComponent)
	if idleComponent.action then
		local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
		animationRequest.animationSetId = idleComponent.action.animationSetId
		animationRequest.animationId = idleComponent.action.animationId
		animationRequest.spritebox = idleComponent.componentTable.spritebox
		
		self.eventDispatcher:postEvent(2, 2, animationRequest)
		self.animationRequestPool:incrementCurrentIndex()
	end
end

function EntityIdleSystem:stopAnimation(movementComponent)
	--not needed
end

----------------
--Return module:
----------------

return EntityIdleSystem