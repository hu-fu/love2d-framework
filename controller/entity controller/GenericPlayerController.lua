require '/controller/mapper/PlayerInputMovementActionMapper'
require '/controller/mapper/PlayerInputTargetingActionMapper'
require '/controller/mapper/PlayerInputSpawnActionMapper'
require '/controller/mapper/PlayerInputEventActionMapper'
require '/controller/mapper/PlayerInputCombatActionMapper'

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
		
		self.output = false
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
			self:addOutput(self.OUTPUT_ACTION.MOVEMENT)
		end,
		
		[self.INPUT_ACTION.MOVE_LEFT] = function(self, inputComponent)
			self.movementInputMapper:incrementMovementDirectionMapXIndex(-1)
			self.movementInputMapper:incrementMovementRotationMapXIndex(-1)
			self:addOutput(self.OUTPUT_ACTION.MOVEMENT)
		end,
		
		[self.INPUT_ACTION.MOVE_DOWN] = function(self, inputComponent)
			self.movementInputMapper:incrementMovementDirectionMapYIndex(1)
			self.movementInputMapper:incrementMovementRotationMapYIndex(1)
			self:addOutput(self.OUTPUT_ACTION.MOVEMENT)
		end,
		
		[self.INPUT_ACTION.MOVE_RIGHT] = function(self, inputComponent)
			self.movementInputMapper:incrementMovementDirectionMapXIndex(1)
			self.movementInputMapper:incrementMovementRotationMapXIndex(1)
			self:addOutput(self.OUTPUT_ACTION.MOVEMENT)
		end,
		
		[self.INPUT_ACTION.END_MOVE_UP] = function(self, inputComponent)
			self:addOutput(self.OUTPUT_ACTION.MOVEMENT)
		end,
		
		[self.INPUT_ACTION.END_MOVE_LEFT] = function(self, inputComponent)
			self:addOutput(self.OUTPUT_ACTION.MOVEMENT)
		end,
		
		[self.INPUT_ACTION.END_MOVE_DOWN] = function(self, inputComponent)
			self:addOutput(self.OUTPUT_ACTION.MOVEMENT)
		end,
		
		[self.INPUT_ACTION.END_MOVE_RIGHT] = function(self, inputComponent)
			self:addOutput(self.OUTPUT_ACTION.MOVEMENT)
		end,
		
		[self.INPUT_ACTION.SET_TARGETING_STATE] = function(self, inputComponent)
			self.targetingInputMapper:setSetState(true)
			self:addOutput(self.OUTPUT_ACTION.TARGETING)
		end,
		
		[self.INPUT_ACTION.SEARCH_TARGET] = function(self, inputComponent)
			self.targetingInputMapper:setGetTarget(true)
			self:addOutput(self.OUTPUT_ACTION.TARGETING)
		end,
		
		[self.INPUT_ACTION.INTERACT_REQUEST] = function(self, inputComponent)
			self.eventInputMapper:setInteractionRequest()
			self:addOutput(self.OUTPUT_ACTION.EVENT)
		end,
		
		[self.INPUT_ACTION.ATTACK_A] = function(self, inputComponent)
			self.combatInputMapper:setAttackA()
			self:addOutput(self.OUTPUT_ACTION.COMBAT)
		end,
		
		[self.INPUT_ACTION.ATTACK_B] = function(self, inputComponent)
			self.combatInputMapper:setAttackB()
			self:addOutput(self.OUTPUT_ACTION.COMBAT)
		end,
		
		[self.INPUT_ACTION.ATTACK_C] = function(self, inputComponent)
			self.combatInputMapper:setAttackC()
			self:addOutput(self.OUTPUT_ACTION.COMBAT)
		end,
		
		[self.INPUT_ACTION.END_ATTACK] = function(self, inputComponent)
			self.combatInputMapper:setEndAttack()
			self:addOutput(self.OUTPUT_ACTION.COMBAT)
		end,
		
		[self.INPUT_ACTION.SPECIAL_MOVE] = function(self, inputComponent)
			self.combatInputMapper:setSpecialMove()
			self:addOutput(self.OUTPUT_ACTION.COMBAT)
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
			self:addOutput(self.OUTPUT_ACTION.IDLE)
		end,
		
		[self.ENTITY_ACTION.LOCKUP] = function(self, request, inputComponent)
			self.combatInputMapper:setLockup()
			self:addOutput(self.OUTPUT_ACTION.COMBAT)
		end,
		
		[self.ENTITY_ACTION.KNOCKBACK] = function(self, request, inputComponent)
			self.combatInputMapper:setKnockback()
			self:addOutput(self.OUTPUT_ACTION.COMBAT)
		end,
		
		[self.ENTITY_ACTION.END_COMBAT] = function(self, request, inputComponent)
			local movementComponent = inputComponent.componentTable.movement
			movementComponent.animationSetId = movementComponent.defaultAnimationSetId
			movementComponent.animationId = movementComponent.defaultAnimationId
			
			inputComponent.componentTable.actionState.state = self.ENTITY_STATE.FREE
			
			if not movementComponent.state then
				self:addOutput(self.OUTPUT_ACTION.IDLE)
			end
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
			
			if self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.MOVE) then
				
				if self.movementInputMapper:getCurrentMovementRotation() then
					--if there is direction(rotation) to movement, then move
					
					local movementComponent = stateComponent.componentTable.movement
					movementComponent.rotation = self.movementInputMapper:getCurrentMovementRotation()
					
					if not stateComponent.componentTable.movement.state then
						--if state is stopped then initiate action
						controllerSystem:sendMovementActionRequest(self.MOVEMENT_REQUEST.START_MOVEMENT, 
							movementComponent)
						controllerSystem:sendIdleActionRequest(self.IDLE_REQUEST.STOP_IDLE, 
							stateComponent.componentTable.idle)
					end
				else
					--if there isn't direction(rotation) to movement, then stop
					controllerSystem:sendMovementActionRequest(self.MOVEMENT_REQUEST.STOP_MOVEMENT, 
						stateComponent.componentTable.movement)
					controllerSystem:sendIdleActionRequest(self.IDLE_REQUEST.START_IDLE, 
						stateComponent.componentTable.idle)
				end
			elseif stateComponent.state == self.ENTITY_STATE.COMBAT then
				
				if not stateComponent.componentTable.combat.action or 
					stateComponent.componentTable.combat.action.variables.walk then
					
					if self.movementInputMapper:getCurrentMovementRotation() then
						--if there is direction(rotation) to movement, then move
						
						local movementComponent = stateComponent.componentTable.movement
						movementComponent.rotation = self.movementInputMapper:getCurrentMovementRotation()
						
						if not stateComponent.componentTable.movement.state then
							--if state is stopped then initiate action
							controllerSystem:sendMovementActionRequest(self.MOVEMENT_REQUEST.START_MOVEMENT, 
								movementComponent)
						end
					else
						--if there isn't direction(rotation) to movement, then stop
						controllerSystem:sendMovementActionRequest(self.MOVEMENT_REQUEST.STOP_MOVEMENT, 
							stateComponent.componentTable.movement)
						controllerSystem:sendIdleActionRequest(self.IDLE_REQUEST.START_IDLE, 
							stateComponent.componentTable.idle)
					end
				else
					--not allowed
					controllerSystem:sendMovementActionRequest(self.MOVEMENT_REQUEST.STOP_MOVEMENT, 
						stateComponent.componentTable.movement)
				end
			else
				if stateComponent.componentTable.movement.state then
					--if action isn't allowed but movement is still active:
					controllerSystem:sendMovementActionRequest(self.MOVEMENT_REQUEST.STOP_MOVEMENT, 
						stateComponent.componentTable.movement)
				end
			end
			
			self.movementInputMapper:resetMapping()
		end,
		
		[self.OUTPUT_ACTION.TARGETING] = function(self, controllerSystem, stateComponent)
			if self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.TARGETING_SET_STATE) then
				local requestType = self.TARGETING_REQUEST.SET_STATE
				
				if self.targetingInputMapper.setState then
					requestType = self.TARGETING_REQUEST.SET_STATE
				elseif self.targetingInputMapper.getTarget then
					requestType = self.TARGETING_REQUEST.SEARCH
				end
				
				controllerSystem:sendTargetingActionRequest(requestType, stateComponent.componentTable.targeting)
			end
			
			self.targetingInputMapper:resetMapping()
		end,
		
		[self.OUTPUT_ACTION.EVENT] = function(self, controllerSystem, stateComponent)
			--TODO
		end,
		
		[self.OUTPUT_ACTION.COMBAT] = function(self, controllerSystem, stateComponent)
			if self:isActionAllowed(stateComponent.state, self.ENTITY_ACTION.COMBAT) then
				stateComponent.state = self.ENTITY_STATE.COMBAT
				
				controllerSystem:sendCombatActionRequest(self.combatInputMapper.request, 
					stateComponent.componentTable.combat)
			end
			
			self.combatInputMapper:resetMapping()
		end,
		
		[self.OUTPUT_ACTION.IDLE] = function(self, controllerSystem, stateComponent)
			--only send START_IDLE requests here
			
			if not stateComponent.componentTable.movement.state then
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
	for i=#self.outputList, 1, -1 do
		self:resolveOutput(controllerSystem, self.outputList[i], component)
		table.remove(self.outputList)
	end
	
	self.output = false
end

function GenericPlayerController:addOutput(outputId)
	self.output = true
	
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