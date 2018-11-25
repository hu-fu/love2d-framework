--[[
Storage for animation info objects
One repository per entity type
We can make entities share repositories
we need more systems to deal with movement, hb detection and etc
Those go into other systems. This one is just for the visual stuff!
New names for these two classes. No 'manager' or other shit.
deprecated
]]

----------------------------------
--spriteAnimationRepository class:
----------------------------------

spriteAnimationRepository = {}
spriteAnimationRepository.__index = spriteAnimationRepository

setmetatable(spriteAnimationRepository, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function spriteAnimationRepository.new (id)
	local self = setmetatable ({}, spriteAnimationRepository)
		self.id = id
		self.spriteAnimationList = {}
	return self
end

function spriteAnimationRepository:createSpriteAnimation(id, frameUpdateValues, soundEffectValues, specialEffectValues)
	self.spriteAnimationList[id] = spriteAnimation.new(id)
	self:setSpriteAnimationFrameUpdateValues(id, frameUpdateValues)
	self:setSpriteAnimationSoundEffectValues(id, soundEffectValues)
	self:setSpriteAnimationSpecialEffectValues(id, specialEffectValues)
end

function spriteAnimationRepository:setSpriteAnimationFrameUpdateValues(id, frameUpdateValues)
	for i, value in pairs(frameUpdateValues) do
		self.spriteAnimationList[id].frameUpdates[i] = value
	end
	setDefaultTableValue(self.spriteAnimationList[id].frameUpdates, 0)
end

function spriteAnimationRepository:setSpriteAnimationSoundEffectValues(id, soundEffectValues)
	for i, value in pairs(soundEffectValues) do
		self.spriteAnimationList[id].soundEffects[i] = value
	end
	setDefaultTableValue(self.spriteAnimationList[id].soundEffects, false)
end

function spriteAnimationRepository:setSpriteAnimationSpecialEffectValues(id, specialEffectValues)
	for i, value in pairs(specialEffectValues) do
		self.spriteAnimationList[id].specialEffects[i] = value
	end
	setDefaultTableValue(self.spriteAnimationList[id].specialEffects, false)
end

function spriteAnimationRepository:deleteSpriteAnimation(id)
	self.spriteAnimationList[id] = nil
end

function spriteAnimationRepository:getFrameUpdateValue(spriteAnimationId, interval)
	return self.spriteAnimationList[spriteAnimationId].frameUpdates[interval]
end

function spriteAnimationRepository:getSoundEffectId(spriteAnimationId, interval)
	return self.spriteAnimationList[spriteAnimationId].soundEffects[interval]
end

function spriteAnimationRepository:getSpecialEffectId(spriteAnimationId, interval)
	return self.spriteAnimationList[spriteAnimationId].specialEffects[interval]
end

------------------------
--spriteAnimation class:
------------------------
--Holds animation data. Methods are in the repository class.

spriteAnimation = {}
spriteAnimation.__index = spriteAnimation

setmetatable(spriteAnimation, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function spriteAnimation.new (id)
	local self = setmetatable ({}, spriteAnimation)
		self.id = id
		self.frameUpdates = {}		--hashtbl [t] = increment value
		self.soundEffects = {}		--hashtbl [t] = sound_id
		self.specialEffects = {}	--hashtbl [t] = sfx_id
	return self
end