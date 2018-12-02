------------------------------------
--Player Entity State System Module:
------------------------------------

--[[
Global system id = 

NOTE: This system only supports one controllable entity at a time.
IMPORTANT FIX THIS: Action requests are only sent to the first active input component row - dude what?!
Create methods to control the current active player input rows.

How to make this work with different entity types?

http://boreal.aggydaggy.com/programming/2016/05/25/mean-clean-state-machine.html
]]

local playerEntityStateSystem = {}

---------------
--Dependencies:
---------------

require 'entityInputMovementActionMapper'
require 'entityInputTargetingActionMapper'
require 'eventDataObjectPool'
playerEntityStateSystem.movementActionMapper = movementActionMapper.new()
playerEntityStateSystem.targetingActionMapper = targetingActionMapper.new()
playerEntityStateSystem.entityStateActionMap = require 'entityStateActionMap'
playerEntityStateSystem.ENTITY_TYPES = require '/entity/ENTITY_TYPE'
playerEntityStateSystem.ENTITY_ACTION = require 'ENTITY_ACTION'
playerEntityStateSystem.EVENT_OBJECT = require 'EVENT_OBJECT'
local SYSTEM_ID = require '/system/SYSTEM_ID'

playerEntityStateSystem.movementRequestPool = eventDataObjectPool.new(6, 
	{'action id', 'movement row index', 'direction', 'x', 'y', 'hitbox row'}, 3)
playerEntityStateSystem.movementRequestPool:buildObjectPool()

playerEntityStateSystem.targetingActionRequestPool = eventDataObjectPool.new(5, {'TARGETING_REQUEST_TYPE', 
	{'TARGETING_SELECTOR_ENTITY_TYPE', 'TARGETING_SELECTOR_ENTITY_ID', 'TARGETING_STATE', 
	'TARGETING_TARGET_ENTITY_LIST'}}, 3)
playerEntityStateSystem.targetingActionRequestPool:buildObjectPool()

-------------------
--Static Variables:
-------------------

-------------------
--System Variables:
-------------------

playerEntityStateSystem.id = SYSTEM_ID.PLAYER_CONTROLLER

playerEntityStateSystem.entityStateComponentTable = {}
playerEntityStateSystem.entityTargetingComponentTable = {}
playerEntityStateSystem.playerInputTable = {}

playerEntityStateSystem.eventDispatcher = nil
playerEntityStateSystem.eventListenerList = {}

playerEntityStateSystem.inputStack = {}

----------------
--Event Methods:
----------------

playerEntityStateSystem.eventMethods = {
	[1] = {
		[1] = function(inputId)
			table.insert(playerEntityStateSystem.inputStack, inputId)
		end
	}
	
	--receive the STATE from the action requests
}

---------------
--Init Methods:
---------------

function playerEntityStateSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function playerEntityStateSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function playerEntityStateSystem:setEntityStateComponentTable(entityStateComponentTable)
	self.entityStateComponentTable = entityStateComponentTable
end

function playerEntityStateSystem:setPlayerInputTable(playerInputTable)
	self.playerInputTable = playerInputTable
end

function playerEntityStateSystem:buildMovementRequestPool(n)
	self.movementRequestPool:buildObjectPool(n)
end

---------------
--Exec methods:
---------------

playerEntityStateSystem.inputMappingMethods = {
	[KEY_PRESS_MOVE_UP] = function()
		playerEntityStateSystem.movementActionMapper:setMovementKeyPress()
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_RELEASE_MOVE_UP] = function()
		playerEntityStateSystem.movementActionMapper:setMovementKeyRelease()
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_HOLD_MOVE_UP] = function()
		playerEntityStateSystem.movementActionMapper:incrementMovementDirectionMapYIndex(-1)
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_PRESS_MOVE_LEFT] = function()
		playerEntityStateSystem.movementActionMapper:setMovementKeyPress()
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_RELEASE_MOVE_LEFT] = function()
		playerEntityStateSystem.movementActionMapper:setMovementKeyRelease()
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_HOLD_MOVE_LEFT] = function()
		playerEntityStateSystem.movementActionMapper:incrementMovementDirectionMapXIndex(-1)
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_PRESS_MOVE_DOWN] = function()
		playerEntityStateSystem.movementActionMapper:setMovementKeyPress()
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_RELEASE_MOVE_DOWN] = function()
		playerEntityStateSystem.movementActionMapper:setMovementKeyRelease()
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_HOLD_MOVE_DOWN] = function()
		playerEntityStateSystem.movementActionMapper:incrementMovementDirectionMapYIndex(1)
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_PRESS_MOVE_RIGHT] = function()
		playerEntityStateSystem.movementActionMapper:setMovementKeyPress()
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_RELEASE_MOVE_RIGHT] = function()
		playerEntityStateSystem.movementActionMapper:setMovementKeyRelease()
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_HOLD_MOVE_RIGHT] = function()
		playerEntityStateSystem.movementActionMapper:incrementMovementDirectionMapXIndex(1)
		playerEntityStateSystem.actionRequestMap.movement = true
	end,
	
	[KEY_PRESS_SET_TARGETING_STATE] = function()
		playerEntityStateSystem.targetingActionMapper:setSetState(true)
		playerEntityStateSystem.actionRequestMap.targeting = true
	end,
	
	[KEY_RELEASE_SET_TARGETING_STATE] = function()
		--do nothing
	end,
	
	[KEY_HOLD_SET_TARGETING_STATE] = function()
		--do nothing
	end,
	
	[KEY_PRESS_SEARCH_TARGET] = function()
		playerEntityStateSystem.targetingActionMapper:setGetTarget(true)
		playerEntityStateSystem.actionRequestMap.targeting = true
	end,
	
	[KEY_RELEASE_SEARCH_TARGET] = function()
		--do nothing
	end,
	
	[KEY_HOLD_SEARCH_TARGET] = function()
		--do nothing
	end
	
	--(...) add a default value to this table?
}

playerEntityStateSystem.actionRequestMap = {
	--just a prototype (but a good idea):
	movement = false,
	targeting = false
}

function playerEntityStateSystem:setGlobalEntityState(entityStateRow, state)
	entityStateRow.state = state
end

function playerEntityStateSystem:resetGlobalEntityState(entityStateRow)
	entityStateRow.state = entityStateRow.defaultState
end

function playerEntityStateSystem:isActionAllowed(stateId, actionId)
	return self.entityStateActionMap.actionMap[stateId][actionId]
end

function playerEntityStateSystem:resolveInputStack()
	for i=#self.inputStack, 1, -1 do
		self.inputMappingMethods[self.inputStack[i]]()
		table.remove(self.inputStack)
	end
end

function playerEntityStateSystem:sendActionRequests(entityStateRow)
	--prototype:
	
	if self.actionRequestMap.movement then
		self:sendMovementActionRequest(entityStateRow)
		self.actionRequestMap.movement = false
		self.movementActionMapper:resetMapping()
	end
	
	if self.actionRequestMap.targeting then
		self:sendTargetingActionRequest(entityStateRow)
		self.actionRequestMap.targeting = false
		self.targetingActionMapper:resetMapping()
	end
end

function playerEntityStateSystem:sendMovementActionRequest(entityStateRow)
	--movement request: {'action id', 'movement row index', 'direction', 'x', 'y', 'hitbox row'}
	
	if self.movementActionMapper:getCurrentMovementDirection() then
		if self:isActionAllowed(entityStateRow.state, self.ENTITY_ACTION.MOVE) then
			local movementRequest = self.movementRequestPool:getCurrentAvailableObject()
			movementRequest[1], movementRequest[2], movementRequest[3], movementRequest[6] = 
				self.ENTITY_ACTION.MOVE, entityStateRow.componentTable.movement, self.movementActionMapper:getCurrentMovementDirection(), 
				entityStateRow.componentTable.hitbox,
			self.eventDispatcher:postEvent(1, 1, movementRequest)
			self.movementRequestPool:incrementCurrentIndex()
			
			if self.movementActionMapper:getMovementKeyPress() or self.movementActionMapper:getMovementKeyRelease() then
				local movementRequest = self.movementRequestPool:getCurrentAvailableObject()
				movementRequest[1], movementRequest[2], movementRequest[6] = 
					self.ENTITY_ACTION.MOVE_START, entityStateRow.componentTable.movement, 
					entityStateRow.componentTable.hitbox,
				self.eventDispatcher:postEvent(1, 1, movementRequest)
				self.movementRequestPool:incrementCurrentIndex()
			end
		end
	elseif self.movementActionMapper:getMovementKeyRelease() then
		if self:isActionAllowed(entityStateRow.state, self.ENTITY_ACTION.IDLE) then
			local movementRequest = self.movementRequestPool:getCurrentAvailableObject()
			movementRequest[1], movementRequest[2], movementRequest[3] = self.ENTITY_ACTION.IDLE, 
				entityStateRow.componentTable.movement, self.movementActionMapper:getCurrentMovementDirection()
			self.eventDispatcher:postEvent(1, 1, movementRequest)
			self.movementRequestPool:incrementCurrentIndex()
		end
	elseif self.movementActionMapper:getMovementKeyPress() then
		if self:isActionAllowed(entityStateRow.state, self.ENTITY_ACTION.IDLE) then
			local movementRequest = self.movementRequestPool:getCurrentAvailableObject()
			movementRequest[1], movementRequest[2], movementRequest[3] = self.ENTITY_ACTION.IDLE, 
				entityStateRow.componentTable.movement, self.movementActionMapper:getCurrentMovementDirection()
			self.eventDispatcher:postEvent(1, 1, movementRequest)
			self.movementRequestPool:incrementCurrentIndex()
		end
	end
end

function playerEntityStateSystem:sendTargetingActionRequest(entityStateRow)
	--can even mix this shit with the movement action mapper lmao
	
	if self.targetingActionMapper.setState then
		local targetingComponent = entityStateRow.componentTable.targeting
		
		if self:isActionAllowed(entityStateRow.state, self.ENTITY_ACTION.TARGETING_SET_STATE) then
			local targetingActionRequest = self.targetingActionRequestPool:getCurrentAvailableObject()
			targetingActionRequest[self.EVENT_OBJECT.TARGETING_REQUEST_TYPE],
			targetingActionRequest[self.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY_TYPE],
			targetingActionRequest[self.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY] = 
			self.ENTITY_ACTION.TARGETING_SET_STATE, self.ENTITY_TYPES.GENERIC_ENTITY, targetingComponent
			
			self.eventDispatcher:postEvent(2, 1, targetingActionRequest)
			self.targetingActionRequestPool:incrementCurrentIndex()
		end
	elseif self.targetingActionMapper.getTarget then
		local targetingComponent = entityStateRow.componentTable.targeting
		
		if not targetingComponent.state then
			if self:isActionAllowed(entityStateRow.state, self.ENTITY_ACTION.TARGETING_SET_STATE) then
				local targetingActionRequest = self.targetingActionRequestPool:getCurrentAvailableObject()
				targetingActionRequest[self.EVENT_OBJECT.TARGETING_REQUEST_TYPE],
				targetingActionRequest[self.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY_TYPE],
				targetingActionRequest[self.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY] = 
				self.ENTITY_ACTION.TARGETING_SET_STATE, self.ENTITY_TYPES.GENERIC_ENTITY, 
					targetingComponent
				
				self.eventDispatcher:postEvent(2, 1, targetingActionRequest)
				self.targetingActionRequestPool:incrementCurrentIndex()
			end
		else
			local targetingActionRequest = self.targetingActionRequestPool:getCurrentAvailableObject()
			targetingActionRequest[self.EVENT_OBJECT.TARGETING_REQUEST_TYPE],
			targetingActionRequest[self.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY_TYPE],
			targetingActionRequest[self.EVENT_OBJECT.TARGETING_SELECTOR_ENTITY] = 
			self.ENTITY_ACTION.TARGETING_SEARCH, self.ENTITY_TYPES.GENERIC_ENTITY, targetingComponent
			
			self.eventDispatcher:postEvent(2, 1, targetingActionRequest)
			self.targetingActionRequestPool:incrementCurrentIndex()
		end
	end
end

function playerEntityStateSystem:main()
	self.movementRequestPool:resetCurrentIndex()
	self:resolveInputStack()
	for i, row in ipairs(self.playerInputTable) do
		if row.state then
			self:sendActionRequests(row.componentTable.actionState)
		end
	end
end

----------------
--Return Module:
----------------

return playerEntityStateSystem