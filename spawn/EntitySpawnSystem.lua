---------------------
--Entity Idle System:
----------------------

local EntitySpawnSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
EntitySpawnSystem.EVENT_TYPE = require '/event/EVENT_TYPE'
EntitySpawnSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntitySpawnSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntitySpawnSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
EntitySpawnSystem.ACTION_METHODS = require '/action/ACTION_METHOD'
EntitySpawnSystem.ENTITY_SPAWN_TYPE = require '/spawn/ENTITY_SPAWN_TYPE'
EntitySpawnSystem.ENTITY_SPAWN = require '/spawn/ENTITY_SPAWN'
EntitySpawnSystem.SPAWN_REQUEST = require '/spawn/SPAWN_REQUEST'
EntitySpawnSystem.ANIMATION_REQUEST = require '/animation/ANIMATION_REQUEST'

-------------------
--System Variables:
-------------------

EntitySpawnSystem.id = SYSTEM_ID.ENTITY_SPAWN

EntitySpawnSystem.animationRequestPool = EventObjectPool.new(EntitySpawnSystem.EVENT_TYPE.ANIMATION, 100)
EntitySpawnSystem.actionLoaderRequestPool = EventObjectPool.new(EntitySpawnSystem.EVENT_TYPE.ACTION, 100)
EntitySpawnSystem.entityInputRequestPool = EventObjectPool.new(EntitySpawnSystem.EVENT_TYPE.ENTITY_INPUT, 100)

EntitySpawnSystem.areaSpawnTable = {}
EntitySpawnSystem.spawnComponentTable = {}
EntitySpawnSystem.requestStack = {}

EntitySpawnSystem.eventDispatcher = nil
EntitySpawnSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

EntitySpawnSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--set entity component table (request.entityDb)
			EntitySpawnSystem:setSpawnComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--request into stack
			EntitySpawnSystem:addRequestToStack(request)
		end,
		
		[3] = function(request)
			--set area spawns
			EntitySpawnSystem:setAreaSpawnTable(request.area)
		end
	}
}

---------------
--Init Methods:
---------------

function EntitySpawnSystem:setSpawnComponentTable(entityDb)
	self.spawnComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.SPAWN)
end

function EntitySpawnSystem:setAreaSpawnTable(area)
	self.areaSpawnTable = area.spawn
end

function EntitySpawnSystem:initScene()
	self:spawnAllEntities()
end

function EntitySpawnSystem:init()
	
end

---------------
--Exec Methods:
---------------

function EntitySpawnSystem:update(dt)
	self:resolveRequestStack()
	
	for i=1, #self.spawnComponentTable do
		if self.spawnComponentTable[i].state then
			if self.spawnComponentTable[i].action then
				self:updateEntity(dt, self.spawnComponentTable[i])
			else
				self:spawnEntity(self.spawnComponentTable[i])
			end
		end
	end
	
	self.animationRequestPool:resetCurrentIndex()
	self.actionLoaderRequestPool:resetCurrentIndex()
	self.entityInputRequestPool:resetCurrentIndex()
end

function EntitySpawnSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function EntitySpawnSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function EntitySpawnSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function EntitySpawnSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

EntitySpawnSystem.resolveRequestMethods = {
	[EntitySpawnSystem.SPAWN_REQUEST.SPAWN_ENTITY] = function(self, request)
		self:spawnEntity(request.spawnComponent)
	end
}

function EntitySpawnSystem:getAreaSpawnById(spawnId)
	for i=1, #self.areaSpawnTable do
		if self.areaSpawnTable[i].id == spawnId then
			return self.areaSpawnTable[i]
		end
	end
end

function EntitySpawnSystem:getAction(actionSetId, actionId, spawnComponent)
	local eventObj = self.actionLoaderRequestPool:getCurrentAvailableObject()
	
	eventObj.actionSetId = actionSetId
	eventObj.actionId = actionId
	eventObj.component = spawnComponent
	eventObj.callback = self:getActionRequestCallbackMethod()
	
	self.eventDispatcher:postEvent(1, 1, eventObj)
	self.actionLoaderRequestPool:incrementCurrentIndex()
end

function EntitySpawnSystem:getActionRequestCallbackMethod()
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

function EntitySpawnSystem:setActionOnComponent(component, actionObject)
	component.action = actionObject
end

function EntitySpawnSystem:setComponentState(spawnComponent, state)
	spawnComponent.state = state
end

function EntitySpawnSystem:spawnAllEntities()
	for i=1, #self.spawnComponentTable do
		self:spawnEntity(self.spawnComponentTable[i])
	end
end

function EntitySpawnSystem:spawnEntity(spawnComponent)
	self:setComponentState(spawnComponent, true)
	self:modifyEntitySpawn(spawnComponent)
	self:runScript(spawnComponent)
	self:startAction(spawnComponent)
end

function EntitySpawnSystem:modifyEntitySpawn(spawnComponent)
	--if entity contains an areaSpawnId spawn it at areaSpawn(x,y), 
		--else just use the entity default x,y
	
	if spawnComponent.areaSpawnId then
		local areaSpawn = self:getAreaSpawnById(spawnComponent.areaSpawnId)
		
		if areaSpawn then
			local spritebox = spawnComponent.componentTable.spritebox
			local hitbox = spawnComponent.componentTable.hitbox
			
			if spritebox then
				spritebox.x = areaSpawn.x - (spritebox.w/2)
				spritebox.y = areaSpawn.y - (spritebox.h/2)
			end
			
			if hitbox then
				hitbox.x = spritebox.x + hitbox.xDeviation
				hitbox.y = spritebox.y + hitbox.yDeviation
			end
		end
	end
	
	spawnComponent.areaSpawnId = nil
end

function EntitySpawnSystem:runScript(spawnComponent)
	if spawnComponent.scriptId then
		self.ENTITY_SPAWN[spawnComponent.scriptId](self, spawnComponent)
	end
end

function EntitySpawnSystem:startAction(spawnComponent)
	if spawnComponent.actionId then
		if not spawnComponent.action then
			self:getAction(spawnComponent.actionSetId, spawnComponent.actionId, spawnComponent)
		else
			self.ACTION_METHODS:resetAction(spawnComponent)
			self:startAnimation(spawnComponent)
		end
	else
		self:onActionEnd(spawnComponent)
	end
end

function EntitySpawnSystem:endState(spawnComponent)
	self:setComponentState(spawnComponent, false)
	
	local eventObj = self.entityInputRequestPool:getCurrentAvailableObject()
	
	eventObj.actionId = self.ENTITY_ACTION.END_SPAWN
	eventObj.inputComponent = spawnComponent.componentTable.input
	
	self.eventDispatcher:postEvent(3, 4, eventObj)
	self.entityInputRequestPool:incrementCurrentIndex()
end

function EntitySpawnSystem:onActionEnd(spawnComponent)
	self:endState(spawnComponent)
end

function EntitySpawnSystem:updateEntity(dt, spawnComponent)
	self.ACTION_METHODS:playAction(dt, self, spawnComponent)
end

function EntitySpawnSystem:startAnimation(spawnComponent)
	if spawnComponent.action and spawnComponent.action.animationId then
		local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
		animationRequest.requestType = self.ANIMATION_REQUEST.SET_ANIMATION
		animationRequest.animationSetId = spawnComponent.action.animationSetId
		animationRequest.animationId = spawnComponent.action.animationId
		animationRequest.spritebox = spawnComponent.componentTable.spritebox
		
		self.eventDispatcher:postEvent(2, 2, animationRequest)
		self.animationRequestPool:incrementCurrentIndex()
	end
end

function EntitySpawnSystem:stopAnimation(movementComponent)
	--not needed
end

----------------
--Return module:
----------------

return EntitySpawnSystem