--------------
--Interaction:
--------------

Interaction = {}
Interaction.__index = Interaction

setmetatable(Interaction, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function Interaction.new ()
	local self = setmetatable ({}, Interaction)
		self.interactionType = nil
		self.interactionId = nil
		
		self.area = {
			x=0, y=0, w=0, h=0
		}
		
		self.origin = nil			--spatialEntity.parentEntity
		self.targetRole = nil
		self.targets = nil
	return self
end

-------------------
--Interaction Pool:
-------------------

InteractionObjectPool = {}
InteractionObjectPool.__index = InteractionObjectPool

setmetatable(InteractionObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function InteractionObjectPool.new (maxInteractionObjects, resizable)
	local self = setmetatable ({}, InteractionObjectPool)
		
		self.objectList = {}
		self.currentIndex = 1
		self.defaultMaxObjects = maxInteractionObjects
		self.resizable = resizable
		
		self:buildInteractionObjectPool()
	return self
end

function InteractionObjectPool:buildInteractionObjectPool()
	for i=1, self.defaultMaxObjects do
		self:createInteractionObject()
	end
end

function InteractionObjectPool:createInteractionObject()
	table.insert(self.objectList, Interaction.new())
end

function InteractionObjectPool:getCurrentAvailableInteractionObject()
	--action type is optional, it's set to default if you don't pass it
	local current = self.objectList[self.currentIndex]
	return current
end

function InteractionObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function InteractionObjectPool:incrementCurrentIndex()
	if self.currentIndex == #self.objectList then
		if self.resizable then
			self:createInteractionObject()
			self.currentIndex = self.currentIndex + 1
		else
			self:resetCurrentIndex()
		end
	else
		self.currentIndex = self.currentIndex + 1
	end
end

function InteractionObjectPool:resetObjectListSize()
	for i=#self.objectList, self.defaultMaxObjects, -1 do
		table.remove(self.objectList)
	end
end