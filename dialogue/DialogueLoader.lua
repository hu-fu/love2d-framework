------------------
--Dialogue Loader:
------------------

local DialogueLoader = {}

---------------
--Dependencies:
---------------

require '/dialogue/DialogueObjects'
DIALOGUE_METHODS.DIALOGUE = require '/dialogue/DIALOGUE'
DIALOGUE_METHODS.DIALOGUE_ASSET = require '/dialogue/DIALOGUE_ASSET'
DIALOGUE_METHODS.ACTOR = require '/dialogue/ACTOR'
DIALOGUE_METHODS.SEGMENT_TYPE = require '/dialogue/SEGMENT_TYPE'
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
			local player = DialogueLoader:getDialoguePlayer(request.dialogueId)
			
			if player ~= nil then
				request.callback(player)
			end
		end,
		
		[2] = function(request)
			--load dialogue
			DialogueLoader:getDialoguePlayer(request.dialogueId, request.parentEntity)
		end
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
		local path = self.assetsFolderPath .. asset.controllerPath
		local controller = require(path)
		return controller
	end
	return nil
end

function ActionLoader:loadDialogue(dialogueId)
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

function ActionLoader:setDialogueFile(dialogueId, dialogueFile)
	self.fileList[dialogueId] = dialogueFile
end

function ActionLoader:setControllerFile(dialogueId, controller)
	self.controllerList[dialogueId] = controller
end

function ActionLoader:getDialoguePlayer(dialogueId, parentEntity)
	self:loadDialogue(dialogueId)
	local player = self.dialoguePlayerObjectPool:getCurrentAvailableDialoguePlayerObject()
	
	if player then
		self:initPlayer(player, dialogueId, self.fileList[dialogueId], self.controllerList[dialogueId], 
			parentEntity)
		return player
	end
end

function DialogueLoader:initPlayer(player, dialogueId, dialogueFile, controller, parentEntity)
	player.dialogueId = dialogueId
	
	if dialogueFile then
		self:setThreadsOnPlayer(player, dialogueFile)
		self:setSpecialLinesOnPlayer(player, dialogueFile)
		self:setOptionStatusOnPlayer(player, dialogueFile)
		self:setParentEntity(player, parentEntity)
		self:setController(player, controller)
	end
	
	player.currentLine = 1
	player.currentThread = 1
end

function DialogueLoader:resetPlayer(player)
	--not needed?
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

function DialogueLoader:setSpecialLinesOnPlayer(player, dialogueFile)
	for i=1, #dialogueFile do
		local currentLine = dialogueFile[i]
		
		if currentLine.id then
			table.insert(player.specialLines, currentLine)
		end
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
	if parentEntity then
		player.parentEntity = parentEntity
	end
end

function DialogueLoader:setController(player, controller)
	if controller then
		player.controller = controller
	end
end

function DialogueLoader:setReturnType(player, returnType)
	if returnType then
		player.returnType = returnType
	end
end

function DialogueLoader:getDialogueController(dialogueId)
	--TODO
end

---------------
--Init Methods:
---------------

return DialogueLoader