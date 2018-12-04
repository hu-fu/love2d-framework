------------------
--Dialogue Loader:
------------------

local DialogueLoader = {}

---------------
--Dependencies:
---------------

DialogueLoader.DIALOGUE = require '/dialogue/DIALOGUE'
DialogueLoader.ACTOR = require '/dialogue/ACTOR'
DialogueLoader.LINE_TYPE = require '/dialogue/LINE_TYPE'

-------------------
--System Variables:
-------------------

DialogueLoader.id = SYSTEM_ID.DIALOGUE_LOADER

DialogueLoader.eventDispatcher = nil
DialogueLoader.eventListenerList = {}

----------------
--Event Methods:
----------------

DialogueLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			
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

function DialogueLoader:setParentEntity(player, controller)
	if controller then
		player.controller = controller
	end
end

function DialogueLoader:getDialogueController(dialogueId)
	--TODO
end

---------------
--Init Methods:
---------------

return DialogueLoader