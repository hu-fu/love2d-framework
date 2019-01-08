--------------------
--Projectile System:
--------------------

local ProjectileSystem = {}

---------------
--Dependencies:
---------------

require '/projectile/Projectile'
local SYSTEM_ID = require '/system/SYSTEM_ID'
ProjectileSystem.EVENT_TYPE = require '/event/EVENT_TYPE'
ProjectileSystem.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
ProjectileSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
ProjectileSystem.ENTITY_ROLE = require '/entity/ENTITY_ROLE'
ProjectileSystem.ENTITY_ROLE_GROUP = require '/entity/ENTITY_ROLE_GROUP'
ProjectileSystem.ENTITY_ROLE_TRANSFORM = require '/entity/ENTITY_ROLE_TRANSFORM'
ProjectileSystem.PROJECTILE_TYPE = require '/projectile/PROJECTILE_TYPE'
ProjectileSystem.PROJECTILE_TEMPLATE_TYPE = require '/projectile/PROJECTILE_TEMPLATE_TYPE'
ProjectileSystem.PROJECTILE_SPAWN_TYPE = require '/projectile/PROJECTILE_SPAWN_TYPE'
ProjectileSystem.PROJECTILE_CONTROLLER_TYPE = require '/projectile/PROJECTILE_CONTROLLER_TYPE'
ProjectileSystem.PROJECTILE_DESTRUCTOR_TYPE = require '/projectile/PROJECTILE_DESTRUCTOR_TYPE'
ProjectileSystem.PROJECTILE_DESTRUCTION_TYPE = require '/projectile/PROJECTILE_DESTRUCTION_TYPE'
ProjectileSystem.PROJECTILE_REQUEST = require '/projectile/PROJECTILE_REQUEST'

ProjectileSystem.controlMethods = require '/projectile/ProjectileControlMethods'

-------------------
--System Variables:
-------------------

ProjectileSystem.id = SYSTEM_ID.PROJECTILE

ProjectileSystem.projectileObjectPool = ProjectileObjectPool.new(500)

ProjectileSystem.projectileTemplateTable = {}		--[id] = template obj
ProjectileSystem.spawnTable = {}					--[id] = spawn obj
ProjectileSystem.controllerTable = {}				--[id] = cont obj
ProjectileSystem.destructorTable = {}				--[id] = anim obj
ProjectileSystem.animationTable = {}				--[id] = anim obj

ProjectileSystem.requestStack = {}

ProjectileSystem.initEntityRequestPool = EventObjectPool.new(ProjectileSystem.EVENT_TYPE.INIT_ENTITY, 2)
ProjectileSystem.healthRequestPool = EventObjectPool.new(ProjectileSystem.EVENT_TYPE.ENTITY_HEALTH, 25)

function ProjectileSystem:spatialQueryDefaultCallbackMethod() return function () end end
ProjectileSystem.spatialSystemRequestPool = EventObjectPool.new(ProjectileSystem.EVENT_TYPE.SPATIAL_REQUEST, 100)
ProjectileSystem.registerProjectileSpatialQueryPool = SpatialQueryPool.new(100, ProjectileSystem.QUERY_TYPES.REINDEX_ENTITY, 
	SpatialQueryBuilder.new(), ProjectileSystem:spatialQueryDefaultCallbackMethod())
ProjectileSystem.unregisterProjectileSpatialQueryPool = SpatialQueryPool.new(100, ProjectileSystem.QUERY_TYPES.UNREGISTER_ENTITY, 
	SpatialQueryBuilder.new(), ProjectileSystem:spatialQueryDefaultCallbackMethod())

ProjectileSystem.eventDispatcher = nil
ProjectileSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

ProjectileSystem.eventMethods = {

	[1] = {
		[1] = function(request)
			--add request to stack
			ProjectileSystem:addRequestToStack(request)
		end,
		
	}
}

---------------
--Init Methods:
---------------

function ProjectileSystem:createProjectileObjectPool(maxProjectiles)
	self.projectileObjectPool:buildObjectPool(maxProjectiles)
end

function ProjectileSystem:createProjectileTemplateTable()
	self.projectileTemplateTable = {}
	
	local templates = require '/projectile/PROJECTILE_TEMPLATE'
	self.projectileTemplateTable = templates
end

function ProjectileSystem:createSpawnTable()
	self.spawnTable = {}
	
	local templates = require '/projectile/PROJECTILE_SPAWN'
	for spawnType, spawnObjects in pairs(templates) do
		local spawn = ProjectileSpawn.new(spawnType)
		spawn:createSpawnObjects(spawnObjects)
		self.spawnTable[spawnType] = spawn
	end
end

function ProjectileSystem:createControllerTable()
	self.controllerTable = {}
	
	local templates = require '/projectile/PROJECTILE_CONTROLLER'
	
	for controllerType, controllerTemplate in pairs(templates) do
		local controller = ProjectileController.new(controllerType, controllerTemplate.totalTime,
			controllerTemplate.animation, controllerTemplate.animationTotalTime, controllerTemplate.animationLoop)
		controller:setMethodMap(controllerTemplate.methods)
		controller:setAnimationMap(controllerTemplate.animationUpdate)
		self.controllerTable[controllerType] = controller
	end
end

function ProjectileSystem:createDestructorTable()
	self.destructorTable = {}
	
	local templates = require '/projectile/PROJECTILE_DESTRUCTOR'
	for destructorType, destructorTemplate in pairs(templates) do
		self.destructorTable[destructorType] = ProjectileDestructor.new(destructorType, 
			destructorTemplate)
	end
end

function ProjectileSystem:createAnimationTable()
	self.animationTable = {}
	
	--do later - fuck
end

ProjectileSystem.projectileObjectPool.getCurrentAvailableObject = function()
	for i=1, #ProjectileSystem.projectileObjectPool.objectPool do
		local index = ((i + ProjectileSystem.projectileObjectPool.currentIndex) % 
			#ProjectileSystem.projectileObjectPool.objectPool) + 1
		if not ProjectileSystem.projectileObjectPool.objectPool[index].active then
			ProjectileSystem.projectileObjectPool.currentIndex = index
			return ProjectileSystem.projectileObjectPool.objectPool[index]
		end
	end
	
	return nil
end

function ProjectileSystem:initProjectilesOnSystems()
	local request = self.initEntityRequestPool:getCurrentAvailableObject()
	request.projectileList = self.projectileObjectPool.objectPool
	self.eventDispatcher:postEvent(1, 5, request)
end

function ProjectileSystem:init()
	
end

---------------
--Exec Methods:
---------------

function ProjectileSystem:update(dt)
	--TODO: loop all OR get all actives with a spatial query?
	
	self:resolveRequestStack()
	
	for i=1, #self.projectileObjectPool.objectPool do
		if self.projectileObjectPool.objectPool[i].active then
			self:runProjectile(self.projectileObjectPool.objectPool[i], dt)
		end
	end
	
	self.spatialSystemRequestPool:resetCurrentIndex()
	self.registerProjectileSpatialQueryPool:resetCurrentIndex()
	self.unregisterProjectileSpatialQueryPool:resetCurrentIndex()
	self.healthRequestPool:resetCurrentIndex()
	self.initEntityRequestPool:resetCurrentIndex()
end

function ProjectileSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function ProjectileSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function ProjectileSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function ProjectileSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

ProjectileSystem.resolveRequestMethods = {
	[ProjectileSystem.PROJECTILE_REQUEST.INIT_PROJECTILE] = function(self, request)
		self:activateSpawn(request.spawnType, request.senderType, request.senderEntity, 
			request.senderRole, request.x, request.y, request.direction, 
			request.targetEntity)
	end,
	
	[ProjectileSystem.PROJECTILE_REQUEST.END_PROJECTILE] = function(self, request)
		self:destroyProjectile(request.projectileObject, request.destructionType, request.entityObject)
	end,
	
}

function ProjectileSystem:activateSpawn(spawnType, senderType, senderEntity, senderRole, x, y, 
	direction, targetEntity)
	
	--this is what is passed in the initiate projectile external message:
		--the sender/target type may not be needed
		--sender/target ref -> main object (there's no main object you fucker), not the components
		--TODO: projectile x, y must change with the entity direction -> offset transforms
	
	local spawn = self.spawnTable[spawnType]
	
	for i=1, #spawn.spawnObjects do
		local currentProjectile = self.projectileObjectPool:getCurrentAvailableObject()
		
		if currentProjectile ~= nil then	
			local projectileRole = self:getProjectileRole(spawn.spawnObjects[i].roleGroup, 
				senderRole)
			
			self:initProjectile(senderType, senderEntity, projectileRole, 
				spawn.spawnObjects[i].xOffset + x, 
				spawn.spawnObjects[i].yOffset + y, 
				spawn.spawnObjects[i].getDirection(direction, x, y, targetEntity), 
				targetEntity, 
				self.projectileTemplateTable[spawn.spawnObjects[i].projectileTemplate], 
				currentProjectile)
		end
	end
end

function ProjectileSystem:initProjectile(senderType, senderRef, role, x, y, direction, targetRef, 
	template, projectile)
	
	projectile.active = true
	projectile.components.state.globalState = 1
	projectile.components.state.currentTime = 0.0
	projectile.components.state.updatePoint = 0.0
	projectile.components.state.currentMethodIndex = 0
	projectile.components.state.currentControlMethod = 1
	projectile.components.state.animationCurrentTime = 0
	projectile.components.state.animationUpdatePoint = 0
	projectile.components.state.animationCurrentIndex = 1
	projectile.components.state.methodArguments = nil
	projectile.components.scene.role = role
	projectile.components.spatial.x = x
	projectile.components.spatial.y = y
	projectile.components.spatial.direction = direction		--direction of the projectile
	projectile.components.target.senderType = senderType
	projectile.components.target.senderRef = senderRef
	projectile.components.target.targetRef = targetRef
	projectile.components.sprite.rotation = 0				--rotation of the sprite, 
															--can calculated from the direction
	
	if projectile.components.state.projectileType ~= template.projectileType then
		projectile.components.state.projectileType = template.projectileType
		projectile.components.spatial.w = template.w
		projectile.components.spatial.h = template.h
		projectile.components.spatial.velocity = template.velocity
		projectile.components.sprite.spritesheetId = template.spritesheetId
		projectile.components.sprite.spritesheetQuad = template.spritesheetQuad
		projectile.components.sprite.spriteOffsetX = template.spriteOffsetX
		projectile.components.sprite.spriteOffsetY = template.spriteOffsetY
		projectile.components.sprite.defaultQuad = template.spritesheetQuad
		projectile.components.destruction.damage = template.damage
		projectile.controller = template.controller
		projectile.destructor = template.destructor
		projectile.animation = template.animation
	end
	
	self:registerProjectileOnSpatialSystem(projectile)
	
	local controller = self.controllerTable[projectile.controller]
	self:resetAnimation(projectile.components.state, controller)
	self:updateProjectile(projectile.components.state, controller)
	--update the current control method (??)
end

function ProjectileSystem:runProjectile(projectile, dt)
	local controller = self.controllerTable[projectile.controller]
	local stateComponent = projectile.components.state
	
	stateComponent.currentTime = stateComponent.currentTime + dt
	
	if stateComponent.currentTime >= controller.totalTime then
		self:destroyProjectile(projectile, self.PROJECTILE_DESTRUCTION_TYPE.GENERIC, nil)
	else
		self.controlMethods[stateComponent.currentControlMethod](self, projectile, 
			stateComponent.methodArguments, dt)
		
		if controller.animation then
			self:runAnimation(controller, stateComponent, dt)
		end
		
		if stateComponent.currentTime >= stateComponent.updatePoint then
			self:updateProjectile(stateComponent, controller)
		end
	end
end

function ProjectileSystem:updateProjectile(stateComponent, controller)
	if stateComponent.currentMethodIndex == #controller.methodMap then
		stateComponent.updatePoint = controller.totalTime
		stateComponent.currentControlMethod = 1	--runs a generic control method
		stateComponent.methodArguments = nil
	else
		stateComponent.currentMethodIndex = stateComponent.currentMethodIndex + 1
		stateComponent.updatePoint = controller.methodMap[stateComponent.currentMethodIndex].stopTime
		stateComponent.currentControlMethod = controller.methodMap[stateComponent.currentMethodIndex].methodId
		stateComponent.methodArguments = controller.methodMap[stateComponent.currentMethodIndex].arguments
	end
end

function ProjectileSystem:runAnimation(controller, stateComponent, dt)
	stateComponent.animationCurrentTime = stateComponent.animationCurrentTime + dt
	
	if stateComponent.animationCurrentTime >= controller.animationTotalTime then
		if controller.animationLoop then
			self:resetAnimation(stateComponent, controller)
		else
			stateComponent.animationCurrentTime = stateComponent.animationCurrentTime - dt
		end
	else
		if stateComponent.animationCurrentTime >= stateComponent.animationUpdatePoint then
			self:updateAnimation(stateComponent, controller)
		end
	end
end

function ProjectileSystem:updateAnimation(stateComponent, controller)
	local nextIndex = stateComponent.animationCurrentIndex + 1
	
	if nextIndex <= #controller.animationMap then
		stateComponent.animationUpdatePoint = controller.animationMap[nextIndex].updateTime
		stateComponent.self.components.sprite.spritesheetQuad = 
			controller.animationMap[stateComponent.animationCurrentIndex].quad
		stateComponent.animationCurrentIndex = nextIndex
	else
		stateComponent.animationUpdatePoint = controller.animationTotalTime
		stateComponent.self.components.sprite.spritesheetQuad = 
			controller.animationMap[stateComponent.animationCurrentIndex].quad
	end
end

function ProjectileSystem:resetAnimation(stateComponent, controller)
	if controller.animation then
		stateComponent.animationCurrentTime = 0
		stateComponent.animationCurrentIndex = 1
		stateComponent.animationUpdatePoint = controller.animationMap[1].updateTime	--check array length
		stateComponent.self.components.sprite.spritesheetQuad = 
			stateComponent.self.components.sprite.defaultQuad
	end
end

function ProjectileSystem:destroyProjectile(projectile, destructionType, entity)
	projectile.active = false
	self:unregisterProjectileOnSpatialSystem(projectile)
	self:runProjectileDestructor(projectile, self.destructorTable[projectile.destructor], 
		destructionType, entity)
end

function ProjectileSystem:runProjectileDestructor(projectile, destructor, destructionType, entity)
	destructor.methods[destructionType](self, projectile, entity)
end

function ProjectileSystem:getProjectileRole(roleGroup, senderRole)
	return self.ENTITY_ROLE_TRANSFORM:transformRoleUnique(roleGroup, senderRole)
end

function ProjectileSystem:registerProjectileOnSpatialSystem(projectile)
	local queryObj = self.registerProjectileSpatialQueryPool:getCurrentAvailableObjectDefault()
	--queryObj.querySubType = 1
	--queryObj.responseCallback = nil
	queryObj.entityType = self.ENTITY_TYPE.GENERIC_PROJECTILE
	queryObj.entityRole = projectile.components.scene.role
	queryObj.newRole = projectile.components.scene.role
	queryObj.entity = projectile.components.spatial
	
	local spatialSystemRequest = self.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = queryObj
	self.eventDispatcher:postEvent(2, 1, spatialSystemRequest)
	
	self.registerProjectileSpatialQueryPool:incrementCurrentIndex()
	self.spatialSystemRequestPool:incrementCurrentIndex()
end

function ProjectileSystem:unregisterProjectileOnSpatialSystem(projectile)
	local queryObj = self.unregisterProjectileSpatialQueryPool:getCurrentAvailableObjectDefault()
	--queryObj.querySubType = 1
	--queryObj.responseCallback = nil
	queryObj.entityType = self.ENTITY_TYPE.GENERIC_PROJECTILE
	queryObj.entityRole = projectile.components.scene.role
	queryObj.entity = projectile.components.spatial
	
	local spatialSystemRequest = self.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = queryObj
	self.eventDispatcher:postEvent(2, 1, spatialSystemRequest)
	
	self.unregisterProjectileSpatialQueryPool:incrementCurrentIndex()
	self.spatialSystemRequestPool:incrementCurrentIndex()
end

function ProjectileSystem:sendHealthRequest(healthComponent, requestType, value, effectState, effectId)
	local request = self.healthRequestPool:getCurrentAvailableObject()
	
	request.requestType = requestType
	request.healthComponent = healthComponent
	request.value = value
	request.effectState = effectState
	request.effectId = effectId
	
	self.eventDispatcher:postEvent(3, 2, request)
	self.healthRequestPool:incrementCurrentIndex()
end

----------------
--Return Module:
----------------

--ProjectileSystem:createProjectileObjectPool(300)
ProjectileSystem:createProjectileTemplateTable()
ProjectileSystem:createSpawnTable()
ProjectileSystem:createControllerTable()
ProjectileSystem:createDestructorTable()
ProjectileSystem:createAnimationTable()

return ProjectileSystem