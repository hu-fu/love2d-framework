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
		self.dialogueId = nil
		self.returnType = 1				--string default
		
		self.threads = {}				--all lines indexed by thread
		self.specialLines = {}			--lines with id indexing
		
		self.selectedChoice = {}		--selected options indexed by options lines
		
		self.parentEntity = nil
		self.controller = nil
		
		self.currentLine = 1
		self.currentThread = 1
	return self
end

------------------------
--Dialogue Player Pool:
------------------------

DialoguePlayerObjectPool = {}
DialoguePlayerObjectPool.__index = DialoguePlayerObjectPool

setmetatable(DialoguePlayerObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function DialoguePlayerObjectPool.new (maxDialoguePlayerObjects, resizable)
	local self = setmetatable ({}, DialoguePlayerObjectPool)
		
		self.objectList = {}
		self.currentIndex = 1
		self.defaultMaxObjects = maxDialoguePlayerObjects
		self.resizable = resizable
		
		self:buildDialoguePlayerObjectPool()
	return self
end

function DialoguePlayerObjectPool:buildDialoguePlayerObjectPool()
	for i=1, self.defaultMaxObjects do
		self:createDialoguePlayerObject(i)
	end
end

function DialoguePlayerObjectPool:createDialoguePlayerObject(id)
	table.insert(self.objectList, DialoguePlayer.new(id))
end

function DialoguePlayerObjectPool:getCurrentAvailableDialoguePlayerObject()
	--action type is optional, it's set to default if you don't pass it
	local current = self.objectList[self.currentIndex]
	self:incrementCurrentIndex()
	return current
end

function DialoguePlayerObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function DialoguePlayerObjectPool:incrementCurrentIndex()
	if self.currentIndex == #self.objectList then
		if self.resizable then
			self:createDialoguePlayerObject()
			self.currentIndex = self.currentIndex + 1
		else
			self:resetCurrentIndex()
		end
	else
		self.currentIndex = self.currentIndex + 1
	end
end

function DialoguePlayerObjectPool:resetObjectListSize()
	for i=#self.objectList, self.defaultMaxObjects, -1 do
		table.remove(self.objectList)
	end
end

-------------------
--Dialogue Segment:
-------------------

DialogueSegment = {}
DialogueSegment.__index = DialogueSegment

setmetatable(DialogueSegment, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function DialogueSegment.new ()
	local self = setmetatable ({}, DialogueSegment)
		self.type = nil
		self.line = nil
		
		self.text = ''
		self.options = nil
	return self
end

------------------------
--Dialogue Segment Pool:
------------------------

DialogueSegmentObjectPool = {}
DialogueSegmentObjectPool.__index = DialogueSegmentObjectPool

setmetatable(DialogueSegmentObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function DialogueSegmentObjectPool.new (maxDialogueSegmentObjects, resizable)
	local self = setmetatable ({}, DialogueSegmentObjectPool)
		
		self.objectList = {}
		self.currentIndex = 1
		self.defaultMaxObjects = maxDialogueSegmentObjects
		self.resizable = resizable
		
		self:buildDialogueSegmentObjectPool()
	return self
end

function DialogueSegmentObjectPool:buildDialogueSegmentObjectPool()
	for i=1, self.defaultMaxObjects do
		self:createDialogueSegmentObject()
	end
end

function DialogueSegmentObjectPool:createDialogueSegmentObject()
	table.insert(self.objectList, DialogueSegment.new())
end

function DialogueSegmentObjectPool:getCurrentAvailableDialogueSegmentObject()
	--action type is optional, it's set to default if you don't pass it
	local current = self.objectList[self.currentIndex]
	self:incrementCurrentIndex()
	return current
end

function DialogueSegmentObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function DialogueSegmentObjectPool:incrementCurrentIndex()
	if self.currentIndex == #self.objectList then
		if self.resizable then
			self:createDialogueSegmentObject()
			self.currentIndex = self.currentIndex + 1
		else
			self:resetCurrentIndex()
		end
	else
		self.currentIndex = self.currentIndex + 1
	end
end

function DialogueSegmentObjectPool:resetObjectListSize()
	for i=#self.objectList, self.defaultMaxObjects, -1 do
		table.remove(self.objectList)
	end
end