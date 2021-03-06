------------------
--Dialogue Loader:
------------------

local DialogueLoader = {}

---------------
--Dependencies:
---------------

require 'misc'
require '/dialogue/DialogueObjects'
DialogueLoader.DIALOGUE = require '/dialogue/DIALOGUE'
DialogueLoader.DIALOGUE_REQUEST = require '/dialogue/DIALOGUE_REQUEST'
DialogueLoader.DIALOGUE_ASSET = require '/dialogue/DIALOGUE_ASSET'
DialogueLoader.ACTOR = require '/dialogue/ACTOR'
DialogueLoader.SEGMENT_TYPE = require '/dialogue/SEGMENT_TYPE'
DialogueLoader.DIALOGUE_METHOD = require '/dialogue/DIALOGUE_METHOD'
DialogueLoader.PLAYER_TYPE = require '/dialogue/PLAYER_TYPE'
local SYSTEM_ID = require '/system/SYSTEM_ID'

-------------------
--System Variables:
-------------------

DialogueLoader.id = SYSTEM_ID.DIALOGUE_LOADER

DialogueLoader.controllerFolderPath = '/dialogue/controller/'
DialogueLoader.assetsFolderPath = '/dialogue/assets/'

DialogueLoader.fileList = {}			--[dialogue_id] = dialogue file
DialogueLoader.controllerList = {}		--[dialogue_id] = controller file

DialogueLoader.dialoguePlayerObjectPool = DialoguePlayerObjectPool.new(50, false)

DialogueLoader.eventDispatcher = nil
DialogueLoader.eventListenerList = {}

----------------
--Event Methods:
----------------

DialogueLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			--get dialogue player
			local player = DialogueLoader:getDialoguePlayer(request.dialogueId, request.playerType,
				request.parentEntity)
			
			if player ~= nil then
				request.responseCallback(player)
			end
		end,
		
		[2] = function(request)
			--load dialogue
			DialogueLoader:loadDialogue(request.dialogueId)
		end,
		
	}
}

---------------
--Init Methods:
---------------

function DialogueLoader:init()
	
end

---------------
--Exec Methods:
---------------

function DialogueLoader:resetFileList()
	for dialogueName, dialogueId in pairs(self.DIALOGUE) do
		self.fileList[dialogueId] = nil
	end
end

function DialogueLoader:resetControllerList()
	for dialogueName, dialogueId in pairs(self.DIALOGUE) do
		self.controllerList[dialogueId] = nil
	end
end

function DialogueLoader:getDialogueFile(dialogueId)
	local asset = self.DIALOGUE_ASSET[dialogueId]
	if asset ~= nil then
		local path = self.assetsFolderPath .. asset.filePath
		local assetFile = require(path)
		return assetFile
	end
	return nil
end

function DialogueLoader:getController(dialogueId)
	local asset = self.DIALOGUE_ASSET[dialogueId]
	if asset ~= nil then
		local path = self.controllerFolderPath .. asset.controllerPath
		local controller = require(path)
		return controller
	end
	return nil
end

function DialogueLoader:loadDialogue(dialogueId)
	if self.fileList[dialogueId] == nil then
		local dialogueFile = self:getDialogueFile(dialogueId)
		if dialogueFile ~= nil then
			self:setDialogueFile(dialogueId, dialogueFile)
		end
	end
	
	if self.controllerList[dialogueId] == nil then
		local controller = self:getController(dialogueId)
		if controller ~= nil then
			self:setControllerFile(dialogueId, controller)
		end
	end
end

function DialogueLoader:setDialogueFile(dialogueId, dialogueFile)
	self.fileList[dialogueId] = dialogueFile
end

function DialogueLoader:setControllerFile(dialogueId, controller)
	self.controllerList[dialogueId] = controller
end

function DialogueLoader:getDialoguePlayer(dialogueId, playerType, parentEntity)
	self:loadDialogue(dialogueId)
	local player = self.dialoguePlayerObjectPool:getCurrentAvailableDialoguePlayerObject()
	
	if player then
		self:initPlayer(player, dialogueId, self.fileList[dialogueId], self.controllerList[dialogueId], 
			playerType, parentEntity)
		return player
	end
end

function DialogueLoader:initPlayer(player, dialogueId, dialogueFile, controller, playerType, 
	parentEntity)
	self:resetPlayer(player)
	
	player.dialogueId = dialogueId
	
	if dialogueFile then
		self:setThreadsOnPlayer(player, dialogueFile)
		self:setSelectedChoiceOnPlayer(player, dialogueFile)
		self:setParentEntity(player, parentEntity)
		self:setController(player, controller)
		player.type = playerType
		player.state = true
	end
end

function DialogueLoader:resetPlayer(player)
	player.state = false
	player.type = 1
	player.time = 0
	player.updateTime = 0
	player.dialogueId = nil
	player.parentEntity = nil
	player.controller = nil
	player.currentLine = 1
	player.currentThread = 1
	player.currentSegment = nil
	
	resetTable(player.threads)
	resetTable(player.selectedChoice)
end

function DialogueLoader:setPlayerState(state)
	player.state = state
end

function DialogueLoader:setThreadsOnPlayer(player, dialogueFile)
	for i=1, #dialogueFile do
		local currentLine = dialogueFile[i]
		
		if player.threads[currentLine.thread] == nil then
			player.threads[currentLine.thread] = {}
		end
		
		table.insert(player.threads[currentLine.thread], currentLine)
	end
end

function DialogueLoader:setSelectedChoiceOnPlayer(player, dialogueFile)
	for i=1, #dialogueFile do
		local currentLine = dialogueFile[i]
		
		if currentLine.action and currentLine.action == 'choice' then
			player.selectedChoice[currentLine.line] = {}
		end
	end
end

function DialogueLoader:setParentEntity(player, parentEntity)
	if parentEntity and parentEntity.componentTable.spritebox then
		player.parentEntity = parentEntity.componentTable.spritebox
	end
end

function DialogueLoader:setController(player, controller)
	if controller then
		player.controller = controller
	end
end

----------------
--Return Module:
----------------

return DialogueLoader