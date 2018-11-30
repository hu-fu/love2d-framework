---------------
--Sound player:
---------------

SoundPlayer = {}
SoundPlayer.__index = SoundPlayer

setmetatable(SoundPlayer, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SoundPlayer.new ()
	local self = setmetatable ({}, SoundPlayer)
		
		id = nil
		name = nil
		state = false
		
		source = nil
		soundType = nil
		volume = 0
		effect = nil
		
		parentEntity = nil
		distance = false
		x = 0
		y = 0
		
	return self
end

--------------------
--Sound Player Pool:
--------------------

SoundPlayerObjectPool = {}
SoundPlayerObjectPool.__index = SoundPlayerObjectPool

setmetatable(SoundPlayerObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SoundPlayerObjectPool.new (defaultNumberOfObjects)
	local self = setmetatable ({}, SoundPlayerObjectPool)
		self.objectPool = {}
		self.currentIndex = 1
		self.resizable = false
		
		self.defaultNumberOfObjects = defaultNumberOfObjects
		self:buildObjectPool()
	return self
end

function SoundPlayerObjectPool:createNewObject()
	return SoundPlayer.new()
end

function SoundPlayerObjectPool:buildObjectPool()
	for i=1, self.defaultNumberOfObjects do
		table.insert(self.objectPool, self:createNewObject())
	end
end

function SoundPlayerObjectPool:getCurrentAvailableObject()
	return self.objectPool[self.currentIndex]
end

function SoundPlayerObjectPool:getLength()
	return self.currentIndex - 1
end

function SoundPlayerObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function SoundPlayerObjectPool:incrementCurrentIndex()
	self.currentIndex = self.currentIndex + 1
end

function SoundPlayerObjectPool:resetObjectPoolSize()
	for i=#self.objectPool, self.defaultNumberOfObjects, -1 do
		table.remove(self.objectPool)
	end
end

function SoundPlayerObjectPool:setResizableState(resizable)
	self.resizable = resizable
end