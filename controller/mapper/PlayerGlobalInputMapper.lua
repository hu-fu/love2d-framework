----------------
--global mapper:
----------------
--THE """"FINAL"""" SOLUTION!!

PlayerGlobalInputMapper = {}
PlayerGlobalInputMapper.__index = PlayerGlobalInputMapper

setmetatable(PlayerGlobalInputMapper, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function PlayerGlobalInputMapper.new ()
	local self = setmetatable ({}, PlayerGlobalInputMapper)
		self.ENTITY_STATE = require '/entity state/ENTITY_STATE'
		self.OUTPUT_ACTION = require '/controller/OUTPUT_ACTION'
		
		self.getOutputByStateMethods = {}
		self.getStateByStateMethods = {}
		self.cancelStateMethods = {}
		
		self:setGetOuputByStateMethods()
		self:setGetStateByStateMethods()
		self:setCancelStateMethods()
	return self
end

function PlayerGlobalInputMapper:getOutputs(controller, inputComponent)
	local stateComponent = inputComponent.componentTable.actionState
	local newState = self.getStateByStateMethods[stateComponent.state](self, controller, inputComponent)
	
	if stateComponent.state ~= newState then
		self.cancelStateMethods[stateComponent.state](self, controller, inputComponent, newState)
		stateComponent.state = newState
	end
	
	self.getOutputByStateMethods[stateComponent.state](self, controller, inputComponent)
end

function PlayerGlobalInputMapper:setGetStateByStateMethods()
	self.getStateByStateMethods = {
		[self.ENTITY_STATE.FREE] = function(self, controller, inputComponent)
			if controller.spawnInputMapper.startSpawn then
				return self.ENTITY_STATE.SPAWN
			elseif controller.spawnInputMapper.startDespawn then
				return self.ENTITY_STATE.DESPAWN
			elseif controller.combatInputMapper.request then
				return self.ENTITY_STATE.COMBAT_FREE
			elseif controller.eventInputMapper.startEvent or controller.eventInputMapper.eventRequest then
				return self.ENTITY_STATE.EVENT
			else
				return self.ENTITY_STATE.FREE
			end
		end,
		
		[self.ENTITY_STATE.SPAWN] = function(self, controller, inputComponent)
			if controller.spawnInputMapper.endSpawn then
				return self.ENTITY_STATE.FREE
			else
				return self.ENTITY_STATE.SPAWN
			end
		end,
		
		[self.ENTITY_STATE.DESPAWN] = function(self, controller, inputComponent)
			--entity is removed so no point in setting anything here
			return self.ENTITY_STATE.DESPAWN
		end,
		
		[self.ENTITY_STATE.EVENT] = function(self, controller, inputComponent)
			if controller.eventInputMapper.endEvent then
				return self.ENTITY_STATE.FREE
			end
		end,
		
		[self.ENTITY_STATE.COMBAT_FREE] = function(self, controller, inputComponent)
			if controller.combatInputMapper.request == controller.COMBAT_REQUEST.END_COMBAT then
				return self.ENTITY_STATE.FREE
			elseif controller.combatInputMapper.restrictCombat then
				return self.ENTITY_STATE.COMBAT_RESTRICTED
			else
				return self.ENTITY_STATE.COMBAT_FREE
			end
		end,
		
		[self.ENTITY_STATE.COMBAT_RESTRICTED] = function(self, controller, inputComponent)
			if controller.combatInputMapper.request == controller.COMBAT_REQUEST.END_COMBAT then
				return self.ENTITY_STATE.FREE
			elseif controller.combatInputMapper.freeCombat then
				return self.ENTITY_STATE.COMBAT_FREE
			else
				return self.ENTITY_STATE.COMBAT_RESTRICTED
			end
		end,
	}
end

function PlayerGlobalInputMapper:setCancelStateMethods()
	self.cancelStateMethods = {
		[self.ENTITY_STATE.FREE] = function(self, controller, inputComponent, newState)
			--nothing
		end,
		
		[self.ENTITY_STATE.SPAWN] = function(self, controller, inputComponent, newState)
			--spawn component state disabled in the system
		end,
		
		[self.ENTITY_STATE.DESPAWN] = function(self, controller, inputComponent, newState)
			--already dead
		end,
		
		[self.ENTITY_STATE.EVENT] = function(self, controller, inputComponent, newState)
			--TODO
		end,
		
		[self.ENTITY_STATE.COMBAT_FREE] = function(self, controller, inputComponent, newState)
			if newState == self.ENTITY_STATE.EVENT or newState == self.ENTITY_STATE.DESPAWN then
				controller.combatInputMapper:resetMapping()
				controller.combatInputMapper:setEndCombat()
				controller:addOutput(self.OUTPUT_ACTION.COMBAT)
			end
			
			self:resetTargetingMovementModifiers(controller, inputComponent)
		end,
		
		[self.ENTITY_STATE.COMBAT_RESTRICTED] = function(self, controller, inputComponent, newState)
			if newState == self.ENTITY_STATE.EVENT or newState == self.ENTITY_STATE.DESPAWN then
				controller.combatInputMapper:resetMapping()
				controller.combatInputMapper:setEndCombat()
				controller:addOutput(self.OUTPUT_ACTION.COMBAT)
			end
			
			self:resetTargetingMovementModifiers(controller, inputComponent)
		end,
	}
end

function PlayerGlobalInputMapper:setGetOuputByStateMethods()
	self.getOutputByStateMethods = {
		[self.ENTITY_STATE.FREE] = function(self, controller, inputComponent)
			self:getMovementOutput(controller, inputComponent)
			self:getTargetingOutput(controller, inputComponent)
		end,
		
		[self.ENTITY_STATE.SPAWN] = function(self, controller, inputComponent)
			if controller.spawnInputMapper.startSpawn then
				controller:addOutput(self.OUTPUT_ACTION.SPAWN)
				controller:addOutput(self.OUTPUT_ACTION.STOP_MOVEMENT)
			end
		end,
		
		[self.ENTITY_STATE.DESPAWN] = function(self, controller, inputComponent)
			if controller.spawnInputMapper.startDespawn then
				controller:addOutput(self.OUTPUT_ACTION.DESPAWN)
				controller:addOutput(self.OUTPUT_ACTION.STOP_MOVEMENT)
			end
		end,
		
		[self.ENTITY_STATE.EVENT] = function(self, controller, inputComponent)
			if controller.eventInputMapper.interactionRequest then
				controller:addOutput(self.OUTPUT_ACTION.EVENT)
				controller:addOutput(self.OUTPUT_ACTION.STOP_MOVEMENT)
			elseif controller.eventInputMapper.startEvent then
				controller:addOutput(self.OUTPUT_ACTION.EVENT)
				controller:addOutput(self.OUTPUT_ACTION.STOP_MOVEMENT)
			end
		end,
		
		[self.ENTITY_STATE.COMBAT_FREE] = function(self, controller, inputComponent)
			if controller.combatInputMapper.request then
				controller:addOutput(self.OUTPUT_ACTION.COMBAT)
			end
			
			self:getMovementCombatOutput(controller, inputComponent)
			self:getTargetingOutput(controller, inputComponent)
		end,
		
		[self.ENTITY_STATE.COMBAT_RESTRICTED] = function(self, controller, inputComponent)
			if controller.combatInputMapper.restrictCombat then
				controller:addOutput(self.OUTPUT_ACTION.STOP_MOVEMENT)
			elseif controller.combatInputMapper.request == controller.COMBAT_REQUEST.KNOCKBACK then
				controller:addOutput(self.OUTPUT_ACTION.COMBAT)
			end
		end,
	}
end

function PlayerGlobalInputMapper:getMovementOutput(controller, inputComponent)
	if controller.movementInputMapper:getCurrentMovementRotation() then
		
		local movementComponent = inputComponent.componentTable.movement
		movementComponent.rotation = controller.movementInputMapper:getCurrentMovementRotation()
		
		if not movementComponent.state then
			controller:addOutput(self.OUTPUT_ACTION.START_MOVEMENT)
			controller:addOutput(self.OUTPUT_ACTION.STOP_IDLE)
		end
	elseif inputComponent.componentTable.movement.state then
		controller:addOutput(self.OUTPUT_ACTION.STOP_MOVEMENT)
		controller:addOutput(self.OUTPUT_ACTION.START_IDLE)
	end
end

function PlayerGlobalInputMapper:getMovementCombatOutput(controller, inputComponent)
	combatComponent = inputComponent.componentTable.combat
	
	if controller.movementInputMapper:getCurrentMovementRotation() then
		
		local movementComponent = inputComponent.componentTable.movement
		movementComponent.rotation = controller.movementInputMapper:getCurrentMovementRotation()
		
		if not movementComponent.state then
			controller:addOutput(self.OUTPUT_ACTION.START_MOVEMENT_COMBAT)
			controller:addOutput(self.OUTPUT_ACTION.STOP_IDLE)
		end
	
	elseif inputComponent.componentTable.movement.state then
		controller:addOutput(self.OUTPUT_ACTION.STOP_MOVEMENT)
		controller:addOutput(self.OUTPUT_ACTION.START_IDLE_COMBAT)
	end
end

function PlayerGlobalInputMapper:getTargetingOutput(controller, inputComponent)
	if controller.targetingInputMapper.setState or controller.targetingInputMapper.getTarget then
		controller:addOutput(self.OUTPUT_ACTION.TARGETING)
	end
end

function PlayerGlobalInputMapper:resetTargetingMovementModifiers(controller, inputComponent)
	inputComponent.componentTable.targeting.direction = false
end