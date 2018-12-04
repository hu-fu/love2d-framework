-------------------
--Dialogue Methods:
-------------------
--I don't know what the fuck I'm doing

DIALOGUE_METHODS = {}

DIALOGUE_METHODS.DIALOGUE = require '/dialogue/DIALOGUE'
DIALOGUE_METHODS.ACTOR = require '/dialogue/ACTOR'
DIALOGUE_METHODS.LINE_TYPE = require '/dialogue/LINE_TYPE'

function DIALOGUE_METHODS:startDialogue(system, player, component)
	player.controller.header.method(player.controller, system, player, component)
end

function DIALOGUE_METHODS:runDialogue(system, player, component)
	--run line by action
	--return line as RETURN TYPE! (string, box, ...)
end

function DIALOGUE_METHODS:endDialogue(system, player, component)
	player.controller.footer.method(player.controller, system, player, component)
end

function DIALOGUE_METHODS:selectChoice(player, line, choiceId)
	self:saveChoice(player, line, choiceId)
	
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
	
	if line.persistent then
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
	end
	
	return choices
end

function DIALOGUE_METHODS:getCurrentLine(player, currentLine)
	return player.threads[player.currentThread][player.currentLine]
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

function DIALOGUE_METHODS:getLineById(player, id)
	for lineId, line in ipairs(player.specialLines) do
		if lineId == id then
			return line
		end
	end
	
	return nil
end

function DIALOGUE_METHODS:getThreadStart(player, threadId)
	return player.threads[threadId]
end

function DIALOGUE_METHODS:isThreadOver(currentLine, thread)
	if currentLine == #thread[currentLine.thread] then
		return true
	end
	
	return false
end