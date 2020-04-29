--needs a revision once all the state systems are finished - very important!
--FULL OF SPAGHETTI!!! It's cool, this can be the last thing we make
--bugs up the ass
--deprecated

require '/controller/PlayerEntityController'

local GenericController = PlayerEntityController.new(0)

require '/event/EventObjectPool'
require '/controller/EntityInputMovementActionMapper'
require '/controller/EntityInputTargetingActionMapper'
require '/controller/EntityInputSpawnActionMapper'
require '/controller/EntityInputEventActionMapper'
require '/controller/EntityInputCombatActionMapper'
GenericController.EVENT_TYPES = require '/event/EVENT_TYPE'
GenericController.INPUT_ACTION = require '/input/PLAYER_SIMULATION_INPUT_ACTION'
GenericController.ENTITY_STATE = require '/entity state/ENTITY_STATE'
GenericController.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
GenericController.MOVEMENT_REQUEST = require '/entity movement/MOVEMENT_REQUEST'
GenericController.IDLE_REQUEST = require '/entity idle/IDLE_REQUEST'
GenericController.TARGETING_REQUEST = require '/target/TARGETING_REQUEST'
GenericController.SPAWN_REQUEST = require '/spawn/SPAWN_REQUEST'
GenericController.DESPAWN_REQUEST = require '/despawn/DESPAWN_REQUEST'
GenericController.COMBAT_REQUEST = require '/combat/COMBAT_REQUEST'
GenericController.EVENT_REQUEST = require '/entity event/ENTITY_EVENT_REQUEST'
GenericController.INTERACTION_ID = require '/interaction/INTERACTION'
GenericController.INTERACTION_TYPE = require '/interaction/INTERACTION_TYPE'
GenericController.ENTITY_ROLE = require '/entity/ENTITY_ROLE'
GenericController.entityStateActionMap = require '/entity state/EntityStateActionMap'
GenericController.movementActionMapper = MovementActionMapper.new()
GenericController.targetingActionMapper = TargetingActionMapper.new()
GenericController.spawnActionMapper = SpawnActionMapper.new()
GenericController.eventActionMapper = EventActionMapper.new()
GenericController.combatActionMapper = CombatActionMapper.new()

GenericController.movementRequestPool = EventObjectPool.new(GenericController.EVENT_TYPES.MOVEMENT, 5)
GenericController.idleRequestPool = EventObjectPool.new(GenericController.EVENT_TYPES.IDLE, 5)
GenericController.targetingRequestPool = EventObjectPool.new(GenericController.EVENT_TYPES.TARGETING, 5)
GenericController.despawnRequestPool = EventObjectPool.new(GenericController.EVENT_TYPES.ENTITY_DESPAWN, 5)
GenericController.interactionRequestPool = EventObjectPool.new(GenericController.EVENT_TYPES.INTERACTION, 5)
GenericController.entityEventRequestPool = EventObjectPool.new(GenericController.EVENT_TYPES.ENTITY_EVENT, 5)
GenericController.entityCombatRequestPool = EventObjectPool.new(GenericController.EVENT_TYPES.ENTITY_COMBAT, 5)

GenericController.actionRequestMap = {
	spawn = false,
	movement = false,
	targeting = false,
	event = false,
	combat = false
}

function GenericController:resolvePlayerInput(controllerSystem, input, inputComponent)
	self.playerInputMappingMethods[input](self, input)
end

function GenericController:resolveEntityInput(controllerSystem, request, stateComponent)
	self.entityInputMappingMethods[request.actionId](self, request.actionId)
end

function GenericController:resolveState(controllerSystem, inputComponent)
	self:requestEntityAction(controllerSystem, inputComponent.componentTable.actionState)
end

function GenericController:reset()
	self.movementRequestPool:resetCurrentIndex()
	self.idleRequestPool:resetCurrentIndex()
	self.targetingRequestPool:resetCurrentIndex()
	self.despawnRequestPool:resetCurrentIndex()
	self.interactionRequestPool:resetCurrentIndex()
	self.entityEventRequestPool:resetCurrentIndex()
	self.entityCombatRequestPool:resetCurrentIndex()
end

function GenericController:setGlobalEntityState(stateComponent, state)
	stateComponent.state = state
end

function GenericController:resetGlobalEntityState(stateComponent)
	stateComponent.state = stateComponent.defaultState
end

function GenericController:isActionAllowed(stateId, actionId)
	return self.entityStateActionMap.actionMap[stateId][actionId]
end

function GenericController:requestEntityAction(controllerSystem, stateComponent)
	--this has to be improved; all those ifs should be elseifs or switch by priority order
	
	if self.actionRequestMap.spawn then
		self:requestSpawnAction(controllerSystem, stateComponent)
		self.spawnActionMapper:resetMapping()
	end
	
	self:requestMovementAction(controllerSystem, stateComponent)
	self.actionRequestMap.movement = false
	self.movementActionMapper:resetMapping()
	
	if self.actionRequestMap.targeting then
		self:requestTargetingAction(controllerSystem, stateComponent)
		self.actionRequestMap.targeting = false
		self.targetingActionMapper:resetMapping()
	end
	
	if self.actionRequestMap.event then
		self:requestEventAction(controllerSystem, stateComponent)
		self.actionRequestMap.event = false
		self.eventActionMapper:resetMapping()
	end
	
	if self.actionRequestMap.combat then
		self:requestCombatAction(controllerSystem, stateComponent)
		self.actionRequestMap.combat = false
		self.combatActionMapper:resetMapping()
	end
end

function GenericController:requestSpawnAction(controllerSystem, stateComponent)
	--YOU MIGHT WANT TO TEST IF ACTION ALLOWED YOU ABSOLUTE MADMAN:
	
	if self.spawnActionMapper.startSpawn then
		--we can call this on an entity with an associated script that changes its role
		--think of the possibilities: using area scripts to spawn previously loaded entities
		--what an absolute genius
	elseif self.spawnActionMapper.endSpawn then
		stateComponent.componentTable.spawn.state = false
		stateComponent.state = self.ENTITY_STATE.FREE
		self:requestIdleAction(controllerSystem, stateComponent, self.IDLE_REQUEST.START_IDLE)
	elseif self.spawnActionMapper.startDespawn then
		stateComponent.state = self.ENTITY_STATE.DESPAWN
		local despawnComponent = stateComponent.componentTable.despawn
		local despawnSystemRequest = self.despawnRequestPool:getCurrentAvailableObject()
		despawnSystemRequest.requestType = self.DESPAWN_REQUEST.DESPAWN_ENTITY
		despawnSystemRequest.despawnComponent = despawnComponent
		controllerSystem.eventDispatcher:postEvent(4, 2, despawnSystemRequest)
		self.despawnRequestPool:incrementCurrentIndex()
	elseif self.spawnActionMapper.endDespawn then
		--it's ded bro
	end
end

function GenericController:requestMovementAction(controllerSystem, stateComponent)
	--literally hitler (just for testing, needs rewrite):
	
	if not stateComponent.componentTable.movement.state then
		if self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.MOVE) 
			and self.movementActionMapper:getCurrentMovementRotation() then
			
			local movementComponent = stateComponent.componentTable.movement
			movementComponent.rotation = self.movementActionMapper:getCurrentMovementRotation()
			
			local movementSystemRequest = self.movementRequestPool:getCurrentAvailableObject()
			movementSystemRequest.requestType = self.MOVEMENT_REQUEST.START_MOVEMENT
			movementSystemRequest.movementComponent = movementComponent
			controllerSystem.eventDispatcher:postEvent(1, 2, movementSystemRequest)
			self.movementRequestPool:incrementCurrentIndex()
			
			self:requestIdleAction(controllerSystem, stateComponent, self.IDLE_REQUEST.STOP_IDLE)
		end
	else
		if self.movementActionMapper:getCurrentMovementRotation() and 
			self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.MOVE) then
			
			local movementComponent = stateComponent.componentTable.movement
			movementComponent.rotation = self.movementActionMapper:getCurrentMovementRotation()
		else
			local movementComponent = stateComponent.componentTable.movement
			local movementSystemRequest = self.movementRequestPool:getCurrentAvailableObject()
			movementSystemRequest.requestType = self.MOVEMENT_REQUEST.STOP_MOVEMENT
			movementSystemRequest.movementComponent = movementComponent
			controllerSystem.eventDispatcher:postEvent(1, 2, movementSystemRequest)
			self.movementRequestPool:incrementCurrentIndex()
			
			--send idle
			self:requestIdleAction(controllerSystem, stateComponent, self.IDLE_REQUEST.START_IDLE)
		end
	end
end

function GenericController:requestIdleAction(controllerSystem, stateComponent, requestType)
	if self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.IDLE) then
		local idleComponent = stateComponent.componentTable.idle
		local idleSystemRequest = self.idleRequestPool:getCurrentAvailableObject()
		idleSystemRequest.requestType = requestType
		idleSystemRequest.idleComponent = idleComponent
		controllerSystem.eventDispatcher:postEvent(2, 2, idleSystemRequest)
		self.idleRequestPool:incrementCurrentIndex()
	end
end

function GenericController:requestTargetingAction(controllerSystem, stateComponent)
	if self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.TARGETING_SET_STATE) then
		local requestType = self.TARGETING_REQUEST.SET_STATE
		
		if self.targetingActionMapper.setState then
			requestType = self.TARGETING_REQUEST.SET_STATE
		elseif self.targetingActionMapper.getTarget then
			requestType = self.TARGETING_REQUEST.SEARCH
		end
		
		local targetingComponent = stateComponent.componentTable.targeting
		local targetingSystemRequest = self.targetingRequestPool:getCurrentAvailableObject()
		targetingSystemRequest.requestType = requestType
		targetingSystemRequest.targetingComponent = targetingComponent
		controllerSystem.eventDispatcher:postEvent(3, 2, targetingSystemRequest)
		self.targetingRequestPool:incrementCurrentIndex()
	end
end

function GenericController:requestEventAction(controllerSystem, stateComponent)
	if self.eventActionMapper.endEvent and
		self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.END_EVENT) then
		stateComponent.state = self.ENTITY_STATE.FREE
		
	elseif self.eventActionMapper.startEvent and
		self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.START_EVENT) then
		stateComponent.state = self.ENTITY_STATE.EVENT
		local eventSystemRequest = self.entityEventRequestPool:getCurrentAvailableObject()
		
		eventSystemRequest.requestType = self.EVENT_REQUEST.START_EVENT
		eventSystemRequest.eventComponent = stateComponent.componentTable.event
		
		controllerSystem.eventDispatcher:postEvent(6, 3, eventSystemRequest)
		self.entityEventRequestPool:incrementCurrentIndex()
		
	elseif self.eventActionMapper.interactionRequest and
		self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.INTERACT_REQUEST) then
		local interactionSystemRequest = self.interactionRequestPool:getCurrentAvailableObject()
		
		interactionSystemRequest.interactionType = self.INTERACTION_TYPE.GENERIC
		interactionSystemRequest.interactionId = self.INTERACTION_ID.GENERIC
		
		local hitbox = stateComponent.componentTable.hitbox
		interactionSystemRequest.x = hitbox.x - 50
		interactionSystemRequest.y = hitbox.y - 50
		interactionSystemRequest.w = hitbox.w + 100
		interactionSystemRequest.h = hitbox.h + 100
		
		interactionSystemRequest.originEntity = stateComponent.componentTable.main
		interactionSystemRequest.targetRole = {self.ENTITY_ROLE.HOSTILE_NPC}	--change obviously
		
		controllerSystem.eventDispatcher:postEvent(5, 1, interactionSystemRequest)
		self.interactionRequestPool:incrementCurrentIndex()
	end
end

function GenericController:requestCombatAction(controllerSystem, stateComponent)
	if self.combatActionMapper.request == self.COMBAT_REQUEST.END_COMBAT then
		stateComponent.state = self.ENTITY_STATE.FREE
		self:requestIdleAction(controllerSystem, stateComponent, self.IDLE_REQUEST.START_IDLE)
		
	elseif self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.START_COMBAT) then
		--WARNING!
			--setting the entity state as combat here is a bad idea,
			--sometimes the action may not be allowed by the combat system, 
			--leading to a comeback message to close state
			--the instant opening and closing of the state causes jankiness in the current state action
		
		stateComponent.state = self.ENTITY_STATE.COMBAT
		self:sendCombatActionRequest(controllerSystem, self.combatActionMapper.request, 
			stateComponent.componentTable.combat)
		
	else
		--not allowed nuh uh uh
	end
end

function GenericController:sendCombatActionRequest(controllerSystem, requestType, combatComponent)
	local combatSystemRequest = self.entityCombatRequestPool:getCurrentAvailableObject()
	
	combatSystemRequest.requestType = requestType
	combatSystemRequest.combatComponent = combatComponent
	
	controllerSystem.eventDispatcher:postEvent(7, 2, combatSystemRequest)
	self.entityEventRequestPool:incrementCurrentIndex()
end

GenericController.playerInputMappingMethods = {
	[GenericController.INPUT_ACTION.NONE] = function(self, input)
		
	end,
	
	[GenericController.INPUT_ACTION.MOVE_UP] = function(self, input)
		self.movementActionMapper:incrementMovementDirectionMapYIndex(-1)
		self.movementActionMapper:incrementMovementRotationMapYIndex(-1)
		self.actionRequestMap.movement = true
	end,
	
	[GenericController.INPUT_ACTION.MOVE_LEFT] = function(self, input)
		self.movementActionMapper:incrementMovementDirectionMapXIndex(-1)
		self.movementActionMapper:incrementMovementRotationMapXIndex(-1)
		self.actionRequestMap.movement = true
	end,
	
	[GenericController.INPUT_ACTION.MOVE_DOWN] = function(self, input)
		self.movementActionMapper:incrementMovementDirectionMapYIndex(1)
		self.movementActionMapper:incrementMovementRotationMapYIndex(1)
		self.actionRequestMap.movement = true
	end,
	
	[GenericController.INPUT_ACTION.MOVE_RIGHT] = function(self, input)
		self.movementActionMapper:incrementMovementDirectionMapXIndex(1)
		self.movementActionMapper:incrementMovementRotationMapXIndex(1)
		self.actionRequestMap.movement = true
	end,
	
	[GenericController.INPUT_ACTION.SET_TARGETING_STATE] = function(self, input)
		self.targetingActionMapper:setSetState(true)
		self.actionRequestMap.targeting = true
	end,
	
	[GenericController.INPUT_ACTION.SEARCH_TARGET] = function(self, input)
		self.targetingActionMapper:setGetTarget(true)
		self.actionRequestMap.targeting = true
	end,
	
	[GenericController.INPUT_ACTION.INTERACT_REQUEST] = function(self, input)
		self.eventActionMapper:setInteractionRequest()
		self.actionRequestMap.event = true
	end,
	
	[GenericController.INPUT_ACTION.ATTACK_A] = function(self, request)
		self.combatActionMapper:setAttackA()
		self.actionRequestMap.combat = true
	end,
	
	[GenericController.INPUT_ACTION.ATTACK_B] = function(self, request)
		self.combatActionMapper:setAttackB()
		self.actionRequestMap.combat = true
	end,
	
	[GenericController.INPUT_ACTION.ATTACK_C] = function(self, request)
		self.combatActionMapper:setAttackC()
		self.actionRequestMap.combat = true
	end,
	
	[GenericController.INPUT_ACTION.END_ATTACK] = function(self, request)
		self.combatActionMapper:setEndAttack()
		self.actionRequestMap.combat = true
	end,
	
	[GenericController.INPUT_ACTION.SPECIAL_MOVE] = function(self, request)
		self.combatActionMapper:setSpecialMove()
		self.actionRequestMap.combat = true
	end,
}

GenericController.entityInputMappingMethods = {
	[GenericController.ENTITY_ACTION.START_SPAWN] = function(self, request)
		self.spawnActionMapper:setStartSpawn()
		self.actionRequestMap.spawn = true
	end,
	
	[GenericController.ENTITY_ACTION.END_SPAWN] = function(self, request)
		self.spawnActionMapper:setEndSpawn()
		self.actionRequestMap.spawn = true
	end,
	
	[GenericController.ENTITY_ACTION.START_DESPAWN] = function(self, request)
		self.spawnActionMapper:setStartDespawn()
		self.actionRequestMap.spawn = true
	end,
	
	[GenericController.ENTITY_ACTION.END_DESPAWN] = function(self, request)
		self.spawnActionMapper:setEndDespawn()
		self.actionRequestMap.spawn = true
	end,
	
	[GenericController.ENTITY_ACTION.START_EVENT] = function(self, request)
		self.eventActionMapper:setStartEvent()
		self.actionRequestMap.event = true
	end,
	
	[GenericController.ENTITY_ACTION.END_EVENT] = function(self, request)
		self.eventActionMapper:setEndEvent()
		self.actionRequestMap.event = true
	end,
	
	[GenericController.ENTITY_ACTION.LOCKUP] = function(self, request)
		self.combatActionMapper:setLockup()
		self.actionRequestMap.combat = true
	end,
	
	[GenericController.ENTITY_ACTION.KNOCKBACK] = function(self, request)
		self.combatActionMapper:setKnockback()
		self.actionRequestMap.combat = true
	end,
	
	[GenericController.ENTITY_ACTION.END_COMBAT] = function(self, request)
		self.combatActionMapper:setEndCombat()
		self.actionRequestMap.combat = true
	end,
}

return GenericController