-------------------
--Item object pool:
-------------------

ItemObjectPool = {}
ItemObjectPool.__index = ItemObjectPool

setmetatable(ItemObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function ItemObjectPool.new (defaultNumberOfObjects)
	local self = setmetatable ({}, ItemObjectPool)
		self.objectPool = {}
		self.currentIndex = 1
		self.resizable = false
		
		self.defaultNumberOfObjects = defaultNumberOfObjects
		self:buildObjectPool()
	return self
end

function ItemObjectPool:createNewObject()
	--do not use
end

function ItemObjectPool:buildObjectPool()
	--do not use
end

function ItemObjectPool:getCurrentAvailableObject()
	return self.objectPool[self.currentIndex]
end

function ItemObjectPool:getLength()
	return self.currentIndex - 1
end

function ItemObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function ItemObjectPool:incrementCurrentIndex()
	self.currentIndex = self.currentIndex + 1
end

function ItemObjectPool:resetObjectPoolSize()
	for i=#self.objectPool, self.defaultNumberOfObjects, -1 do
		table.remove(self.objectPool)
	end
end

function ItemObjectPool:setResizableState(resizable)
	self.resizable = resizable
end