require 'misc'

------------------------
--Effect Emitter object:
------------------------

EffectEmitter = {}
EffectEmitter.__index = EffectEmitter

setmetatable(EffectEmitter, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EffectEmitter.new ()
	local self = setmetatable ({}, EffectEmitter)
		self.active = false
		self.emitterType = 0
		
		self.role = nil
		self.spatialEntity = nil
		
		self.x = 0
		self.y = 0
		self.w = 0
		self.h = 0
		self.direction = 0
		self.deviationX = 0
		self.deviationY = 0
		
		self.focus = false
		self.focusEntity = nil
		
		self.actionSetId = nil
		self.action = nil
		self.currentTime = 0
		self.updatePoint = 0
		self.frameCounter = 0		--OH MY GOOOOOOOOOOOOOOOOOOOOOOOOOOOOD
		self.currentMethodIndex = 1
		self.methodThreads = {}
		
		self.effectList = {}
	return self
end

-----------------------------
--Effect Emitter object pool:
-----------------------------

EffectEmitterObjectPool = {}
EffectEmitterObjectPool.__index = EffectEmitterObjectPool

setmetatable(EffectEmitterObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EffectEmitterObjectPool.new (defaultNumberOfObjects)
	local self = setmetatable ({}, EffectEmitterObjectPool)
		self.objectPool = {}
		self.currentIndex = 1
		self.resizable = false
		
		self.defaultNumberOfObjects = defaultNumberOfObjects
		self:buildObjectPool()
	return self
end

function EffectEmitterObjectPool:createNewObject()
	local object = EffectEmitter.new()
	table.insert(self.objectPool, object)
end

function EffectEmitterObjectPool:buildObjectPool()
	self.objectPool = {}
	for i=1, self.defaultNumberOfObjects do
		self:createNewObject()
	end
end

function EffectEmitterObjectPool:getCurrentAvailableObject()
	return self.objectPool[self.currentIndex]
end

function EffectEmitterObjectPool:getLength()
	return self.currentIndex - 1
end

function EffectEmitterObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function EffectEmitterObjectPool:incrementCurrentIndex()
	if self.currentIndex == #self.objectPool then
		if self.resizable then 
			self:createNewObject()
		end
	end
	self.currentIndex = self.currentIndex + 1
end

function EffectEmitterObjectPool:resetObjectPoolSize()
	for i=#self.objectPool, self.defaultNumberOfObjects, -1 do
		table.remove(self.objectPool)
	end
end

function EffectEmitterObjectPool:setResizableState(resizable)
	self.resizable = resizable
end

--------------------
--Visual Effect object:
--------------------

VisualEffect = {}
VisualEffect.__index = VisualEffect

setmetatable(VisualEffect, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function VisualEffect.new ()
	local self = setmetatable ({}, VisualEffect)
		self.active = false
		self.controller = nil
		self.parentEmitter = nil
		
		self.components = {
			state = nil,
			scene = nil,
			spatial = nil,
			sprite = nil,
			target = nil
		}
		
	return self
end

------------------------
--Visual Effect factory:
------------------------

VisualEffectFactory = {}
VisualEffectFactory.__index = VisualEffectFactory

setmetatable(VisualEffectFactory, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function VisualEffectFactory.new ()
	local self = setmetatable ({}, VisualEffectFactory)
		self.VISUAL_EFFECT_COMPONENTS = require '/effect/VISUAL_EFFECT_COMPONENT'
		self.ENTITY_ROLE = require '/entity/ENTITY_ROLE'
		self.EFFECT_TYPE = require '/effect/EFFECT_TYPE'
		
		self.createComponentMethods = nil
		self:setCreateComponentMethods()
	return self
end

function VisualEffectFactory:createVisualEffect()
	local visualEffect = VisualEffect.new()
	visualEffect.components.state = self:createComponent(visualEffect, self.VISUAL_EFFECT_COMPONENTS.STATE)
	visualEffect.components.scene = self:createComponent(visualEffect, self.VISUAL_EFFECT_COMPONENTS.SCENE)
	visualEffect.components.spatial = self:createComponent(visualEffect, self.VISUAL_EFFECT_COMPONENTS.SPATIAL)
	visualEffect.components.sprite = self:createComponent(visualEffect, self.VISUAL_EFFECT_COMPONENTS.SPRITE)
	return visualEffect
end

function VisualEffectFactory:createComponent(VisualEffect, componentType)
	return self.createComponentMethods[componentType](VisualEffect)
end

function VisualEffectFactory:setCreateComponentMethods()
	self.createComponentMethods = {
		
		[self.VISUAL_EFFECT_COMPONENTS.STATE] = function(visualEffect)	
			return {
				self = visualEffect,
				effectType = 0,
				totalTime = 1,
				currentTime = 0,
				updatePoint = 0,
				currentMethodIndex = 1,
				currentControlMethod = 1,
				methodArguments = nil,
				animation = false,
				animationCurrentTime = 0,
				animationUpdatePoint = 0,
				animationCurrentIndex = 0
			}
		end,
		
		[self.VISUAL_EFFECT_COMPONENTS.SCENE] = function(visualEffect)	
			return {
				--remove this!
				self = visualEffect,
				role = self.ENTITY_ROLE.VISUAL_EFFECT
			}
		end,
		
		[self.VISUAL_EFFECT_COMPONENTS.SPATIAL] = function(visualEffect)	
			return {
				self = visualEffect,
				x = 0,
				y = 0,
				w = 0,
				h = 0,
				velocity = 0,
				direction = 0,
			}
		end,
		
		[self.VISUAL_EFFECT_COMPONENTS.SPRITE] = function(visualEffect)	
			return {
				self = visualEffect,
				spritesheetId = 0,
				spritesheetQuad = 0,
				spriteOffsetX = 0,
				spriteOffsetY = 0,
				defaultQuad = 0,
				rotation = 0
			}
		end
	}
end

----------------------------
--Visual Effect object pool:
----------------------------

VisualEffectObjectPool = {}
VisualEffectObjectPool.__index = VisualEffectObjectPool

setmetatable(VisualEffectObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function VisualEffectObjectPool.new (defaultNumberOfObjects)
	local self = setmetatable ({}, VisualEffectObjectPool)
		self.visualEffectFactory = VisualEffectFactory.new()
		
		self.objectPool = {}
		self.currentIndex = 1
		self.resizable = false
		
		self.defaultNumberOfObjects = defaultNumberOfObjects
		self:buildObjectPool()
	return self
end

function VisualEffectObjectPool:createNewObject()
	local object = self.visualEffectFactory:createVisualEffect()
	table.insert(self.objectPool, object)
end

function VisualEffectObjectPool:buildObjectPool()
	self.objectPool = {}
	for i=1, self.defaultNumberOfObjects do
		self:createNewObject()
	end
end

function VisualEffectObjectPool:getCurrentAvailableObject()
	return self.objectPool[self.currentIndex]
end

function VisualEffectObjectPool:getLength()
	return self.currentIndex - 1
end

function VisualEffectObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function VisualEffectObjectPool:incrementCurrentIndex()
	if self.currentIndex == #self.objectPool then
		if self.resizable then 
			self:createNewObject()
		end
	end
	self.currentIndex = self.currentIndex + 1
end

function VisualEffectObjectPool:resetObjectPoolSize()
	for i=#self.objectPool, self.defaultNumberOfObjects, -1 do
		table.remove(self.objectPool)
	end
end

function VisualEffectObjectPool:setResizableState(resizable)
	self.resizable = resizable
end

---------------------------
--Visual Effect Controller:
---------------------------

VisualEffectController = {}
VisualEffectController.__index = VisualEffectController

setmetatable(VisualEffectController, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function VisualEffectController.new (controllerType, totalTime, loop, animation, animationTotalTime,
	animationLoop)
	local self = setmetatable ({}, VisualEffectController)
		self.controllerType = controllerType
		self.totalTime = totalTime
		self.loop = loop
		self.animation = animation
		self.animationTotalTime = animationTotalTime
		self.animationLoop = animationLoop
		self.methodMap = {}
		self.animationMap = {}
		self.sortControllerMethod = function(a, b) return a.stopTime < b.stopTime end
		self.sortAnimationMethod = function(a, b) return a.updateTime < b.updateTime end
	return self
end

function VisualEffectController:setMethodMap(methods)
	for i=1, #methods do
		table.insert(self.methodMap, VisualEffectControlMethod.new(methods[i].methodId, methods[i].stopTime,
			methods[i].arguments))
	end
	
	table.sort(self.methodMap, self.sortControllerMethod)
end

function VisualEffectController:setAnimationMap(animationList)
	for i=1, #animationList do
		table.insert(self.animationMap, VisualEffectAnimationObject.new(animationList[i].updateTime, 
			animationList[i].quad, animationList[i].soundId))
	end
	
	table.sort(self.animationMap, self.sortAnimationMethod)
end

VisualEffectControlMethod = {}
VisualEffectControlMethod.__index = VisualEffectControlMethod

setmetatable(VisualEffectControlMethod, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function VisualEffectControlMethod.new (methodId, stopTime, arguments)
	local self = setmetatable ({}, VisualEffectControlMethod)
		self.methodId = methodId
		self.stopTime = stopTime
		self.arguments = arguments
	return self
end

VisualEffectAnimationObject = {}
VisualEffectAnimationObject.__index = VisualEffectAnimationObject

setmetatable(VisualEffectAnimationObject, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function VisualEffectAnimationObject.new (updateTime, quad, soundId)
	local self = setmetatable ({}, VisualEffectAnimationObject)
		self.updateTime = updateTime
		self.quad = quad
		self.soundId = soundId
	return self
end