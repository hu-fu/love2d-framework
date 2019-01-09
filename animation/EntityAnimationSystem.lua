-------------------
--Animation system:
-------------------

local EntityAnimationSystem = {}

---------------
--Dependencies:
---------------

require '/animation/AnimationObjects'
EntityAnimationSystem.ANIMATIONS = require '/animation/ANIMATION'
EntityAnimationSystem.ENTITY_DIRECTION = require '/entity state/ENTITY_DIRECTION'
EntityAnimationSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityAnimationSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityAnimationSystem.EVENT_TYPES = require '/event/EVENT_TYPE'
local SYSTEM_ID = require '/system/SYSTEM_ID'

-------------------
--System Variables:
-------------------

EntityAnimationSystem.id = SYSTEM_ID.ENTITY_ANIMATION

EntityAnimationSystem.spriteComponentTable = {}

EntityAnimationSystem.animationLoaderRequestPool = EventObjectPool.new(EntityAnimationSystem.EVENT_TYPES.ANIMATION, 100)

EntityAnimationSystem.spriteAnimationPlayerObjectPool = SpriteAnimationPlayerObjectPool.new(100)
EntityAnimationSystem.spriteAnimationPlayerObjectPool:buildObjectPool()

EntityAnimationSystem.eventDispatcher = nil
EntityAnimationSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

EntityAnimationSystem.eventMethods = {
	
	[1] = {
		[1] = function(request)
			--set entity component table
			EntityAnimationSystem:setSpriteComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--set and start animation
			EntityAnimationSystem:getAnimation(request.animationSetId, request.animationId, 
				request.spritebox)
		end,
		
		[3] = function(request)
			--refresh animation (use to set a new animation direction)
			EntityAnimationSystem:showAnimationFrame(request.spritebox)
		end,
		
		[4] = function(request)
			--start animation
			EntityAnimationSystem:setAnimationOnSpritebox(request.spritebox, request.animationObject)
		end
	}
}

---------------
--Init Methods:
---------------

function EntityAnimationSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function EntityAnimationSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function EntityAnimationSystem:setSpriteComponentTable(entityDb)
	self.spriteComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.SPRITEBOX)
	self:setAnimationPlayerOnSpriteboxList()
end

function EntityAnimationSystem:init()
	
end

---------------
--Exec Methods:
---------------

function EntityAnimationSystem:update(dt)
	for i=1, #self.spriteComponentTable do
		if self.spriteComponentTable[i].animationPlayer and 
			self.spriteComponentTable[i].animationPlayer.animation then
			
			self:playAnimation(dt, self.spriteComponentTable[i])
		end
	end
end

function EntityAnimationSystem:resetspriteComponentTable()
	self.spriteComponentTable = {}
end

function EntityAnimationSystem:setAnimationPlayerOnSpriteboxList()
	for i=1, #self.spriteComponentTable do
		self:setAnimationPlayerOnSpritebox(self.spriteComponentTable[i])
	end
end

function EntityAnimationSystem:setAnimationPlayerOnSpritebox(spritebox)
	if spritebox.animationPlayer == nil then
		local animationPlayer = self.spriteAnimationPlayerObjectPool:getCurrentAvailableObject()
		spritebox.animationPlayer = animationPlayer
		self.spriteAnimationPlayerObjectPool:incrementCurrentIndex()
	end
end

function EntityAnimationSystem:getAnimation(animationSetId, animationId, spritebox)
	local eventObj = self.animationLoaderRequestPool:getCurrentAvailableObject()
	
	eventObj.animationSetId = animationSetId
	eventObj.animationId = animationId
	eventObj.spritebox = spritebox
	eventObj.callback = self:getAnimationRequestCallbackMethod()
	
	self.eventDispatcher:postEvent(1, 1, eventObj)
	self.animationLoaderRequestPool:incrementCurrentIndex()
end

function EntityAnimationSystem:setAnimationOnSpritebox(spritebox, animationObject)
	--callback for event request
	self:setAnimationPlayerOnSpritebox(spritebox)	--should gtfo, no it shouldn't
	spritebox.spritesheetId = animationObject.spritesheetId
	spritebox.animationPlayer.animation = animationObject
	self:resetAnimation(spritebox)
end

function EntityAnimationSystem:resetAnimationPlayer(animationPlayer)
	animationPlayer.currentTime = 0
	animationPlayer.updatePoint = 0
	animationPlayer.currentUpdateIndex = 0
end

function EntityAnimationSystem:resetAnimation(spritebox)
	self:resetAnimationPlayer(spritebox.animationPlayer)
	self:updateAnimation(spritebox, spritebox.animationPlayer)
end

function EntityAnimationSystem:updateAnimation(spritebox)
	self:setNewUpdatePoint(spritebox.animationPlayer)
	self:showAnimationFrame(spritebox)
end

function EntityAnimationSystem:setNewUpdatePoint(animationPlayer)
	if animationPlayer.currentUpdateIndex == #animationPlayer.animation.frameUpdates then
		animationPlayer.updatePoint = animationPlayer.animation.totalTime
	else
		animationPlayer.currentUpdateIndex = animationPlayer.currentUpdateIndex + 1
		animationPlayer.updatePoint = 
			animationPlayer.animation.frameUpdates[animationPlayer.currentUpdateIndex].updateTime
	end
end

function EntityAnimationSystem:showAnimationFrame(spritebox)
	local quadIndex = spritebox.animationPlayer.animation.frameUpdates[spritebox.animationPlayer.currentUpdateIndex].frameIndex
	spritebox.quad = spritebox.animationPlayer.animation.quads[spritebox.direction][quadIndex]
end

function EntityAnimationSystem:playAnimation(dt, spritebox)
	local animationPlayer = spritebox.animationPlayer
	
	animationPlayer.currentTime = animationPlayer.currentTime + dt
	
	if animationPlayer.currentTime >= animationPlayer.animation.totalTime then
		if animationPlayer.animation.replay then
			self:resetAnimation(spritebox)
		else
			animationPlayer.currentTime = animationPlayer.currentTime - dt
		end
	else
		if animationPlayer.currentTime >= animationPlayer.updatePoint then
			self:updateAnimation(spritebox)
		end
	end
end

function EntityAnimationSystem:getAnimationRequestCallbackMethod()
	return function (spritebox, animationObject)
		self:setAnimationOnSpritebox(spritebox, animationObject) 
	end
end

--DEBUG

function EntityAnimationSystem:debug_getAnimation(animationSetId, animationId)
	local eventObj = self.animationLoaderRequestPool:getCurrentAvailableObject()
	
	eventObj.animationSetId = animationSetId
	eventObj.animationId = animationId
	eventObj.spritebox = nil
	eventObj.callback = nil
	
	self.eventDispatcher:postEvent(1, 1, eventObj)
	self.animationLoaderRequestPool:incrementCurrentIndex()
end

----------------
--Return Module:
----------------

return EntityAnimationSystem