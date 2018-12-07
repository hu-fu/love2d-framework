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
			local player = DialogueLoader:getDialoguePlayer(request.dialogueId, request.parentEntity)
			
			if player ~= nil then
				request.callback(player)
			end
		end,
		
		[2] = function(request)
			--load dialogue
			DialogueLoader:loadDialogue(request.dialogueId)
		end,
		
		[3] = function(request)
			--add request to stack
			DialogueLoader:addRequestToStack(request)
		end,
	}
}

---------------
--Init Methods:
---------------

function DialogueLoader:init()
	self:resetAutoPlayTimer()
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

function DialogueLoader:getDialoguePlayer(dialogueId, parentEntity)
	self:loadDialogue(dialogueId)
	local player = self.dialoguePlayerObjectPool:getCurrentAvailableDialoguePlayerObject()
	
	if player then
		self:initPlayer(player, dialogueId, self.fileList[dialogueId], self.controllerList[dialogueId], 
			parentEntity)
		return player
	end
end

function DialogueLoader:initPlayer(player, dialogueId, dialogueFile, controller, parentEntity)
	self:resetPlayer(player)
	
	player.dialogueId = dialogueId
	
	if dialogueFile then
		self:setThreadsOnPlayer(player, dialogueFile)
		self:setSelectedChoiceOnPlayer(player, dialogueFile)
		self:setParentEntity(player, parentEntity)
		self:setController(player, controller)
		player.state = true
	end
end

function DialogueLoader:resetPlayer(player)
	player.state = false
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

-- debug: --

function DialogueLoader:testRoutine()
	local player = self:getDialoguePlayer(1, nil)
	
	INFO_STR = 0
end

------------------
--Dialogue player:
------------------
--Works as a loader and simple system for playing dialogues
	--dialogues can be played by external systems using this loader and the DIALOGUE_METHOD module
	--action -> start dialogue request | play dialogue request | end dialogue request
	--this is so contrived it's not even funny (don't like it just use a custom one)
		--just load and get the dialogue player and run it elsewhere!
	
DialogueLoader.requestStack = {}
DialogueLoader.activePlayers = {}

DialogueLoader.autoPlaySpeed = 1.0
DialogueLoader.autoPlayTimer = 0

DialogueLoader.resolveRequestMethods = {
	[DialogueLoader.DIALOGUE_REQUEST.START_DIALOGUE_AUTO] = function(self, request)
		local player = self:getDialoguePlayer(request.dialogueId, request.parentEntity)
		
		if player and player.parentEntity then
			self:addPlayerToActivePlayers(player)
			self.DIALOGUE_METHOD:startDialogue(self, player)
		end
	end,
	
	[DialogueLoader.DIALOGUE_REQUEST.END_DIALOGUE_AUTO] = function(self, request)
		local player = nil
		
		if request.dialogueId then
			self:getPlayerFromActivePlayersByDialogueId(request.dialogueId)
		elseif request.parentEntity then
			self:getPlayerFromActivePlayersByParentEntity(request.parentEntity)
		end
		
		if player then
			self.DIALOGUE_METHOD:endDialogue(self, player)
			self:removePlayerFromActivePlayers(player)
		end
	end,
	
	[DialogueLoader.DIALOGUE_REQUEST.START_DIALOGUE] = function(self, request)
		self.DIALOGUE_METHOD:startDialogue(request.player)
		
		local segment = self.DIALOGUE_METHOD:runDialogueBySegment(self, request.player)
		player.currentSegment = segment
	end,
	
	[DialogueLoader.DIALOGUE_REQUEST.PLAY_DIALOGUE] = function(self, request)
		local segment = self.DIALOGUE_METHOD:runDialogueBySegment(self, request.player)
		player.currentSegment = segment
	end,
	
	[DialogueLoader.DIALOGUE_REQUEST.CHOOSE_OPTION] = function(self, request)
		local line = self.DIALOGUE_METHOD:getLineByNumber(request.player, request.lineNumber)
		self.DIALOGUE_METHOD:selectChoice(request.player, line, request.choiceId)
		
		local segment = self.DIALOGUE_METHOD:runDialogueBySegment(self, request.player)
		player.currentSegment = segment
	end,
	
	[DialogueLoader.DIALOGUE_REQUEST.END_DIALOGUE] = function(self, request)
		self.DIALOGUE_METHOD:endDialogue(request.player)
	end,
	
}

function DialogueLoader:update(dt)
	self:resolveRequestStack()
	self:autoPlayDialogue(dt)
	self:removeInactivePlayers()
end

function DialogueLoader:addPlayerToActivePlayers(player)
	table.insert(self.activePlayers, player)
end

function DialogueLoader:removePlayerFromActivePlayers(player)
	for i=#self.activePlayers, 1 , -1 do
		if self.activePlayers[i] == player then
			table.remove(self.activePlayers, i)
			break
		end
	end
end

function DialogueLoader:getPlayerFromActivePlayersByDialogueId(dialogueId)
	for i=#self.activePlayers, 1 , -1 do
		if self.activePlayers[i].dialogueId == dialogueId then
			return self.activePlayers[i]
		end
	end
end

function DialogueLoader:getPlayerFromActivePlayersByParentEntity(parentEntity)
	for i=#self.activePlayers, 1 , -1 do
		if self.activePlayers[i].parentEntity == parentEntity then
			return self.activePlayers[i]
		end
	end
end

function DialogueLoader:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function DialogueLoader:removeRequestFromStack()
	table.remove(self.requestStack)
end

function DialogueLoader:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function DialogueLoader:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

function DialogueLoader:autoPlayDialogue(dt)
	self.autoPlayTimer = self.autoPlayTimer + dt
	
	if self.autoPlayTimer >= self.autoPlaySpeed then
		self:updateActivePlayers()
		self:resetAutoPlayTimer()
	end
end

function DialogueLoader:incrementAutoPlayTimer(dt)
	self.autoPlayTimer = self.autoPlayTimer + dt
end

function DialogueLoader:resetAutoPlayTimer()
	self.autoPlayTimer = 0
end

function DialogueLoader:updateActivePlayers()
	for i=#self.activePlayers, 1, -1 do
		self:updateActivePlayer(self.activePlayers[i])
	end
end

function DialogueLoader:updateActivePlayer(player)
	local segment = self.DIALOGUE_METHOD:runDialogueBySegment(self, player)
	player.currentSegment = segment
	
	if segment.type == self.SEGMENT_TYPE.TEXT then
		--render to screen
	elseif segment.type == self.SEGMENT_TYPE.CHOICE then
		self.DIALOGUE_METHOD:advanceDialogue(player)
		self:updateActivePlayer(player)
	elseif segment.type == self.SEGMENT_TYPE.END then
		self.DIALOGUE_METHOD:endDialogue(self, player)
	else
		self:updateActivePlayer(player)
	end
end

function DialogueLoader:removeInactivePlayers()
	for i=#self.activePlayers, 1 , -1 do
		if not self.activePlayers[i].state then
			table.remove(self.activePlayers, i)
		end
	end
end

-- * debug * --
--NOTE: do not use this! Make a real text renderer (with portraits, entity swapping and everything!)

function DialogueLoader:printDialogueLines(cameraX, cameraY)
	love.graphics.setColor(200, 0, 0, 1)
	
	for i=1, #self.activePlayers do
		self:printDialogueLine(self.activePlayers[i], cameraX, cameraY)
	end
	
	love.graphics.setColor(1, 1, 1, 1)
end

function DialogueLoader:printDialogueLine(player, cameraX, cameraY)
	if player.parentEntity and player.currentSegment then
		love.graphics.printf(player.currentSegment.text, math.floor((player.parentEntity.x - 10) - cameraX),
			math.floor((player.parentEntity.y - 30) - cameraY), 100, 'center')
	end
end

----------------
--Return Module:
----------------

return DialogueLoader