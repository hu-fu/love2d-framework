------------------
--Dialogue Loader:
------------------

local DialogueSystem = {}

---------------
--Dependencies:
---------------

require 'misc'
require '/dialogue/DialogueObjects'
DialogueSystem.DIALOGUE = require '/dialogue/DIALOGUE'
DialogueSystem.DIALOGUE_REQUEST = require '/dialogue/DIALOGUE_REQUEST'
DialogueSystem.DIALOGUE_ASSET = require '/dialogue/DIALOGUE_ASSET'
DialogueSystem.ACTOR = require '/dialogue/ACTOR'
DialogueSystem.SEGMENT_TYPE = require '/dialogue/SEGMENT_TYPE'
DialogueSystem.DIALOGUE_METHOD = require '/dialogue/DIALOGUE_METHOD'
DialogueSystem.PLAYER_TYPE = require '/dialogue/PLAYER_TYPE'
DialogueSystem.EVENT_TYPE = require '/event/EVENT_TYPE'
local SYSTEM_ID = require '/system/SYSTEM_ID'

-------------------
--System Variables:
-------------------

DialogueSystem.id = SYSTEM_ID.DIALOGUE
DialogueSystem.DEFAULT_PLAY_SPEED = 1.0

DialogueSystem.requestStack = {}
DialogueSystem.activePlayers = {}

DialogueSystem.eventDispatcher = nil
DialogueSystem.eventListenerList = {}

DialogueSystem.dialogueRequestPool = EventObjectPool.new(DialogueSystem.EVENT_TYPE.DIALOGUE, 1)
DialogueSystem.dialogueLoaderRequestPool = EventObjectPool.new(DialogueSystem.EVENT_TYPE.DIALOGUE, 5)

function DialogueSystem:dialogueLoaderDefaultCallbackMethod() return function () end end

----------------
--Event Methods:
----------------

DialogueSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--add request to stack
			DialogueSystem:addRequestToStack(request)
		end,
	}
}

---------------
--Init Methods:
---------------

function DialogueSystem:init()
	
end

---------------
--Exec Methods:
---------------

function DialogueSystem:update(dt)
	self:resolveRequestStack()
	self:updateActivePlayers(dt)
	self:removeInactivePlayers()
	
	self.dialogueLoaderRequestPool:resetCurrentIndex()
end

DialogueSystem.resolveRequestMethods = {
	[DialogueSystem.DIALOGUE_REQUEST.AUTO_START_DIALOGUE] = function(self, request)
		self:getDialoguePlayer(request.dialogueId, request.playerType, request.parentEntity)
	end,
	
	[DialogueSystem.DIALOGUE_REQUEST.AUTO_END_DIALOGUE] = function(self, request)
		local player = self:getActivePlayer(request.dialogueId, request.parentEntity)
		
		if player then
			self.DIALOGUE_METHOD:endDialogue(self, player)
			self:removePlayerFromActivePlayers(player)
		end
	end,
	
	-- (+) GUI specific request methods (dialogue advance is manual)
		--no need to do before doing the GUI
}

function DialogueSystem:getActivePlayer(dialogueId, parentEntity)
	if dialogueId then
		self:getPlayerFromActivePlayersByDialogueId(dialogueId)
	elseif parentEntity then
		self:getPlayerFromActivePlayersByParentEntity(parentEntity)
	end
end

function DialogueSystem:addPlayerToActivePlayers(player)
	table.insert(self.activePlayers, player)
end

function DialogueSystem:removePlayerFromActivePlayers(player)
	for i=#self.activePlayers, 1 , -1 do
		if self.activePlayers[i] == player then
			table.remove(self.activePlayers, i)
			break
		end
	end
end

function DialogueSystem:getPlayerFromActivePlayersByDialogueId(dialogueId)
	for i=#self.activePlayers, 1 , -1 do
		if self.activePlayers[i].dialogueId == dialogueId then
			return self.activePlayers[i]
		end
	end
end

function DialogueSystem:getPlayerFromActivePlayersByParentEntity(parentEntity)
	for i=#self.activePlayers, 1 , -1 do
		if self.activePlayers[i].parentEntity == parentEntity then
			return self.activePlayers[i]
		end
	end
end

function DialogueSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function DialogueSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function DialogueSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function DialogueSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

function DialogueSystem:updateActivePlayers(dt)
	for i=1, #self.activePlayers do
		local player = self.activePlayers[i]
		
		if player.state then
			self.runPlayerByType[player.type](self, player, dt)
		end
	end
end

DialogueSystem.runPlayerByType = {
	[DialogueSystem.PLAYER_TYPE.REAL_TIME_TEXT_ONLY] = function(self, player, dt)
		player.time = player.time + dt
		
		if player.time >= player.updateTime then
			local segment = self.DIALOGUE_METHOD:runDialogueBySegment(self, player)
			player.currentSegment = segment
			
			self.REAL_TIME_UPDATE_METHOD[segment.type](self, player, dt)
		end
	end,
	
	[DialogueSystem.PLAYER_TYPE.REAL_TIME_PORTRAIT] = function(self, player, dt)
		self.runPlayerByType[self.PLAYER_TYPE.REAL_TIME_TEXT_ONLY](self, player, dt)
	end,
	
	[DialogueSystem.PLAYER_TYPE.GUI] = function(self, player, dt)
		
	end,
}

DialogueSystem.REAL_TIME_UPDATE_METHOD = {
	[DialogueSystem.SEGMENT_TYPE.TEXT] = function(self, player, dt)
		player.time = 0
		
		if player.updateTime == nil then
			player.updateTime = self.DEFAULT_PLAY_SPEED
		end
	end,
	
	[DialogueSystem.SEGMENT_TYPE.CHOICE] = function(self, player, dt)
		--choices are ignored in real time (intentional)
		self.DIALOGUE_METHOD:advanceDialogue(player)
		self.runPlayerByType[player.type](self, player, dt)
	end,
	
	[DialogueSystem.SEGMENT_TYPE.END] = function(self, player, dt)
		self.DIALOGUE_METHOD:endDialogue(self, player)
	end,
	
	[DialogueSystem.SEGMENT_TYPE.START] = function(self, player, dt)
		self.runPlayerByType[player.type](self, player, dt)
	end,
	
	[DialogueSystem.SEGMENT_TYPE.JUMP_LINE] = function(self, player, dt)
		self.runPlayerByType[player.type](self, player, dt)
	end,
	
}

function DialogueSystem:removeInactivePlayers()
	for i=#self.activePlayers, 1 , -1 do
		if not self.activePlayers[i].state then
			table.remove(self.activePlayers, i)
		end
	end
end

function DialogueSystem:getDialoguePlayerCallbackMethod()
	return function (player)
		DialogueSystem:getLoadedDialoguePlayer(player)
	end
end

function DialogueSystem:getLoadedDialoguePlayer(player)
	if player then
		self:addPlayerToActivePlayers(player)
		self.DIALOGUE_METHOD:startDialogue(self, player)
	end
end

function DialogueSystem:getDialoguePlayer(dialogueId, playerType, parentEntity)
	local request = self.dialogueLoaderRequestPool:getCurrentAvailableObject()
	request.dialogueId = dialogueId
	request.playerType = playerType
	request.parentEntity = parentEntity
	request.responseCallback = self:getDialoguePlayerCallbackMethod()
	self.dialogueLoaderRequestPool:incrementCurrentIndex()
	
	self.eventDispatcher:postEvent(1, 1, request)
end

function DialogueSystem:setActivePlayersOnGameRenderer()
	local dialogueRequest = self.dialogueRequestPool:getCurrentAvailableObject()
	
	dialogueRequest.activePlayers = self.activePlayers
	
	self.eventDispatcher:postEvent(2, 8, dialogueRequest)
end

----------------
--Return Module:
----------------

return DialogueSystem