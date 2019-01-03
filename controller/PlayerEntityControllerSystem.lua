----------------------------------
--Entity Player Controller System:
----------------------------------
--DEPRECATED!

local PlayerEntityControllerSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
PlayerEntityControllerSystem.PLAYER_ENTITY_CONTROLLER = require '/controller/PLAYER_ENTITY_CONTROLLER'
PlayerEntityControllerSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
PlayerEntityControllerSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'

-------------------
--System Variables:
-------------------

PlayerEntityControllerSystem.id = SYSTEM_ID.PLAYER_ENTITY_CONTROLLER

PlayerEntityControllerSystem.inputComponentTable = {}
PlayerEntityControllerSystem.activeInputComponent = nil

PlayerEntityControllerSystem.playerEntityControllers = {
	[PlayerEntityControllerSystem.PLAYER_ENTITY_CONTROLLER.GENERIC] = require '/controller/PlayerEntityControllerGeneric',
	--...
}

PlayerEntityControllerSystem.playerInputStack = {}
PlayerEntityControllerSystem.entityInputStack = {}

PlayerEntityControllerSystem.eventDispatcher = nil
PlayerEntityControllerSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

PlayerEntityControllerSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			PlayerEntityControllerSystem:setInputComponentTable(request.entityDb)
			PlayerEntityControllerSystem:chooseActiveEntity()
		end,
		
		[2] = function(request)
			--set new active entity
		end,
		
		[3] = function(request)
			--add request.inputId to stack
			PlayerEntityControllerSystem:addPlayerInputToStack(request.inputId)
		end,
		
		[4] = function(request)
			--add request.inputId to stack
			PlayerEntityControllerSystem:addEntityInputToStack(request)
		end
	}
}

---------------
--Init Methods:
---------------

function PlayerEntityControllerSystem:setInputComponentTable(entityDb)
	self.inputComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.PLAYER_INPUT)
end

function PlayerEntityControllerSystem:init()

end

---------------
--Exec Methods:
---------------

function PlayerEntityControllerSystem:update()
	if self.activeInputComponent and self.activeInputComponent.state then
		local controller = self.playerEntityControllers[self.activeInputComponent.controllerId]
		self:resolveEntityInputStack(controller)
		self:resolvePlayerInputStack(controller)
		controller:resolveState(self, self.activeInputComponent)
		controller:reset()
	else
		self:clearEntityInputStack()
		self:clearPlayerInputStack()
	end
end

function PlayerEntityControllerSystem:addPlayerInputToStack(input)
	table.insert(self.playerInputStack, input)
end

function PlayerEntityControllerSystem:removePlayerInputFromStack()
	table.remove(self.playerInputStack, 1)
end

function PlayerEntityControllerSystem:clearPlayerInputStack()
	while #self.playerInputStack > 0 do
		self:removePlayerInputFromStack()
	end
end

function PlayerEntityControllerSystem:resolvePlayerInputStack(controller)
	while #self.playerInputStack > 0 do
		self:resolvePlayerInput(controller, self.playerInputStack[1])
	end
end

function PlayerEntityControllerSystem:resolvePlayerInput(controller, input)
	controller:resolvePlayerInput(self, input, self.activeInputComponent)
	self:removePlayerInputFromStack()
end

function PlayerEntityControllerSystem:addEntityInputToStack(request)
	table.insert(self.entityInputStack, request)
end

function PlayerEntityControllerSystem:removeEntityInputFromStack()
	table.remove(self.entityInputStack, 1)
end

function PlayerEntityControllerSystem:clearEntityInputStack()
	while #self.entityInputStack > 0 do
		self:removeEntityInputFromStack()
	end
end

function PlayerEntityControllerSystem:resolveEntityInputStack(controller)
	while #self.entityInputStack > 0 do
		self:resolveEntityInput(controller, self.entityInputStack[1])
	end
end

function PlayerEntityControllerSystem:resolveEntityInput(controller, request)
	controller:resolveEntityInput(self, request, request.stateComponent)
	self:removeEntityInputFromStack()
end

function PlayerEntityControllerSystem:chooseActiveEntity()
	for i=1, #self.inputComponentTable do
		if self.inputComponentTable[i].state then
			self.activeInputComponent = self.inputComponentTable[i]
			break
		end
	end
end

function PlayerEntityControllerSystem:setActiveEntity(inputComponent)
	if self.activeInputComponent then
		self:setInputComponentState(self.activeInputComponent, false)
	end
	self.activeInputComponent = inputComponent
	self:setInputComponentState(self.activeInputComponent, true)
end

function PlayerEntityControllerSystem:setActiveEntityById(id)
	for i=1, #self.inputComponentTable do
		if self.inputComponentTable[i].componentTable.main.id == id then
			self:setActiveEntity(self.inputComponentTable[i])
			break
		end
	end
end

function PlayerEntityControllerSystem:setInputComponentState(component, state)
	component.state = state
end

----------------
--Return module:
----------------

return PlayerEntityControllerSystem