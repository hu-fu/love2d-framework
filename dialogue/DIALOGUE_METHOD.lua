-------------------
--Dialogue Methods:
-------------------

DIALOGUE_METHODS = {}

require '/dialogue/DialogueObjects'
DIALOGUE_METHODS.DIALOGUE = require '/dialogue/DIALOGUE'
DIALOGUE_METHODS.ACTOR = require '/dialogue/ACTOR'
DIALOGUE_METHODS.SEGMENT_TYPE = require '/dialogue/SEGMENT_TYPE'

DIALOGUE_METHODS.segmentObjectPool = DialogueSegmentObjectPool.new (50, false)

function DIALOGUE_METHODS:startDialogue(system, player)
	player.state = true
	self:runControllerHeader(system, player)
	self:advanceDialogue(player)
end

function DIALOGUE_METHODS:runDialogueBySegment(system, player)
	--returns a dialogue segment
	
	local currentLine = self:getCurrentLine(player)
	local segment = self.getSegment[currentLine.action](self, system, player, currentLine)
	
	self:runControllerBody(player, currentLine)
	
	return segment
end

function DIALOGUE_METHODS:runDialogueByLine(system, player)
	--returns a raw dialogue line - avoid using - doesn't work
	
end

function DIALOGUE_METHODS:endDialogue(system, player)
	self:runControllerFooter(system, player)
	player.state = false
end

function DIALOGUE_METHODS:selectChoice(player, line, choiceId)
	self:saveChoice(player, line, choiceId)
	for i=1, #line.choice do
		if line.choice[i].id == choiceId then
			self:jumpThread(player, line.choice[i].jumpToThread)
			break
		end
	end
end

function DIALOGUE_METHODS:saveChoice(player, line, choiceId)
	if line.persistent then
		table.insert(player.savedChoices[line.line], choiceId)
	end
end

function DIALOGUE_METHODS:getAvailableChoices(player, line)
	local availableChoices = {}
	local savedChoices = player.selectedChoice[line.line]
	local selected = false
	
	for i=1, #line.choice do
		selected = false
			
		for j=1, #savedChoices do
			if line.choice[i] == savedChoices then
				selected = true
				break
			end
		end
			
		if not selected then
			table.insert(availableChoices, line.choice[i])
		end
	end
	
	return availableChoices
end

function DIALOGUE_METHODS:advanceDialogue(player)
	if self:isThreadOver(player) then
		player.currentLine = 1
		player.currentThread = player.currentThread + 1
	else
		player.currentLine = player.currentLine + 1
	end
end

function DIALOGUE_METHODS:getCurrentLine(player)
	return player.threads[player.currentThread][player.currentLine]
end

function DIALOGUE_METHODS:getLineByThreadAndNumber(player, lineThread, lineNumber)
	return player.threads[lineThread][lineNumber]
end

function DIALOGUE_METHODS:getLineByNumber(player, lineNumber)
	for threadId, thread in pairs(self.threads) do
		for i=1, #thread do
			if thread[i].line == lineNumber then
				return thread[i]
			end
		end
	end
	
	return nil
end

function DIALOGUE_METHODS:getLineById(player, lineId)
	for threadId, thread in pairs(self.threads) do
		for i=1, #thread do
			if thread[i].lineId and hread[i].lineId == lineId then
				return thread[i]
			end
		end
	end
	
	return nil
end

function DIALOGUE_METHODS:getCurrentThread(player)
	return player.threads[player.currentThread]
end

function DIALOGUE_METHODS:getThreadStart(player, threadId)
	if #player.threads[threadId] > 0 then
		return player.threads[threadId][1]
	end
end

function DIALOGUE_METHODS:isThreadOver(player)
	local thread = self:getCurrentThread(player)
	
	if player.currentLine == thread[#thread].line then
		return true
	end
	
	return false
end

function DIALOGUE_METHODS:jumpThread(player, nextThread)
	player.currentLine = 1
	player.currentThread = nextThread
end

DIALOGUE_METHODS.getSegment = {
	['none'] = function(self, system, player, currentLine)
		self:advanceDialogue(player)
		
		local segment = self.segmentObjectPool:getCurrentAvailableDialogueSegmentObject()
		
		segment.type = self.SEGMENT_TYPE.TEXT
		segment.line = currentLine
		segment.text = currentLine.text
		segment.actorId = currentLine.actorId
		segment.actorName = currentLine.actorName
		segment.targetEntityId = currentLine.targetEntityId
		
		player.updateTime = currentLine.activeTime
		
		return segment
	end,
	
	['choice'] = function(self, system, player, currentLine)
		local segment = self.segmentObjectPool:getCurrentAvailableDialogueSegmentObject()
		
		segment.type = self.SEGMENT_TYPE.CHOICE
		segment.line = currentLine
		
		if segment.line.persistent then
			segment.options = self:getAvailableChoices(player, currentLine)
		end
		
		return segment
	end,
	
	['jump_thread'] = function(self, system, player, currentLine)
		self:jumpThread(player, currentLine.nextThread)
		
		local segment = self.segmentObjectPool:getCurrentAvailableDialogueSegmentObject()
		segment.type = self.SEGMENT_TYPE.JUMP_LINE
		
		return segment
	end,
	
	['start'] = function(self, system, player, currentLine)
		local segment = self.segmentObjectPool:getCurrentAvailableDialogueSegmentObject()
		segment.type = self.SEGMENT_TYPE.START
		
		self:startDialogue(system, player)
		
		return segment
	end,
	
	['end'] = function(self, system, player, currentLine)
		local segment = self.segmentObjectPool:getCurrentAvailableDialogueSegmentObject()
		segment.type = self.SEGMENT_TYPE.END
		
		self:endDialogue(system, player)
		
		return segment
	end,
}

function DIALOGUE_METHODS:createDialogueSegment(segmentType, currentLine)
	local segment = self.segmentObjectPool:getCurrentAvailableDialogueSegmentObject()
	
	segment.type = segmentType
	segment.line = currentLine
	segment.text = currentLine.text
	segment.options = currentLine.options
end

function DIALOGUE_METHODS:runControllerHeader(system, player)
	player.controller.header.method(player.controller, system, player)
end

function DIALOGUE_METHODS:runControllerBody(player, currentLine)
	if currentLine.id ~= nil then
		local controller = player.controller
		
		for i=1, #controller.body do
			if currentLine.id == controller.body[i].lineId then
				controller.body[i].method(controller, self, player)
				break
			end
		end
	end
end

function DIALOGUE_METHODS:runControllerFooter(system, player)
	player.controller.footer.method(player.controller, system, player)
end

return DIALOGUE_METHODS