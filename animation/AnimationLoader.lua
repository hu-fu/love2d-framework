-------------------
--Animation Loader:
-------------------

local AnimationLoader = {}

---------------
--Dependencies:
---------------

require '/animation/AnimationObjects'
AnimationLoader.ANIMATIONS = require '/animation/ANIMATION'
AnimationLoader.ANIMATION_ASSETS = require '/animation/ANIMATION_ASSET'
AnimationLoader.ENTITY_DIRECTION = require '/entity state/ENTITY_DIRECTION'
local SYSTEM_ID = require '/system/SYSTEM_ID'

-------------------
--System Variables:
-------------------

AnimationLoader.id = SYSTEM_ID.ANIMATION_LOADER

AnimationLoader.eventDispatcher = nil
AnimationLoader.eventListenerList = {}

AnimationLoader.assetsFolderPath = '/animation/assets/'

AnimationLoader.animationList = {}	--[set_id][animation_id] = sprite animation object
AnimationLoader.defaultAnimation = nil

AnimationLoader.sortAnimationFrameUpdates = function(a, b) return a.updateTime < b.updateTime end

----------------
--Event Methods:
----------------

AnimationLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			--get animation
			
			local animation = AnimationLoader:getAnimation(request.animationSetId, request.animationId)
			
			if animation ~= nil then
				request.callback(request.spritebox, animation)
			end
		end
	}
}

---------------
--Init Methods:
---------------

function AnimationLoader:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function AnimationLoader:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function AnimationLoader:init()
	
end

---------------
--Exec Methods:
---------------

function AnimationLoader:resetAnimationList()
	for setName, animationSetId in pairs(self.ANIMATIONS) do
		self.animationList[animationSetId] = {}
		for animationName, animationId in pairs(self.ANIMATIONS[animationId]) do
			self.animationList[animationSetId][animationId] = nil
		end
	end
end

function AnimationLoader:getAnimationAssetFile(animationSetId)
	local animationAsset = self.ANIMATION_ASSETS[animationSetId]
	if animationAsset ~= nil then
		local path = self.assetsFolderPath .. animationAsset.filepath
		local assetFile = require(path)
		return assetFile
	end
	return nil
end

function AnimationLoader:loadAnimationSet(animationSetId)
	if self.animationList[animationSetId] == nil then
		local assetFile = self:getAnimationAssetFile(animationSetId)
		if assetFile ~= nil then
			self:createAnimationSet(animationSetId, assetFile)
		end
	end
end

function AnimationLoader:getAnimationSet(animationSetId)
	self:loadAnimationSet(animationSetId)
	if self.animationList[animationSetId] == nil then
		return nil		--consider returning an empty sprite animation object
	end
	return self.animationList[animationSetId]
end

function AnimationLoader:removeAnimationSet(animationSetId)
	self.animationList[animationSetId] = nil
end

function AnimationLoader:loadAnimation(animationSetId, animationId)
	self:loadAnimationSet(animationSetId)
	if self.animationList[animationSetId] == nil then return nil end
	if self.animationList[animationSetId][animationId] == nil then
		local assetFile = self:getAnimationAssetFile(animationSetId)
		if assetFile ~= nil then
			self:setAnimation(animationSetId, animationId, self:createAnimation(assetFile[animationId]))
		end
	end
	return self.animationList[animationSetId][animationId]
end

function AnimationLoader:getAnimation(animationSetId, animationId)
	local animationSet = self:getAnimationSet(animationSetId)
	if animationSet == nil then return nil end
	if animationSet[animationId] == nil then self:loadAnimation(animationSetId, animationId) end
	return animationSet[animationId]
end

function AnimationLoader:removeAnimation(animationSetId, animationId)
	self.animationList[animationSetId][animationId] = nil
end

function AnimationLoader:createAnimationSet(animationSetId, assetFile)
	for animationId, assetObject in pairs(assetFile) do
		self:setAnimation(animationSetId, animationId, self:createAnimation(assetObject))
	end
end

function AnimationLoader:createAnimation(assetObject)
	--parse object here:
	
	local animationObject = SpriteAnimation.new(assetObject.id, assetObject.spritesheetId, 
		assetObject.totalTime, {}, {}, assetObject.replay)
	self:setAnimationFrameUpdateTable(animationObject, assetObject)
	self:setAnimationQuadTable(animationObject, assetObject)
	return animationObject
end

function AnimationLoader:setAnimationFrameUpdateTable(animationObject, assetObject)
	for i=1, #assetObject.frameUpdates do
		table.insert(animationObject.frameUpdates, AnimationFrameUpdate.new(
			assetObject.frameUpdates[i].updateTime, assetObject.frameUpdates[i].frameIndex))
	end
	
	table.sort(animationObject.frameUpdates, self.sortAnimationFrameUpdates)
end

function AnimationLoader:setAnimationQuadTable(animationObject, assetObject)
	animationObject.quads[self.ENTITY_DIRECTION.UP] = assetObject.quads.UP
	animationObject.quads[self.ENTITY_DIRECTION.UP_LEFT] = assetObject.quads.UP_LEFT
	animationObject.quads[self.ENTITY_DIRECTION.LEFT] = assetObject.quads.LEFT
	animationObject.quads[self.ENTITY_DIRECTION.DOWN_LEFT] = assetObject.quads.DOWN_LEFT
	animationObject.quads[self.ENTITY_DIRECTION.DOWN] = assetObject.quads.DOWN
	animationObject.quads[self.ENTITY_DIRECTION.DOWN_RIGHT] = assetObject.quads.DOWN_RIGHT
	animationObject.quads[self.ENTITY_DIRECTION.RIGHT] = assetObject.quads.RIGHT
	animationObject.quads[self.ENTITY_DIRECTION.UP_RIGHT] = assetObject.quads.UP_RIGHT
end

function AnimationLoader:setAnimation(animationSetId, animationId, spriteAnimation)
	if self.animationList[animationSetId] == nil then
		self.animationList[animationSetId] = {}
	end
	
	self.animationList[animationSetId][animationId] = spriteAnimation	
end

--DEBUG:

--print animation

---------------
--Init Methods:
---------------

return AnimationLoader