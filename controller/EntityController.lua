--USE AS A TEMPLATE FOR ALL CONTROLLERS

EntityController = {}
EntityController.__index = EntityController

setmetatable(EntityController, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EntityController.new ()
	local self = setmetatable ({}, EntityController)
		
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

		self.movementInputMapper = nil
		self.targetingInputMapper = nil
		self.spawnInputMapper = nil
		self.despawnInputMapper = nil
		self.eventInputMapper = nil
		self.combatInputMapper = nil
		self.healthInputMapper = nil
		
		self.playerInputMappingMethods = nil
		self.gameInputMappingMethods = nil
		self.entityOutputMappingMethods = nil
		
		self.output = false
		self.outputList = {}
		
		self:setPlayerInputMappingMethods()
		self:setGameInputMappingMethods()
		self:setEntityOutputMappingMethods()
	return self
end

function GameEntityBuilder:setPlayerInputMappingMethods()
	self.playerInputMappingMethods = {
		[self.INPUT_ACTION.NONE] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.MOVE_UP] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.MOVE_LEFT] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.MOVE_DOWN] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.MOVE_RIGHT] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.SET_TARGETING_STATE] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.SEARCH_TARGET] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.INTERACT_REQUEST] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.ATTACK_A] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.ATTACK_B] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.ATTACK_C] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.END_ATTACK] = function(self, inputComponent)
			
		end,
		
		[self.INPUT_ACTION.SPECIAL_MOVE] = function(self, inputComponent)
			
		end,
	}
end

function GameEntityBuilder:setGameInputMappingMethods()
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
			
		end,
		
		[self.ENTITY_ACTION.KNOCKBACK] = function(self, request, inputComponent)
			
		end,
		
		[self.ENTITY_ACTION.END_COMBAT] = function(self, request, inputComponent)
			
		end,
	}
end

function GameEntityBuilder:setEntityOutputMappingMethods()
	self.entityOutputMappingMethods = {
		[self.OUTPUT_ACTION.SPAWN] = function(self, controllerSystem, stateComponent)
			
		end,
		
		[self.OUTPUT_ACTION.DESPAWN] = function(self, controllerSystem, stateComponent)
			
		end,
		
		[self.OUTPUT_ACTION.MOVEMENT] = function(self, controllerSystem, stateComponent)
			
		end,
		
		[self.OUTPUT_ACTION.TARGETING] = function(self, controllerSystem, stateComponent)
			
		end,
		
		[self.OUTPUT_ACTION.EVENT] = function(self, controllerSystem, stateComponent)
			
		end,
		
		[self.OUTPUT_ACTION.COMBAT] = function(self, controllerSystem, stateComponent)
			
		end,
}
end

function EntityController:resolvePlayerInput(request, inputComponent)
	self.playerInputMappingMethods[request.actionId](self, inputComponent)
end

function EntityController:resolveGameInput(controllerSystem, request, inputComponent)
	self.gameInputMappingMethods[request.actionId](self, request, inputComponent)
end

function EntityController:resolveOutputs(controllerSystem, component)
	for i=#self.outputList, 1, -1 do
		self:resolveOutput(controllerSystem, self.outputList[i], component)
		table.remove(self.outputList)
	end
	
	self.output = false
end

function EntityController:addOutput(outputId)
	self.output = true
	table.insert(self.outputList, outputId)
end

function EntityController:resolveOutput(controllerSystem, outputId, component)
	self.entityOutputMappingMethods[outputId](self, controllerSystem, component.componentTable.state)
end

function EntityController:setEntityState(stateComponent, state)
	stateComponent.state = state
end

function EntityController:resetGlobalEntityState(stateComponent)
	stateComponent.state = stateComponent.defaultState
end