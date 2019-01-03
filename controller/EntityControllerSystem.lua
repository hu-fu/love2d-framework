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

-------------------
--System Variables:
-------------------

EntityControllerSystem.id = SYSTEM_ID.ENTITY_CONTROLLER

EntityControllerSystem.inputComponentTable = {}
EntityControllerSystem.activePlayerInputComponent = nil

EntityControllerSystem.entityControllers = {
	[EntityControllerSystem.ENTITY_CONTROLLER.PLAYER_GENERIC] = require '/controller/PlayerEntityControllerGeneric',
	--...
}

EntityControllerSystem.playerInputStack = {}
EntityControllerSystem.gameInputStack = {}

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
end

function EntityControllerSystem:init()

end

---------------
--Exec Methods:
---------------

function EntityControllerSystem:update()
	self:resolvePlayerInputRequestStack()
	self:resolveGameInputRequestStack()
	
	--TEMP (update method for current player controller - it isn't supposed to go in here or maybe even exist):
	self.entityControllers[self.activePlayerInputComponent.controllerId]:resolveState(self, 
		self.activePlayerInputComponent)
	self.entityControllers[self.activePlayerInputComponent.controllerId]:reset()
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
		local controller = self.entityControllers[self.activePlayerInputComponent.controllerId]
		controller:resolvePlayerInput(self, request.inputId, self.activePlayerInputComponent)	--TEMP
	end
end

function EntityControllerSystem:resolveGameInput(request)
	if request.inputComponent.state then
		local controller = self.entityControllers[request.inputComponent.controllerId]
		controller:resolveEntityInput(self, request, request.inputComponent.componentTable.state)	--TEMP
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

----------------
--Return module:
----------------

return EntityControllerSystem