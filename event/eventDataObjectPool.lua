-------------------------
--Event Data Object Pool:
-------------------------
--Avoids allocating memory every time we dispatch an event
--This is the simplified version, substitute for the recent one
--DEPRECATED SO HARD ITS NOT EVEN FUNNY

eventDataObjectPool = {}
eventDataObjectPool.__index = eventDataObjectPool

setmetatable(eventDataObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function eventDataObjectPool.new (numberOfColumns, columnNames, defaultNumberOfObjects)
	local self = setmetatable ({}, eventDataObjectPool)
		
		self.objectPool = {}
		self.currentIndex = 1
		
		self.numberOfColumns = numberOfColumns
		self.columnNames = columnNames
		self.defaultNumberOfObjects = defaultNumberOfObjects
	return self
end

function eventDataObjectPool:createNewDataObject()
	local newDataObject = {}
	for i=1, self.numberOfColumns do
		table.insert(newDataObject, 1)
	end
	table.insert(self.objectPool, newDataObject)
end

function eventDataObjectPool:buildObjectPool()
	for i=1, self.defaultNumberOfObjects do
		self:createNewDataObject()
	end
end

function eventDataObjectPool:getCurrentAvailableObject()
	return self.objectPool[self.currentIndex]
end

function eventDataObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function eventDataObjectPool:incrementCurrentIndex()
	if self.currentIndex == #self.objectPool then
		self:createNewDataObject()
	end
	self.currentIndex = self.currentIndex + 1
end

function eventDataObjectPool:resetObjectPoolSize()
	for i=#self.objectPool, self.defaultNumberOfObjects, -1 do
		table.remove(self.objectPool)
	end
end