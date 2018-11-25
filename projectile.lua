require 'misc'

---------------------
--Projectile factory:
---------------------

projectileFactory = {}
projectileFactory.__index = projectileFactory

setmetatable(projectileFactory, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function projectileFactory.new ()
	local self = setmetatable ({}, projectileFactory)
		self.PROJECTILE_COMPONENTS = require 'PROJECTILE_COMPONENT'
		
		self.createComponentMethods = nil
		self:setCreateComponentMethods()
	return self
end

function projectileFactory:createProjectiles(n)
	local projectiles = {}
	
	for i=1, n do
		table.insert(projectiles, projectile.new())
	end
	
	for i=1, #projectiles do
		projectiles[i].components.main = self:createComponent(projectiles[i], self.PROJECTILE_COMPONENTS.MAIN)
	end
	
	for i=1, #projectiles do
		projectiles[i].components.state = self:createComponent(projectiles[i], self.PROJECTILE_COMPONENTS.STATE)
	end
	
	for i=1, #projectiles do
		projectiles[i].components.scene = self:createComponent(projectiles[i], self.PROJECTILE_COMPONENTS.SCENE)
	end
	
	for i=1, #projectiles do
		projectiles[i].components.spatial = self:createComponent(projectiles[i], self.PROJECTILE_COMPONENTS.SPATIAL)
	end
	
	for i=1, #projectiles do
		projectiles[i].components.sprite = self:createComponent(projectiles[i], self.PROJECTILE_COMPONENTS.SPRITE)
	end
	
	for i=1, #projectiles do
		projectiles[i].components.target = self:createComponent(projectiles[i], self.PROJECTILE_COMPONENTS.TARGET)
	end
	
	for i=1, #projectiles do
		projectiles[i].components.animation = self:createComponent(projectiles[i], self.PROJECTILE_COMPONENTS.ANIMATION)
	end
	
	for i=1, #projectiles do
		projectiles[i].components.controller = self:createComponent(projectiles[i], self.PROJECTILE_COMPONENTS.CONTROLLER)
	end
	
	for i=1, #projectiles do
		projectiles[i].components.destructor = self:createComponent(projectiles[i], self.PROJECTILE_COMPONENTS.DESTRUCTOR)
	end
	
	return projectiles
end

function projectileFactory:createComponent(projectile, componentType)
	return self.createComponentMethods[componentType](projectile)
end

function projectileFactory:setCreateComponentMethods()
	self.createComponentMethods = {
		
		[self.PROJECTILE_COMPONENTS.MAIN] = function(projectile)	
			return {
				componentTable = projectile.components,
				active = false
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.STATE] = function(projectile)	
			return {
				componentTable = projectile.components,
				projectileType = 1,
				globalState = 1,
				updateIndex = 1,
				t = 0
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.SCENE] = function(projectile)	
			return {
				componentTable = projectile.components,
				role = nil
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.SPATIAL] = function(projectile)	
			return {
				componentTable = projectile.components,
				x = 0,
				y = 0,
				w = 0,
				h = 0,
				velocity = 0,
				direction = 0
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.SPRITE] = function(projectile)	
			return {
				componentTable = projectile.components,
				spritesheetId = 0,
				spritesheetQuad = 0,
				spriteOffsetX = 0,
				spriteOffsetY = 0
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.TARGET] = function(projectile)	
			return {
				componentTable = projectile.components,
				targetType = nil,
				targetRef = nil
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.ANIMATION] = function(projectile)	
			return {
				componentTable = projectile.components,
				animation = nil
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.CONTROLLER] = function(projectile)	
			return {
				componentTable = projectile.components,
				controller = nil
			}
		end,
		
		[self.PROJECTILE_COMPONENTS.DESTRUCTOR] = function(projectile)	
			return {
				componentTable = projectile.components,
				destructorType = nil
			}
		end
	}
end

--------------------
--Projectile object:
--------------------

projectile = {}
projectile.__index = projectile

setmetatable(projectile, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function projectile.new ()
	local self = setmetatable ({}, projectile)
		
		self.components = {
			main = nil,
			state = nil,
			spatial = nil,
			sprite = nil,
			target = nil,
			animation = nil,
			controller = nil,
			destructor = nil
		}
		
	return self
end

-------------------
--Projectile spawn:
-------------------

projectileSpawn = {}
projectileSpawn.__index = projectileSpawn

setmetatable(projectileSpawn, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function projectileSpawn.new (id)
	local self = setmetatable ({}, projectileSpawn)
		
		self.id = id
		self.spawnMap = {}
	return self
end

-----------------------
--Projectile animation:
-----------------------
--Animation routine for projectiles; do this later

projectileAnimation = {}
projectileAnimation.__index = projectileAnimation

setmetatable(projectileAnimation, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function projectileAnimation.new (id)
	local self = setmetatable ({}, projectileAnimation)
		
		self.id = id
		
	return self
end

------------------------
--Projectile controller:
------------------------

projectileController = {}
projectileController.__index = projectileController

setmetatable(projectileController, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function projectileController.new (id)
	local self = setmetatable ({}, projectileController)
		
		self.id = id
		
		self.startControlMethod = nil			--linked list first element
		self.controlMethods = {}				--hash table
		
		self.startDestructionMethod = nil
		self.destructionMethods = {}			--hash table
	return self
end

function projectileController:createControlMethods(methodMap)
	--method maps in the PROJECTILE_CONTROLLER file
	
	local previousMethodObj = nil
	local currentMethodObj = nil
	
	for controlState, updateIndexes in sortedPairs(methodMap) do
		for updateTime, method in sortedPairs(updateIndexes) do
			currentMethodObj = projectileControlMethod.new(controlState, updateTime)
			currentMethodObj.method = method
			
			if previousMethodObj == nil then 
				self.startControlMethod = currentMethodObj
			else
				previousMethodObj.nextMethod = currentMethodObj
			end
			
			self:indexControlMethod(currentMethodObj)
			previousMethodObj = currentMethodObj
		end
	end
end

function projectileController:indexControlMethod(controlMethod)
	if self.controlMethods[controlMethod.controlState] == nil then
		self.controlMethods[controlMethod.controlState] = {}
	end
	self.controlMethods[controlMethod.controlState][controlMethod.updateTime] = controlMethod
end

function projectileController:getNextControllerMethod(state, updateTime)
	local controlMethod = self.controlMethods[state][updateTime]
	if controlMethod ~= nil and controlMethod.nextMethod ~= nil then
		return controlMethod.nextMethod
	end
	return nil
end

function projectileController:createDestructionMethods(methodMap)
	--method maps in the PROJECTILE_DESTRUCTOR file
	
	for destructorType, updateIndexes in sortedPairs(methodMap) do
		for updateTime, method in sortedPairs(updateIndexes) do
			currentMethodObj = projectileDestructionMethod.new(destructorType, updateTime)
			currentMethodObj.method = method
			
			if previousMethodObj == nil then
				self.startDestructionMethod = currentMethodObj
			else
				previousMethodObj.nextMethod = currentMethodObj
			end
			
			self:indexDestructionMethod(destructorType, currentMethodObj)
			previousMethodObj = currentMethodObj
		end
	end
end

function projectileController:indexDestructionMethod(destructorType, destructionMethod)
	if self.destructionMethods[destructionMethod.destructorType] == nil then
		self.destructionMethods[destructionMethod.destructorType] = {}
	end
	self.destructionMethods[destructionMethod.destructorType][destructionMethod.updateTime] = destructionMethod
end

function projectileController:getNextDestructionMethod(destructorType, updateTime)
	local destructionMethod = self.destructionMethods[destructorType][updateTime]
	if destructionMethod ~= nil and destructionMethod.nextMethod ~= nil then
		return destructionMethod.nextMethod
	end
	return nil
end

projectileControlMethod = {}
projectileControlMethod.__index = projectileControlMethod

setmetatable(projectileControlMethod, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function projectileControlMethod.new (controlState, updateTime)
	local self = setmetatable ({}, projectileControlMethod)
		
		self.controlState = controlState
		self.updateTime = updateTime
		self.method = nil
		
		self.nextMethod = nil
	return self
end

projectileDestructionMethod = {}
projectileDestructionMethod.__index = projectileDestructionMethod

setmetatable(projectileDestructionMethod, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function projectileDestructionMethod.new (destructorType, updateTime)
	local self = setmetatable ({}, projectileDestructionMethod)
		
		self.destructorType = destructorType
		self.updateTime = updateTime
		self.method = nil
		
		self.nextMethod = nil
	return self
end