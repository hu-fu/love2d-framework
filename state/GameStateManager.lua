--this is a system (GameStateManager System)

local GameStateManager = {}

GameStateManager.stateStack = {}

GameStateManager.STATE_ID = require '/state/GAME_STATE'
GameStateManager.SYSTEM_ID = require '/system/SYSTEM_ID'

GameStateManager.id = GameStateManager.SYSTEM_ID.GAME_STATE_MANAGER

GameStateManager.stateTable = {
	[GameStateManager.STATE_ID.VOID] = nil,
	[GameStateManager.STATE_ID.TEST_STATE] = nil,
	[GameStateManager.STATE_ID.TEST_STATE_B] = nil,
	[GameStateManager.STATE_ID.TEST_STATE_C] = nil,
	[GameStateManager.STATE_ID.SCENE_LOAD] = nil,
	[GameStateManager.STATE_ID.SCENE_SAVE] = nil
}

GameStateManager.eventListenerList = {}
GameStateManager.eventDispatcher = nil

GameStateManager.eventMethods = {
	
	[1] = {
		[1] = function(request)
			--change state:
			GameStateManager:runStateInitializer(request.stateInitializer)
		end
	}
}

function GameStateManager:init(systemTable)
	self:initializeAllStates(systemTable)
	--self:changeState(self.stateTable[self.STATE_ID.SCENE_LOAD])
end

function GameStateManager:initializeAllStates(systemTable, gameDatabase)
	self.stateTable[self.STATE_ID.VOID] = require '/state/VoidState'
	self.stateTable[self.STATE_ID.VOID]:setSystems(systemTable)
	self.stateTable[self.STATE_ID.TEST_STATE] = require '/state/TestState'
	self.stateTable[self.STATE_ID.TEST_STATE]:setSystems(systemTable)
	self.stateTable[self.STATE_ID.TEST_STATE_B] = require '/state/TestStateB'
	self.stateTable[self.STATE_ID.TEST_STATE_B]:setSystems(systemTable)
	self.stateTable[self.STATE_ID.TEST_STATE_C] = require '/state/TestStateC'
	self.stateTable[self.STATE_ID.TEST_STATE_C]:setSystems(systemTable)
	self.stateTable[self.STATE_ID.SCENE_LOAD] = require '/state/SceneLoadState'
	self.stateTable[self.STATE_ID.SCENE_LOAD]:setSystems(systemTable)
	self.stateTable[self.STATE_ID.SCENE_SAVE] = require '/state/SceneSaveState'
	self.stateTable[self.STATE_ID.SCENE_SAVE]:setSystems(systemTable)
end

function GameStateManager:getStateById(stateId)
	return self.stateTable[stateId]
end

function GameStateManager:finish()
	love.event.quit()
end

function GameStateManager:runStateInitializer(stateInitializer)
	self:changeStateById(stateInitializer.stateId, stateInitializer:getInitParameters())
end

function GameStateManager:changeState(gameState, initParam)
	self:removeFromStack(gameState)
	
	if not self:isStackEmpty() then
		self.stateStack[#self.stateStack]:pause()
	end
	
	self:push(gameState)
	gameState:init(self, initParam)
end

function GameStateManager:changeStateById(gameStateId, initParam)
	local gameState = self:getStateById(gameStateId)
	
	if gameState then
		self:removeFromStack(gameState)
		
		if not self:isStackEmpty() then
			self.stateStack[#self.stateStack]:pause()
		end
		
		self:push(gameState)
		gameState:init(self, initParam)
	end
end

function GameStateManager:revertState()
	self:pop()
	
	if not self:isStackEmpty() then
		self.stateStack[#self.stateStack]:resume()
	end
end

function GameStateManager:isStateInStack(gameState)
	for i=1, #self.stateStack do
		if gameState == self.stateStack[i] then return i end
	end
	return false
end

function GameStateManager:isStackEmpty()
	if #self.stateStack > 0 then
		return false
	else
		return true
	end
end

function GameStateManager:push(gameState)
	table.insert(self.stateStack, gameState)
end

function GameStateManager:pop()
	table.remove(self.stateStack)
end

function GameStateManager:removeFromStack(gameState)
	local index = self:isStateInStack(gameState)
	if index then
		table.remove(self.stateStack, index)
	end
end

function GameStateManager:update(dt)
	if self:isStackEmpty() then
		self:finish()
	end
	
	self.stateStack[#self.stateStack]:update(self, dt)
end

function GameStateManager:draw()
	self.stateStack[#self.stateStack]:draw(self)
end

function GameStateManager:handleKeyPress(key)
	self.stateStack[#self.stateStack]:handleKeyPress(self, key)
end

function GameStateManager:handleKeyRelease(key)
	self.stateStack[#self.stateStack]:handleKeyRelease(self, key)
end

function GameStateManager:handleKeyHold()
	self.stateStack[#self.stateStack]:handleKeyHold(self)
end

return GameStateManager