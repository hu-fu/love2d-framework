--------------------
--Projectile System:
--------------------

--[[
	needs a lot of optimization, runs like shit
	the update loop itself runs slow (cache misses up the ass I think, or maybe not who knows?)
	update projectiles at >1 frame intervals - good idea, VERY good idea - this will work
	projectile updates and spatial queries shouldn't be done in the same frame
	subdivide the projectile updates by frame intervals
	projectile object is too large - subdividing is a good idea - DIDN'T WORK, but it's better this way I think
	anonymous function calls in update projectile method are expensive - irrelevant
	sin/cos calculations are expensive - irrelevant
]]

local projectileSystem = {}

---------------
--Dependencies:
---------------

require 'projectile'

-------------------
--Static Variables:
-------------------

-------------------
--System Variables:
-------------------

projectileSystem.projectileObjectTable = {}			--{projectile, ...}
projectileSystem.projectileTable = {}				--{projectile.main component, ...}
projectileSystem.currentProjectileIndex = 1

projectileSystem.projectileFactory = projectileFactory.new()
projectileSystem.projectileStateManager = require 'projectileState'
projectileSystem.PROJECTILE_TYPE = require 'PROJECTILE_TYPE'
projectileSystem.PROJECTILE_CONTROLLER = require 'PROJECTILE_CONTROLLER'
projectileSystem.PROJECTILE_DESTRUCTOR = require 'PROJECTILE_DESTRUCTOR'
projectileSystem.PROJECTILE_SPAWN = require 'PROJECTILE_SPAWN'

projectileSystem.projectileTemplateTable = {}		--[id] = template obj
projectileSystem.spawnTable = {}					--[id] = spawn obj
projectileSystem.controllerTable = {}				--[id] = cont obj
projectileSystem.animationTable = {}				--[id] = anim obj

----------------
--Event Methods:
----------------

projectileSystem.eventMethods = {

	[1] = {
		[1] = function(projectileSystemRequest)
			--projectile spawn init request
			
		end,
		
		[2] = function(projectileSystemRequest)
			--projectile destruction request
			
		end
	}
}

---------------
--Init Methods:
---------------

function projectileSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function projectileSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function projectileSystem:createProjectileTable(maxProjectiles)
	self.projectileObjectTable = {}
	self.projectileTable = {}
	
	local projectiles = self.projectileFactory:createProjectiles(maxProjectiles)
	
	self.projectileObjectTable = projectiles
	
	for i=1, #projectiles do
		table.insert(self.projectileTable, projectiles[i].components.main)
	end
end

function projectileSystem:createProjectileTemplateTable()
	self.projectileTemplateTable = {}
	self.projectileTemplateTable = self.PROJECTILE_TYPE.TEMPLATES
end

function projectileSystem:createSpawnTable()
	self.spawnTable = {}
	
	for spawnType, template in pairs(self.PROJECTILE_SPAWN.TEMPLATES) do
		self.spawnTable[spawnType] = self:buildProjectileSpawn(spawnType, template)
	end
end

function projectileSystem:createControllerTable()
	self.controllerTable = {}
	
	for controllerType, controllerTemplate in pairs(self.PROJECTILE_CONTROLLER.TEMPLATES) do
		local destructionTemplate = self.PROJECTILE_DESTRUCTOR.TEMPLATES[controllerType]
		self.controllerTable[controllerType] = self:buildProjectileController(id, controllerTemplate, 
			destructionTemplate)
	end
end

function projectileSystem:createAnimationTable()
	self.animationTable = {}
	--do later
end

---------------
--Exec Methods:
---------------

function projectileSystem:main(dt)
	--loop all? -> for now; get all actives with a spatial query?
	
	for i=1, #self.projectileTable do
		if self.projectileTable[i].active then
			self:updateProjectile(self.projectileTable[i].componentTable, dt)
		end
	end
end

function projectileSystem:getNextAvailableProjectile()
	for i=1, #self.projectileTable do
		local index = ((i + self.currentProjectileIndex) % #self.projectileTable) + 1
		if not self.projectileTable[index].active then
			self.currentProjectileIndex = index
			return self.projectileTable[index]
		end
	end
	return nil
end

function projectileSystem:initProjectile(role, x, y, direction, targetType, targetRef, template, 
	projectileComponents)
	
	projectileComponents.main.active = true
	projectileComponents.state.globalState = 1
	projectileComponents.spatial.t = 0
	projectileComponents.scene.role = role
	projectileComponents.spatial.x = x
	projectileComponents.spatial.y = y
	projectileComponents.spatial.direction = direction
	projectileComponents.target.targetType = targetType
	projectileComponents.target.targetRef = targetRef
	
	if projectileComponents.state.projectileType ~= template.type then
		projectileComponents.state.projectileType = template.type
		projectileComponents.spatial.w = template.w
		projectileComponents.spatial.h = template.h
		projectileComponents.spatial.velocity = template.velocity
		projectileComponents.sprite.spritesheetId = template.spritesheetId
		projectileComponents.sprite.spritesheetQuad = template.spritesheetQuad
		projectileComponents.sprite.spriteOffsetX = template.spriteOffsetX
		projectileComponents.sprite.spriteOffsetY = template.spriteOffsetY
		projectileComponents.controller.controller = self.controllerTable[template.controller]
		projectileComponents.destructor.destructorType = template.destructorType
		projectileComponents.state.updateIndex = projectileComponents.controller.controller.startControlMethod.updateTime
		projectileComponents.animation.animation = template.animation
	end
	
	--other stuff, like requests for the spatial system
end

function projectileSystem:buildProjectileController(id, controllerTemplate, destructorTemplate)
	local controller = projectileController.new(id)
	controller:createControlMethods(controllerTemplate)
	controller:createDestructionMethods(destructorTemplate)
	return controller
end

function projectileSystem:buildProjectileSpawn(id, template)
	local spawn = projectileSpawn.new (id)
	
	for i=1, #template do
		table.insert(spawn.spawnMap, template[i])
	end
	
	return spawn
end

function projectileSystem:buildProjectileAnimation()
	--do later
end

function projectileSystem:activateSpawn(spawnType, role, x, y, direction, targetEntity, targetEntityType)
	local spawn = self.spawnTable[spawnType]
	for i=1, #spawn.spawnMap do
		local currentProjectile = self:getNextAvailableProjectile()
		if currentProjectile ~= nil then
			self:initProjectile(role, spawn.spawnMap[i].xOffset + x, spawn.spawnMap[i].yOffset + y, 
				spawn.spawnMap[i].getDirection(direction), targetEntityType, targetEntity, 
				self.projectileTemplateTable[spawn.spawnMap[i].projectileTemplate], currentProjectile.componentTable)
		end
	end
end

function projectileSystem:updateProjectile(projectileComponents, dt)
	projectileComponents.state.t = projectileComponents.state.t + dt
	self.projectileUpdateMethods[projectileComponents.state.globalState](projectileComponents)
end

projectileSystem.projectileUpdateMethods = {
	[projectileSystem.projectileStateManager.states.SPAWN] = function(projectileComponents)
		if projectileComponents.state.t >= projectileComponents.state.updateIndex then
			local nextMethod = projectileComponents.controller.controller:getNextControllerMethod(projectileComponents.state.globalState, 
				projectileComponents.state.updateIndex)
			
			if projectileComponents.state.globalState ~= nextMethod.controlState then
				--end of state, do stuff
				
				projectileComponents.state.globalState = projectileSystem.projectileStateManager:getNextState(projectileComponents.state.globalState)
				projectileComponents.state.updateIndex = nextMethod.updateTime
				projectileComponents.state.t = 0
				return 0
			else
				projectileComponents.state.updateIndex = nextMethod.updateTime
			end
		end
		
		projectileComponents.controller.controller.controlMethods[projectileComponents.state.globalState][projectileComponents.state.updateIndex].method(projectileComponents)
	end,
	
	[projectileSystem.projectileStateManager.states.ACTIVE] = function(projectileComponents)
		if projectileComponents.state.t >= projectileComponents.state.updateIndex then
			local nextMethod = projectileComponents.controller.controller:getNextControllerMethod(projectileComponents.state.globalState, 
				projectileComponents.state.updateIndex)
			
			if nextMethod ~= nil then
				projectileComponents.state.updateIndex = nextMethod.updateTime
			else
				--end of state
				projectileComponents.state.globalState = projectileSystem.projectileStateManager:getNextState(projectileComponents.state.globalState)
				projectileComponents.destructor.destructorType = projectileSystem.PROJECTILE_DESTRUCTOR.TYPES.GENERIC
				projectileComponents.state.updateIndex = projectileComponents.controller.controller.startDestructionMethod.updateTime
				projectileComponents.state.t = 0
				return 0
			end
		end
		
		projectileComponents.controller.controller.controlMethods[projectileComponents.state.globalState][projectileComponents.state.updateIndex].method(projectileComponents)
	end,
	
	[projectileSystem.projectileStateManager.states.DESTROY] = function(projectileComponents)
		if projectileComponents.state.t >= projectileComponents.state.updateIndex then
			local nextMethod = projectileComponents.controller.controller:getNextDestructionMethod(projectileComponents.destructor.destructorType, 
				projectileComponents.state.updateIndex)
			
			if nextMethod ~= nil then
				projectileComponents.state.updateIndex = nextMethod.updateTime
			else
				--end of object life
				projectileComponents.main.active = false
				return nil
			end
		end
		
		projectileComponents.controller.controller.destructionMethods[projectileComponents.destructor.destructorType][projectileComponents.state.updateIndex].method(projectileComponents)
	end
}

function projectileSystem:destroyProjectile()
	
end

----------------
--Return Module:
----------------

return projectileSystem