require '/controller/mapper/PlayerInputMovementActionMapper'
require '/controller/mapper/PlayerInputTargetingActionMapper'
require '/controller/mapper/PlayerInputSpawnActionMapper'
require '/controller/mapper/PlayerInputEventActionMapper'
require '/controller/mapper/PlayerInputCombatActionMapper'
require '/controller/mapper/PlayerGlobalInputMapper'

GenericPlayerController = {}
GenericPlayerController.__index = GenericPlayerController

setmetatable(GenericPlayerController, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function GenericPlayerController.new ()
	local self = setmetatable ({}, GenericPlayerController)
		
		self.EVENT_TYPES = require '/event/EVENT_TYPE'
		self.INPUT_ACTION = require '/input/PLAYER_SIMULATION_INPUT_ACTION'
		self.OUTPUT_ACTION = require '/controller/OUTPUT_ACTION'
		self.ENTITY_STATE = require '/entity state/ENTITY_STATE'
		self.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
		self.MOVEMENT_REQUEST = require '/entity movement/MOVEMENT_REQUEST'
		self.IDLE_REQUEST = require '/entity idle/IDLE_REQUEST'
		self.TARGETING_REQUEST = require '/target/TARGETING_REQUEST'
		self.SPAWN_REQUEST = require '/spawn/SPAWN_REQUEST'
		self.DESPAWN_REQUEST = require '/despawn/DESPAWN_REQUEST'
		self.COMBAT_REQUEST = require '/combat/COMBAT_REQUEST'
		self.EVENT_REQUEST = require '/entity event/ENTITY_EVENT_REQUEST'
		self.INTERACTION_ID = require '/interaction/INTERACTION'
		self.INTERACTION_TYPE = require '/interaction/INTERACTION_TYPE'
		self.ENTITY_ROLE = require '/entity/ENTITY_ROLE'
		self.entityStateActionMap = require '/entity state/EntityStateActionMap'
		
		self.movementInputMapper = MovementActionMapper.new()
		self.targetingInputMapper = TargetingActionMapper.new()
		self.spawnInputMapper = SpawnActionMapper.new()
		self.despawnInputMapper = SpawnActionMapper.new()
		self.eventInputMapper = EventActionMapper.new()
		self.combatInputMapper = CombatActionMapper.new()
		self.healthInputMapper = nil
		self.globalInputMapper = PlayerGlobalInputMapper.new()
		
		self.output = true
		self.outputList = {}
		
		self:setPlayerInputMappingMethods()
		self:setGameInputMappingMethods()
		self:setEntityOutputMappingMethods()
	return self
end

function GenericPlayerController:setPlayerInputMappingMethods()
	self.playerInputMappingMethods = {
		[self.INPUT_ACTION.NONE] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.MOVE_UP] = function(self, inputComponent)
			self.movementInputMapper:incrementMovementDirectionMapYIndex(-1)
			self.movementInputMapper:incrementMovementRotationMapYIndex(-1)
		end,
		
		[self.INPUT_ACTION.MOVE_LEFT] = function(self, inputComponent)
			self.movementInputMapper:incrementMovementDirectionMapXIndex(-1)
			self.movementInputMapper:incrementMovementRotationMapXIndex(-1)
		end,
		
		[self.INPUT_ACTION.MOVE_DOWN] = function(self, inputComponent)
			self.movementInputMapper:incrementMovementDirectionMapYIndex(1)
			self.movementInputMapper:incrementMovementRotationMapYIndex(1)
		end,
		
		[self.INPUT_ACTION.MOVE_RIGHT] = function(self, inputComponent)
			self.movementInputMapper:incrementMovementDirectionMapXIndex(1)
			self.movementInputMapper:incrementMovementRotationMapXIndex(1)
		end,
		
		[self.INPUT_ACTION.END_MOVE_UP] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.END_MOVE_LEFT] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.END_MOVE_DOWN] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.END_MOVE_RIGHT] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.SET_TARGETING_STATE] = function(self, inputComponent)
			self.targetingInputMapper:setSetState()
		end,
		
		[self.INPUT_ACTION.SEARCH_TARGET] = function(self, inputComponent)
			self.targetingInputMapper:setGetTarget(true)
		end,
		
		[self.INPUT_ACTION.INTERACT_REQUEST] = function(self, inputComponent)
			self.eventInputMapper:setInteractionRequest()
		end,
		
		[self.INPUT_ACTION.ATTACK_A] = function(self, inputComponent)
			self.combatInputMapper:setAttackA()
		end,
		
		[self.INPUT_ACTION.ATTACK_B] = function(self, inputComponent)
			self.combatInputMapper:setAttackB()
		end,
		
		[self.INPUT_ACTION.ATTACK_C] = function(self, inputComponent)
			self.combatInputMapper:setAttackC()
		end,
		
		[self.INPUT_ACTION.CONTINUE_ATTACK_A] = function(self, inputComponent)
			self.combatInputMapper:setContinueAttackA()
		end,
		
		[self.INPUT_ACTION.CONTINUE_ATTACK_B] = function(self, inputComponent)
			self.combatInputMapper:setContinueAttackB()
		end,
		
		[self.INPUT_ACTION.CONTINUE_ATTACK_C] = function(self, inputComponent)
			self.combatInputMapper:setContinueAttackC()
		end,
		
		[self.INPUT_ACTION.END_ATTACK] = function(self, inputComponent)
			self.combatInputMapper:setEndAttack()
		end,
		
		[self.INPUT_ACTION.SPECIAL_MOVE] = function(self, inputComponent)
			self.combatInputMapper:setSpecialMove()
		end,
	}
end

function GenericPlayerController:setGameInputMappingMethods()
	self.gameInputMappingMethods = {
		[self.ENTITY_ACTION.START_SPAWN] = function(self, inputComponent)
			
		end,
		
		[self.ENTITY_ACTION.END_SPAWN] = function(self, inputComponent)
			
		end,
		
		[self.ENTITY_ACTION.START_DESPAWN] = function(self, request, inputComponent)
			
		end,
		
		[self.ENTITY_ACTION.END_DESPAWN] = function(self, request, inputComponent)
			
		end,
		
		[self.ENTITY_ACTION.START_EVENT] = function(self, request, inputComponent)
			
		end,
		
		[self.ENTITY_ACTION.END_EVENT] = function(self, request, inputComponent)
			
		end,
		
		[self.ENTITY_ACTION.LOCKUP] = function(self, request, inputComponent)
			self.combatInputMapper:setLockup()
		end,
		
		[self.ENTITY_ACTION.KNOCKBACK] = function(self, request, inputComponent)
			self.combatInputMapper:setKnockback()
		end,
		
		[self.ENTITY_ACTION.END_COMBAT] = function(self, request, inputComponent)
			self.combatInputMapper:setEndCombat()
		end,
		
		[self.ENTITY_ACTION.FREE_COMBAT] = function(self, request, inputComponent)
			self.combatInputMapper:setFreeCombat()
		end,
		
		[self.ENTITY_ACTION.RESTRICT_COMBAT] = function(self, request, inputComponent)
			self.combatInputMapper:setRestrictCombat()
		end,
	}
end

function GenericPlayerController:setEntityOutputMappingMethods()
	self.entityOutputMappingMethods = {
		[self.OUTPUT_ACTION.SPAWN] = function(self, controllerSystem, stateComponent)
			
		end,
		
		[self.OUTPUT_ACTION.DESPAWN] = function(self, controllerSystem, stateComponent)
			
		end,
		
		[self.OUTPUT_ACTION.MOVEMENT] = function(self, controllerSystem, stateComponent)
			
		end,
		
		[self.OUTPUT_ACTION.TARGETING] = function(self, controllerSystem, stateComponent)
			if self.targetingInputMapper.setState then
				controllerSystem:sendTargetingActionRequest(self.TARGETING_REQUEST.SET_STATE,
					stateComponent.componentTable.targeting)
			elseif self.targetingInputMapper.getTarget then
				controllerSystem:sendTargetingActionRequest(self.TARGETING_REQUEST.SEARCH,
					stateComponent.componentTable.targeting)
			end
		end,
		
		[self.OUTPUT_ACTION.EVENT] = function(self, controllerSystem, stateComponent)
			
		end,
		
		[self.OUTPUT_ACTION.COMBAT] = function(self, controllerSystem, stateComponent)
			controllerSystem:sendCombatActionRequest(self.combatInputMapper.request, 
				stateComponent.componentTable.combat)
		end,
		
		[self.OUTPUT_ACTION.IDLE] = function(self, controllerSystem, stateComponent)
			
		end,
		
		[self.OUTPUT_ACTION.START_MOVEMENT] = function(self, controllerSystem, stateComponent)
			controllerSystem:sendMovementActionRequest(self.MOVEMENT_REQUEST.START_MOVEMENT, 
				stateComponent.componentTable.movement)
		end,
		
		[self.OUTPUT_ACTION.START_IDLE] = function(self, controllerSystem, stateComponent)
			controllerSystem:sendIdleActionRequest(self.IDLE_REQUEST.START_IDLE, 
				stateComponent.componentTable.idle)
		end,
		
		[self.OUTPUT_ACTION.STOP_MOVEMENT] = function(self, controllerSystem, stateComponent)
			controllerSystem:sendMovementActionRequest(self.MOVEMENT_REQUEST.STOP_MOVEMENT, 
				stateComponent.componentTable.movement)
		end,
		
		[self.OUTPUT_ACTION.STOP_IDLE] = function(self, controllerSystem, stateComponent)
			controllerSystem:sendIdleActionRequest(self.IDLE_REQUEST.STOP_IDLE, 
				stateComponent.componentTable.idle)
		end,
		
		[self.OUTPUT_ACTION.START_MOVEMENT_COMBAT] = function(self, controllerSystem, stateComponent)
			if stateComponent.componentTable.combat.action then
				controllerSystem:sendMovementActionRequest(self.MOVEMENT_REQUEST.START_MOVEMENT_CUSTOM, 
					stateComponent.componentTable.movement, 
					stateComponent.componentTable.combat.action.variables.walkAnimationSetId,
					stateComponent.componentTable.combat.action.variables.walkAnimationId)
			else
				controllerSystem:sendMovementActionRequest(self.MOVEMENT_REQUEST.START_MOVEMENT, 
					stateComponent.componentTable.movement)
			end
		end,
		
		[self.OUTPUT_ACTION.START_IDLE_COMBAT] = function(self, controllerSystem, stateComponent)
			if stateComponent.componentTable.combat.action then
				controllerSystem:sendIdleActionRequest(self.IDLE_REQUEST.START_IDLE_CUSTOM, 
					stateComponent.componentTable.idle, 
					stateComponent.componentTable.combat.action.variables.idleActionSetId,
					stateComponent.componentTable.combat.action.variables.idleActionId)
			else
				controllerSystem:sendIdleActionRequest(self.IDLE_REQUEST.START_IDLE, 
					stateComponent.componentTable.idle)
			end
		end,
	}
end

function GenericPlayerController:isActionAllowed(stateId, actionId)
	return self.entityStateActionMap.actionMap[stateId][actionId]
end

function GenericPlayerController:resolvePlayerInput(request, inputComponent)
	self.playerInputMappingMethods[request.inputId](self, inputComponent)
end

function GenericPlayerController:resolveGameInput(controllerSystem, request, inputComponent)
	self.gameInputMappingMethods[request.actionId](self, request, inputComponent)
end

function GenericPlayerController:resolveOutputs(controllerSystem, component)
	--this runs every frame, set some additional checks here 
		--(if entity is moving without rotation then stop it for example)
	
	self.globalInputMapper:getOutputs(self, component.componentTable.input)
	
	for i=#self.outputList, 1, -1 do
		self:resolveOutput(controllerSystem, self.outputList[i], component)
		table.remove(self.outputList)
	end
	
	self:reset()
end

function GenericPlayerController:addOutput(outputId)
	--allow only one output of each type
	
	for i=1, #self.outputList do
		if self.outputList[i] == outputId then
			return nil
		end
	end
	
	table.insert(self.outputList, outputId)
end

function GenericPlayerController:resolveOutput(controllerSystem, outputId, component)
	self.entityOutputMappingMethods[outputId](self, controllerSystem, component.componentTable.actionState)
end

function GenericPlayerController:setEntityState(stateComponent, state)
	stateComponent.state = state
end

function GenericPlayerController:resetGlobalEntityState(stateComponent)
	stateComponent.state = stateComponent.defaultState
end

function GenericPlayerController:reset()
	self.movementInputMapper:resetMapping()
	self.targetingInputMapper:resetMapping()
	self.spawnInputMapper:resetMapping()
	self.despawnInputMapper:resetMapping()
	self.eventInputMapper:resetMapping()
	self.combatInputMapper:resetMapping()
end