--------------------------
--Animation System Module:
--------------------------

--[[
DEPRECATED!!
]]

local animationSystem = {}

local SYSTEM_ID = require '/system/SYSTEM_ID'
animationSystem.id = SYSTEM_ID.ANIMATION

animationSystem.spriteBoxComponentTable = {}
animationSystem.animationRepositoryList = {}
animationSystem.eventDispatcher = nil
animationSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

animationSystem.eventMethods = {
	--animationRequest = {'spritebox row', 'spritesheetId', 'quad', 'spriteAnimationId', 'interval'}
	
	[1] = {
		[1] = function(animationRequest)
			--update animation
			animationSystem:updateAnimation(animationRequest[1], animationRequest[4], animationRequest[5])
		end,
		
		[2] = function(animationRequest)
			--set image rendering data
			animationSystem:setSpritesheetId(animationRequest[1], animationRequest[2])
			animationSystem:setQuad(animationRequest[1], animationRequest[3])
		end
	}
}

---------------
--Init Methods:
---------------

function animationSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function animationSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function animationSystem:setSpriteBoxComponentTable(spriteBoxComponentTable)
	self.spriteBoxComponentTable = spriteBoxComponentTable
end

function animationSystem:setAnimationRepository(id, animationRepository)
	self.animationRepositoryList[id] = animationRepository
end

---------------
--Exec Methods:
---------------

function animationSystem:setSpritesheetId(spriteBoxRow, spritesheetId)
	if spritesheetId then
		spriteBoxRow.spritesheetId = spritesheetId
	else
		spriteBoxRow.spritesheetId = spriteBoxRow.defaultSpritesheetId
	end
end

function animationSystem:setDefaultSpritesheetId(spriteBoxRow, defaultSpritesheetId)
	spriteBoxRow.defaultSpritesheetId = defaultSpritesheetId
end

function animationSystem:setQuad(spriteBoxRow, newQuad)
	spriteBoxRow.quad = newQuad
end

function animationSystem:incrementAnimationFrame(spriteBoxRow, spriteAnimationId, interval)
	spriteBoxRow.quad = spriteBoxRow.quad + 
		self.animationRepositoryList[spriteBoxRow.aniRepoId]:getFrameUpdateValue(spriteAnimationId, interval)
end

function animationSystem:playAnimationSound(spriteBoxRow, spriteAnimationId, interval)
	if self.animationRepositoryList[spriteBoxRow.aniRepoId]:getSoundEffectId(spriteAnimationId, interval) then
		--play sound
	end
end

--dunno about this... it's cool (15-02-2017)
function animationSystem:playSpecialEffect(spriteBoxRow, spriteAnimationId, interval)
	if self.animationRepositoryList[spriteBoxRow.aniRepoId]:getSpecialEffectId(spriteAnimationId, interval) then
		--play special effect
	end
end

function animationSystem:updateAnimation(spriteBoxRow, spriteAnimationId, interval)
	self:incrementAnimationFrame(spriteBoxRow, spriteAnimationId, interval)
	self:playAnimationSound(spriteBoxRow, spriteAnimationId, interval)
	self:playSpecialEffect(spriteBoxRow, spriteAnimationId, interval)
end

----------------
--Return Module:
----------------

return animationSystem