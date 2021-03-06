---------------------------
--Entity Controller System:
---------------------------

local EntityControllerSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
EntityControllerSystem.ENTITY_CONTROLLER = require '/controller/ENTITY_CONTROLLER'
EntityControllerSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityControllerSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityControllerSystem.EVENT_TYPE = require '/event/EVENT_TYPE'

-------------------
--System Variables:
-------------------

EntityControllerSystem.id = SYSTEM_ID.ENTITY_CONTROLLER

EntityControllerSystem.inputComponentTable = {}
EntityControllerSystem.activePlayerInputComponent = nil

EntityControllerSystem.playerInputStack = {}
EntityControllerSystem.gameInputStack = {}

EntityControllerSystem.movementRequestPool = EventObjectPool.new(EntityControllerSystem.EVENT_TYPE.MOVEMENT, 25)
EntityControllerSystem.idleRequestPool = EventObjectPool.new(EntityControllerSystem.EVENT_TYPE.IDLE, 25)
EntityControllerSystem.targetingRequestPool = EventObjectPool.new(EntityControllerSystem.EVENT_TYPE.TARGETING, 25)
EntityControllerSystem.spawnRequestPool = EventObjectPool.new(EntityControllerSystem.EVENT_TYPE.ENTITY_SPAWN, 25)
EntityControllerSystem.despawnRequestPool = EventObjectPool.new(EntityControllerSystem.EVENT_TYPE.ENTITY_DESPAWN, 25)
EntityControllerSystem.interactionRequestPool = EventObjectPool.new(EntityControllerSystem.EVENT_TYPE.INTERACTION, 25)
EntityControllerSystem.entityEventRequestPool = EventObjectPool.new(EntityControllerSystem.EVENT_TYPE.ENTITY_EVENT, 25)
EntityControllerSystem.entityCombatRequestPool = EventObjectPool.new(EntityControllerSystem.EVENT_TYPE.ENTITY_COMBAT, 25)
EntityControllerSystem.playerInputRequestPool = EventObjectPool.new(EntityControllerSystem.EVENT_TYPE.PLAYER_INPUT, 10)

----------------
--Event Methods:
----------------

EntityControllerSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			EntityControllerSystem:setInputComponentTable(request.entityDb)
			EntityControllerSystem:selectActivePlayerEntity()
		end,
		
		[2] = function(request)
			--set new active player entity
		end,
		
		[3] = function(request)
			EntityControllerSystem:addPlayerInputToStack(request)
		end,
		
		[4] = function(request)
			EntityControllerSystem:addGameInputToStack(request)
		end
	}
}

---------------
--Init Methods:
---------------

function EntityControllerSystem:setInputComponentTable(entityDb)
	self.inputComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.INPUT)
	
	for i=1, #self.inputComponentTable do
		if not self.inputComponentTable[i].controller then
			self.inputComponentTable[i].controller = self.ENTITY_CONTROLLER[self.inputComponentTable[i].controllerId]()
		end
	end
end

function EntityControllerSystem:init()

end

---------------
--Exec Methods:
---------------

function EntityControllerSystem:update()
	self:resolvePlayerInputRequestStack()
	self:resolveGameInputRequestStack()
	self:resolveEntityOutputs()
	self:reset()
end

function EntityControllerSystem:resolvePlayerInputRequestStack()
	for i=#self.playerInputStack, 1, -1 do
		self:resolvePlayerInput(self.playerInputStack[i])
		self:removePlayerInputFromStack()
	end
end

function EntityControllerSystem:resolveGameInputRequestStack()
	for i=#self.gameInputStack, 1, -1 do
		self:resolveGameInput(self.gameInputStack[i])
		self:removeGameInputFromStack()
	end
end

function EntityControllerSystem:resolveEntityOutputs()
	for i=1, #self.inputComponentTable do
		if self.inputComponentTable[i].controller.output then
			self.inputComponentTable[i].controller:resolveOutputs(self, self.inputComponentTable[i])
		end
	end
end

function EntityControllerSystem:addPlayerInputToStack(request)
	table.insert(self.playerInputStack, request)
end

function EntityControllerSystem:removePlayerInputFromStack()
	table.remove(self.playerInputStack)
end

function EntityControllerSystem:addGameInputToStack(request)
	table.insert(self.gameInputStack, request)
end

function EntityControllerSystem:removeGameInputFromStack()
	table.remove(self.gameInputStack)
end

function EntityControllerSystem:resolvePlayerInput(request)
	if self.activePlayerInputComponent and self.activePlayerInputComponent.state then
		self.activePlayerInputComponent.controller:resolvePlayerInput(request, 
			self.activePlayerInputComponent)
	end
end

function EntityControllerSystem:resolveGameInput(request)
	if request.inputComponent.state then
		request.inputComponent.controller:resolveGameInput(self, request, request.inputComponent)
	end
end

function EntityControllerSystem:selectActivePlayerEntity()
	for i=1, #self.inputComponentTable do
		if self.inputComponentTable[i].playerInputState then
			self:setActivePlayerEntity(self.inputComponentTable[i])
			break
		end
	end
end

function EntityControllerSystem:setActivePlayerEntity(inputComponent)
	if self.activePlayerInputComponent then
		self.activePlayerInputComponent.playerInputState = false
	end
	
	self.activePlayerInputComponent = inputComponent
	self.activePlayerInputComponent.playerInputState = true
end

function EntityControllerSystem:changeEntityController(inputComponent, controllerId)
	inputComponent.controller = self.ENTITY_CONTROLLER[controllerId]
end

function EntityControllerSystem:resetEntityController(inputComponent)
	inputComponent.controller = self.ENTITY_CONTROLLER[inputComponent.defaultControllerId]
end

function EntityControllerSystem:addPlayerInputRequest(inputId)
	local request = self.playerInputRequestPool:getCurrentAvailableObject()
	request.inputId = inputId
	self:addPlayerInputToStack(request)
	inputSystem.playerInputRequestPool:incrementCurrentIndex()
end

function EntityControllerSystem:sendMovementActionRequest(requestType, movementComponent, animationSetId, 
	animationId)
	local movementSystemRequest = self.movementRequestPool:getCurrentAvailableObject()
	movementSystemRequest.requestType = requestType
	movementSystemRequest.animationSetId = animationSetId
	movementSystemRequest.animationId = animationId
	movementSystemRequest.movementComponent = movementComponent
	self.eventDispatcher:postEvent(1, 2, movementSystemRequest)
	self.movementRequestPool:incrementCurrentIndex()
end

function EntityControllerSystem:sendIdleActionRequest(requestType, idleComponent, actionSetId, actionId)
	local idleSystemRequest = self.idleRequestPool:getCurrentAvailableObject()
	idleSystemRequest.requestType = requestType
	idleSystemRequest.actionSetId = actionSetId
	idleSystemRequest.actionId = actionId
	idleSystemRequest.idleComponent = idleComponent
	self.eventDispatcher:postEvent(2, 2, idleSystemRequest)
	self.idleRequestPool:incrementCurrentIndex()
end

function EntityControllerSystem:requestEventAction(requestType, eventComponent)
	
end

function EntityControllerSystem:sendTargetingActionRequest(requestType, targetingComponent)
	local targetingSystemRequest = self.targetingRequestPool:getCurrentAvailableObject()
	targetingSystemRequest.requestType = requestType
	targetingSystemRequest.targetingComponent = targetingComponent
	self.eventDispatcher:postEvent(3, 2, targetingSystemRequest)
	self.targetingRequestPool:incrementCurrentIndex()
end

function EntityControllerSystem:sendCombatActionRequest(requestType, combatComponent)
	local combatSystemRequest = self.entityCombatRequestPool:getCurrentAvailableObject()
	combatSystemRequest.requestType = requestType
	combatSystemRequest.combatComponent = combatComponent
	self.eventDispatcher:postEvent(7, 2, combatSystemRequest)
	self.entityCombatRequestPool:incrementCurrentIndex()
end

function EntityControllerSystem:sendSpawnActionRequest(requestType, spawnComponent)
	
end

function EntityControllerSystem:sendDespawnActionRequest(requestType, despawnComponent)
	
end

function EntityControllerSystem:sendHealthActionRequest(requestType, healthComponent)
	
end

function EntityControllerSystem:reset()
	self.movementRequestPool:resetCurrentIndex()
	self.idleRequestPool:resetCurrentIndex()
	self.targetingRequestPool:resetCurrentIndex()
	self.spawnRequestPool:resetCurrentIndex()
	self.despawnRequestPool:resetCurrentIndex()
	self.interactionRequestPool:resetCurrentIndex()
	self.entityEventRequestPool:resetCurrentIndex()
	self.entityCombatRequestPool:resetCurrentIndex()
	self.playerInputRequestPool:resetCurrentIndex()
end

----------------
--Return module:
----------------

return EntityControllerSystem