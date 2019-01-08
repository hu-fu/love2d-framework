require 'misc'

--------------------
--Projectile object:
--------------------

Projectile = {}
Projectile.__index = Projectile

setmetatable(Projectile, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function Projectile.new ()
	local self = setmetatable ({}, Projectile)
		self.active = false
		self.animation = nil
		self.controller = nil
		self.destructor = nil
		
		self.components = {
			state = nil,
			scene = nil,
			spatial = nil,
			sprite = nil,
			target = nil,
			destruction = nil,
		}
		
	return self
end

---------------------
--Projectile factory:
---------------------

ProjectileFactory = {}
ProjectileFactory.__index = ProjectileFactory

setmetatable(ProjectileFactory, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function ProjectileFactory.new ()
	local self = setmetatable ({}, ProjectileFactory)
		self.PROJECTILE_COMPONENTS = require '/projectile/PROJECTILE_COMPONENT'
		
		self.createComponentMethods = nil
		self:setCreateComponentMethods()
	return self
end

function ProjectileFactory:createProjectile()
	local projectile = Projectile.new()
	projectile.components.state = self:createComponent(projectile, self.PROJECTILE_COMPONENTS.STATE)
	projectile.components.scene = self:createComponent(projectile, self.PROJECTILE_COMPONENTS.SCENE)
	projectile.components.spatial = self:createComponent(projectile, self.PROJECTILE_COMPONENTS.SPATIAL)
	projectile.components.sprite = self:createComponent(projectile, self.PROJECTILE_COMPONENTS.SPRITE)
	projectile.components.target = self:createComponent(projectile, self.PROJECTILE_COMPONENTS.TARGET)
	projectile.components.destruction = self:createComponent(projectile, self.PROJECTILE_COMPONENTS.DESTRUCTION)
	return projectile
end

function ProjectileFactory:createComponent(projectile, componentType)
	return self.createComponentMethods[componentType](projectile)
end

function ProjectileFactory:setCreateComponentMethods()
	self.createComponentMethods = {
		
		[self.PROJECTILE_COMPONENTS.STATE] = function(projectile)	
			return {
				self = projectile,
				projectileType = 0,
				globalState = 1,
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
		
		[self.PROJECTILE_COMPONENTS.SCENE] = function(projectile)	
			return {
				self = projectile,
				role = nil
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.SPATIAL] = function(projectile)	
			return {
				self = projectile,
				x = 0,
				y = 0,
				w = 0,
				h = 0,
				velocity = 0,
				direction = 0,
				spatialEntity = nil
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.SPRITE] = function(projectile)	
			return {
				self = projectile,
				spritesheetId = 0,
				spritesheetQuad = 0,
				spriteOffsetX = 0,
				spriteOffsetY = 0,
				defaultQuad = 0,
				rotation = 0,
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.TARGET] = function(projectile)	
			return {
				self = projectile,
				senderType = nil,
				senderRef = nil,
				targetType = nil,
				targetRef = nil
				--...
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.DESTRUCTION] = function(projectile)
			return {
				self = projectile,
				damage = 0,
				--...
			}
		end,
	}
end

-------------------------
--Projectile object pool:
-------------------------

ProjectileObjectPool = {}
ProjectileObjectPool.__index = ProjectileObjectPool

setmetatable(ProjectileObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function ProjectileObjectPool.new (defaultNumberOfObjects)
	local self = setmetatable ({}, ProjectileObjectPool)
		self.projectileFactory = ProjectileFactory.new()
		
		self.objectPool = {}
		self.currentIndex = 1
		self.resizable = false
		
		self.defaultNumberOfObjects = defaultNumberOfObjects
		self:buildObjectPool()
	return self
end

function ProjectileObjectPool:createNewObject()
	local object = self.projectileFactory:createProjectile()
	table.insert(self.objectPool, object)
end

function ProjectileObjectPool:buildObjectPool()
	self.objectPool = {}
	for i=1, self.defaultNumberOfObjects do
		self:createNewObject()
	end
end

function ProjectileObjectPool:getCurrentAvailableObject()
	return self.objectPool[self.currentIndex]
end

function ProjectileObjectPool:getLength()
	return self.currentIndex - 1
end

function ProjectileObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function ProjectileObjectPool:incrementCurrentIndex()
	if self.currentIndex == #self.objectPool then
		if self.resizable then 
			self:createNewObject()
		end
	end
	self.currentIndex = self.currentIndex + 1
end

function ProjectileObjectPool:resetObjectPoolSize()
	for i=#self.objectPool, self.defaultNumberOfObjects, -1 do
		table.remove(self.objectPool)
	end
end

function ProjectileObjectPool:setResizableState(resizable)
	self.resizable = resizable
end

-------------------
--Projectile spawn:
-------------------

ProjectileSpawn = {}
ProjectileSpawn.__index = ProjectileSpawn

setmetatable(ProjectileSpawn, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function ProjectileSpawn.new (spawnType)
	local self = setmetatable ({}, ProjectileSpawn)
		
		self.type = spawnType
		self.spawnObjects = {}
	return self
end

function ProjectileSpawn:createSpawnObjects(template)
	for i=1, #template do
		local spawnObject = ProjectileSpawnObject.new(template[i])
		table.insert(self.spawnObjects, spawnObject)
	end
end

ProjectileSpawnObject = {}
ProjectileSpawnObject.__index = ProjectileSpawnObject

setmetatable(ProjectileSpawnObject, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function ProjectileSpawnObject.new (template)
	local self = setmetatable ({}, ProjectileSpawnObject)
		self.projectileTemplate = template.projectileTemplate
		self.roleGroup = template.roleGroup
		self.xOffset = template.xOffset
		self.yOffset = template.yOffset
		self.velocityModifier = template.velocityModifier
		self.getDirection = template.getDirection
	return self
end

------------------------
--Projectile Controller:
------------------------

ProjectileController = {}
ProjectileController.__index = ProjectileController

setmetatable(ProjectileController, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function ProjectileController.new (controllerType, totalTime, animation, animationTotalTime, animationLoop)
	local self = setmetatable ({}, ProjectileController)
		self.controllerType = controllerType
		self.totalTime = totalTime
		self.animation = animation
		self.animationTotalTime = animationTotalTime
		self.animationLoop = animationLoop
		self.methodMap = {}
		self.animationMap = {}
		self.sortControllerMethod = function(a, b) return a.stopTime < b.stopTime end
		self.sortAnimationMethod = function(a, b) return a.updateTime < b.updateTime end
	return self
end

function ProjectileController:setMethodMap(methods)
	for i=1, #methods do
		table.insert(self.methodMap, ProjectileControlMethod.new(methods[i].methodId, methods[i].stopTime,
			methods[i].arguments))
	end
	
	table.sort(self.methodMap, self.sortControllerMethod)
end

function ProjectileController:setAnimationMap(animationList)
	for i=1, #animationList do
		table.insert(self.animationMap, ProjectileAnimationObject.new(animationList[i].updateTime, 
			animationList[i].quad))
	end
	
	table.sort(self.animationMap, self.sortAnimationMethod)
end

ProjectileControlMethod = {}
ProjectileControlMethod.__index = ProjectileControlMethod

setmetatable(ProjectileControlMethod, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function ProjectileControlMethod.new (methodId, stopTime, arguments)
	local self = setmetatable ({}, ProjectileControlMethod)
		self.methodId = methodId
		self.stopTime = stopTime
		self.arguments = arguments
	return self
end

-----------------------
--Projectile animation:
-----------------------

ProjectileAnimationObject = {}
ProjectileAnimationObject.__index = ProjectileAnimationObject

setmetatable(ProjectileAnimationObject, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function ProjectileAnimationObject.new (updateTime, quad, soundId)
	local self = setmetatable ({}, ProjectileAnimationObject)
		self.updateTime = updateTime
		self.quad = quad
	return self
end

------------------------
--Projectile destructor:
------------------------

ProjectileDestructor = {}
ProjectileDestructor.__index = ProjectileDestructor

setmetatable(ProjectileDestructor, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function ProjectileDestructor.new (destructorType, destructorMethods)
	local self = setmetatable ({}, ProjectileDestructor)
		self.destructorType = destructorType
		self.methods = destructorMethods	--ref from template
	return self
end