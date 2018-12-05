------------------
--Dialogue Player:
------------------

DialoguePlayer = {}
DialoguePlayer.__index = DialoguePlayer

setmetatable(DialoguePlayer, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function DialoguePlayer.new (id)
	local self = setmetatable ({}, DialoguePlayer)
		self.id = id
		self.dialogueId = dialogueId
		
		self.threads = {}				--all lines indexed by thread
		self.specialLines = {}			--lines with id indexing
		
		self.selectedChoice = {}		--selected options indexed by options lines
		
		self.parentEntity = nil
		self.controller = nil
		
		self.currentLine = 1
		self.currentThread = 1
	return self
end
