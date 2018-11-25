------------------------------
--Simulation Input Controller:
------------------------------
--it says input but it's more like an entity state machine
--this isn't being used is it?

local SimulationInputController = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
local SIMULATION_INPUT_ACTION = require '/input/SIMULATION_INPUT_ACTION'
local ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
local ENTITY_STATE = require '/entity state/ENTITY_STATE'
require '/entity state/EntityInputMovementActionMapper'
require '/entity state/EntityInputTargetingActionMapper'
SimulationInputController.entityStateActionMap = require '/entity state/EntityStateActionMap'

-------------------
--System Variables:
-------------------

SimulationInputController.id = SYSTEM_ID.SIMULATION_INPUT_CONTROLLER

SimulationInputController.movementActionMapper = MovementActionMapper.new()
SimulationInputController.targetingActionMapper = TargetingActionMapper.new()

SimulationInputController.inputComponentTable = {}
SimulationInputController.activeInputComponent = nil

SimulationInputController.inputStack = {}

SimulationInputController.actionRequestMap = {
	movement = false,
	targeting = false
}

SimulationInputController.eventDispatcher = nil
SimulationInputController.eventListenerList = {}

----------------
--Event Methods:
----------------

SimulationInputController.eventMethods = {
	[1] = {
		[1] = function(request)
			--set entity db
			--run chooseActiveEntity()
		end,
		
		[2] = function(request)
			--set active entity
		end,
		
		[3] = function(request)
			--insert input into input stack
			--table.insert(playerEntityStateSystem.inputStack, inputId)
		end
	}
}

---------------
--Init Methods:
---------------

function SimulationInputController:setEntityInputTable(entityInputTable)
	self.entityInputTable = entityInputTable
end

---------------
--Exec Methods:
---------------

function SimulationInputController:reset()
	
end

function SimulationInputController:main()
	self:reset()
	self:resolveInputStack()
	
	if self.activeInputComponent and self.activeInputComponent.state then
		self:sendActionRequests(self.activeInputComponent.componentTable.actionState)
	end
end

function SimulationInputController:chooseActiveEntity()
	for i=1, #self.inputComponentTable do
		if self.inputComponentTable[i].state then
			self.activeInputComponent = self.inputComponentTable[i]
		end
	end
end

function SimulationInputController:setActiveEntity(inputComponent)
	if self.activeInputComponent then
		self:setInputComponentState(self.activeInputComponent, false)
	end
	self.activeInputComponent = inputComponent
	self:setInputComponentState(self.activeInputComponent, true)
end

function SimulationInputController:setActiveEntityById(id)
	for i=1, #self.inputComponentTable do
		if self.inputComponentTable[i].componentTable.main.id == id then
			self:setActiveEntity(self.inputComponentTable[i])
			break
		end
	end
end

function SimulationInputController:setInputComponentState(component, state)
	component.state = state
end

SimulationInputController.inputMappingMethods = {
	[SIMULATION_INPUT_ACTION.NONE] = function()
	
	end,
	
	[SIMULATION_INPUT_ACTION.MOVE_UP] = function()
	
	end,
	
	[SIMULATION_INPUT_ACTION.MOVE_LEFT] = function()
	
	end,
	
	[SIMULATION_INPUT_ACTION.MOVE_DOWN] = function()
	
	end,
	
	[SIMULATION_INPUT_ACTION.MOVE_RIGHT] = function()
	
	end,
	
	[SIMULATION_INPUT_ACTION.SET_TARGETING_STATE] = function()
	
	end,
	
	[SIMULATION_INPUT_ACTION.SEARCH_TARGET] = function()
	
	end
}

function SimulationInputController:isActionAllowed(stateId, actionId)
	return self.entityStateActionMap.actionMap[stateId][actionId]
end

function SimulationInputController:resolveInputStack()
	for i=#self.inputStack, 1, -1 do
		self.inputMappingMethods[self.inputStack[i]]()
		table.remove(self.inputStack)
	end
end

function SimulationInputController:sendActionRequests(stateComponent)
	if self.actionRequestMap.movement then
		self:sendMovementActionRequest(stateComponent)
		self.actionRequestMap.movement = false
		self.movementActionMapper:resetMapping()
	end
	
	if self.actionRequestMap.targeting then
		self:sendTargetingActionRequest(stateComponent)
		self.actionRequestMap.targeting = false
		self.targetingActionMapper:resetMapping()
	end
end

function SimulationInputController:sendMovementActionRequest(stateComponent)

end

function SimulationInputController:sendTargetingActionRequest(stateComponent)

end

----------------
--Return module:
----------------

return SimulationInputController