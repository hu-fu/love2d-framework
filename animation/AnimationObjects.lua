-------------------
--Sprite Animation:
-------------------

SpriteAnimation = {}
SpriteAnimation.__index = SpriteAnimation

setmetatable(SpriteAnimation, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpriteAnimation.new (id, spritesheetId, totalTime, frameUpdates, quads, replay)
	local self = setmetatable ({}, SpriteAnimation)
		self.id = id
		self.spritesheetId = spritesheetId
		self.totalTime = totalTime
		self.frameUpdates = frameUpdates
		self.quads = quads						--{DIRECTION = {quad A, quad B, ...}, ...}
		self.replay = replay					--bool
	return self
end

-------------------------
--Animation Frame Update:
-------------------------

AnimationFrameUpdate = {}
AnimationFrameUpdate.__index = AnimationFrameUpdate

setmetatable(AnimationFrameUpdate, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function AnimationFrameUpdate.new (updateTime, frameIndex)
	local self = setmetatable ({}, AnimationFrameUpdate)
		self.updateTime = updateTime
		self.frameIndex = frameIndex
	return self
end

--------------------------
--Sprite Animation Player:
--------------------------

SpriteAnimationPlayer = {}
SpriteAnimationPlayer.__index = SpriteAnimationPlayer

setmetatable(SpriteAnimationPlayer, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpriteAnimationPlayer.new ()
	local self = setmetatable ({}, SpriteAnimationPlayer)
		self.animation = nil
		self.currentTime = 0
		self.updatePoint = 0
		self.currentUpdateIndex = 0
	return self
end

-------------------------------
--Sprite Animation Player Pool:
-------------------------------

SpriteAnimationPlayerObjectPool = {}
SpriteAnimationPlayerObjectPool.__index = SpriteAnimationPlayerObjectPool

setmetatable(SpriteAnimationPlayerObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpriteAnimationPlayerObjectPool.new (defaultNumberOfObjects)
	local self = setmetatable ({}, SpriteAnimationPlayerObjectPool)
		
		self.objectPool = {}
		self.currentIndex = 1
		
		self.defaultNumberOfObjects = defaultNumberOfObjects
	return self
end

function SpriteAnimationPlayerObjectPool:createNewObject()
	local objectId = #self.objectPool + 1
	local object = SpriteAnimationPlayer.new()
	table.insert(self.objectPool, object)
end

function SpriteAnimationPlayerObjectPool:buildObjectPool()
	for i=1, self.defaultNumberOfObjects do
		self:createNewObject()
	end
end

function SpriteAnimationPlayerObjectPool:getCurrentAvailableObject()
	return self.objectPool[self.currentIndex]
end

function SpriteAnimationPlayerObjectPool:getLength()
	return self.currentIndex - 1
end

function SpriteAnimationPlayerObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function SpriteAnimationPlayerObjectPool:incrementCurrentIndex()
	if self.currentIndex == #self.objectPool then
		self:createNewObject()
	end
	self.currentIndex = self.currentIndex + 1
end

function SpriteAnimationPlayerObjectPool:resetObjectPoolSize()
	for i=#self.objectPool, self.defaultNumberOfObjects, -1 do
		table.remove(self.objectPool)
	end
end