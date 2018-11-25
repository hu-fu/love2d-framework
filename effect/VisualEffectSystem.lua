-----------------------
--Visual Effect System:
-----------------------

local VisualEffectSystem = {}

---------------
--Dependencies:
---------------

require '/effect/VisualEffect'
local SYSTEM_ID = require '/system/SYSTEM_ID'
VisualEffectSystem.EMITTER_TYPE = require '/effect/EMITTER_TYPE'
VisualEffectSystem.EFFECT_REQUEST = require '/effect/VISUAL_EFFECT_REQUEST'
VisualEffectSystem.EFFECT_TYPE = require '/effect/EFFECT_TYPE'
VisualEffectSystem.EFFECT_TEMPLATE_TYPE = require '/effect/VISUAL_EFFECT_TEMPLATE_TYPE'
VisualEffectSystem.EFFECT_TEMPLATE = require '/effect/VISUAL_EFFECT_TEMPLATE'
VisualEffectSystem.EFFECT_CONTROLLER_TYPE = require '/effect/VISUAL_EFFECT_CONTROLLER_TYPE'
VisualEffectSystem.EVENT_TYPE = require '/event/EVENT_TYPE'
VisualEffectSystem.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
VisualEffectSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
VisualEffectSystem.ENTITY_ROLE = require '/entity/ENTITY_ROLE'
VisualEffectSystem.ENTITY_ROLE_GROUP = require '/entity/ENTITY_ROLE_GROUP'
VisualEffectSystem.ENTITY_ROLE_TRANSFORM = require '/entity/ENTITY_ROLE_TRANSFORM'
VisualEffectSystem.ACTION_METHODS = require '/action/ACTION_METHOD'

VisualEffectSystem.controlMethods = require '/effect/EffectControlMethods'

-------------------
--System Variables:
-------------------

VisualEffectSystem.id = SYSTEM_ID.VISUAL_EFFECT

VisualEffectSystem.emitterObjectPool = EffectEmitterObjectPool.new(100)
VisualEffectSystem.effectObjectPool = VisualEffectObjectPool.new(500)

VisualEffectSystem.emitterTemplateTable = {}	--[id] = emitter obj
VisualEffectSystem.effectTemplateTable = {}		--[id] = template obj
VisualEffectSystem.controllerTable = {}			--[id] = controller obj

VisualEffectSystem.globalEmitter = nil

VisualEffectSystem.requestStack = {}

VisualEffectSystem.eventDispatcher = nil
VisualEffectSystem.eventListenerList = {}

VisualEffectSystem.initEntityRequestPool = EventObjectPool.new(VisualEffectSystem.EVENT_TYPE.INIT_ENTITY, 2)
VisualEffectSystem.actionLoaderRequestPool = EventObjectPool.new(VisualEffectSystem.EVENT_TYPE.ACTION, 100)

function VisualEffectSystem:spatialQueryDefaultCallbackMethod() return function () end end
VisualEffectSystem.spatialSystemRequestPool = EventObjectPool.new(VisualEffectSystem.EVENT_TYPE.SPATIAL_REQUEST, 100)
VisualEffectSystem.registerEmitterSpatialQueryPool = SpatialQueryPool.new(100, VisualEffectSystem.QUERY_TYPES.REINDEX_ENTITY, 
	SpatialQueryBuilder.new(), VisualEffectSystem:spatialQueryDefaultCallbackMethod())
VisualEffectSystem.unregisterEmitterSpatialQueryPool = SpatialQueryPool.new(100, VisualEffectSystem.QUERY_TYPES.UNREGISTER_ENTITY, 
	SpatialQueryBuilder.new(), VisualEffectSystem:spatialQueryDefaultCallbackMethod())

----------------
--Event Methods:
----------------

VisualEffectSystem.eventMethods = {

	[1] = {
		[1] = function(request)
			VisualEffectSystem:addRequestToStack(request)
		end,
		
	}
}

---------------
--Init Methods:
---------------

function VisualEffectSystem:createEmitterObjectPool(maxEmitters)
	self.emitterObjectPool:buildObjectPool(maxEmitters)
end

function VisualEffectSystem:createEffectObjectPool(maxEffects)
	self.effectObjectPool:buildObjectPool(maxEffects)
end

function VisualEffectSystem:createEmitterTemplateTable()
	self.emitterTemplateTable = {}
	
	local templates = require '/effect/EMITTER_TEMPLATE'
	self.emitterTemplateTable = templates
end

function VisualEffectSystem:createEffectTemplateTable()
	self.effectTemplateTable = {}
	
	local templates = require '/effect/VISUAL_EFFECT_TEMPLATE'
	self.effectTemplateTable = templates
end

function VisualEffectSystem:createControllerTable()
	self.controllerTable = {}
	
	local templates = require '/effect/VISUAL_EFFECT_CONTROLLER'
	
	for controllerType, controllerTemplate in pairs(templates) do
		local controller = VisualEffectController.new(controllerType, controllerTemplate.totalTime,
			controllerTemplate.loop, controllerTemplate.animation, controllerTemplate.animationTotalTime, 
			controllerTemplate.animationLoop)
		
		controller:setMethodMap(controllerTemplate.methods)
		controller:setAnimationMap(controllerTemplate.animationUpdate)
		self.controllerTable[controllerType] = controller
	end
end

VisualEffectSystem.emitterObjectPool.getCurrentAvailableObject = function()
	--are you sure this works? something is weird about this thing, test it in depth please.
	
	for i=1, #VisualEffectSystem.emitterObjectPool.objectPool do
		local index = ((i + VisualEffectSystem.emitterObjectPool.currentIndex) % 
			#VisualEffectSystem.emitterObjectPool.objectPool) + 1
		if not VisualEffectSystem.emitterObjectPool.objectPool[index].active then
			VisualEffectSystem.emitterObjectPool.currentIndex = index
			return VisualEffectSystem.emitterObjectPool.objectPool[index]
		end
	end
	
	return nil
end

VisualEffectSystem.effectObjectPool.getCurrentAvailableObject = function()
	for i=1, #VisualEffectSystem.effectObjectPool.objectPool do
		local index = ((i + VisualEffectSystem.effectObjectPool.currentIndex) % 
			#VisualEffectSystem.effectObjectPool.objectPool) + 1
		if not VisualEffectSystem.effectObjectPool.objectPool[index].active then
			VisualEffectSystem.effectObjectPool.currentIndex = index
			return VisualEffectSystem.effectObjectPool.objectPool[index]
		end
	end
	
	return nil
end

function VisualEffectSystem:createGlobalEmitter()
	self.globalEmitter = self.emitterObjectPool:getCurrentAvailableObject()
end

function VisualEffectSystem:initGlobalEmitter()
	self:initEmitter(self.EMITTER_TYPE.GLOBAL, nil, -1, -1, 0)
end

function VisualEffectSystem:initGlobalEmitterOnSystems()
	local request = self.initEntityRequestPool:getCurrentAvailableObject()
	request.globalEmitter = self.globalEmitter
	self.eventDispatcher:postEvent(3, 6, request)
end

function VisualEffectSystem:init()
	
end

---------------
--Exec Methods:
---------------

function VisualEffectSystem:update(dt)
	self:resolveRequestStack()
	
	for i=1, #self.emitterObjectPool.objectPool do
		if self.emitterObjectPool.objectPool[i].active then
			self:runEmitter(self.emitterObjectPool.objectPool[i], dt)
		end
	end
	
	for i=1, #self.effectObjectPool.objectPool do
		if self.effectObjectPool.objectPool[i].active then
			self:runVisualEffect(self.effectObjectPool.objectPool[i], dt)
		end
	end
	
	self.actionLoaderRequestPool:resetCurrentIndex()
	self.spatialSystemRequestPool:resetCurrentIndex()
	self.registerEmitterSpatialQueryPool:resetCurrentIndex()
	self.unregisterEmitterSpatialQueryPool:resetCurrentIndex()
end


function VisualEffectSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function VisualEffectSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function VisualEffectSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function VisualEffectSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

VisualEffectSystem.resolveRequestMethods = {
	[VisualEffectSystem.EFFECT_REQUEST.INIT_EMITTER] = function(self, request)
		self:initEmitter(request.emitterType, request.focusEntity, request.x, request.y, request.direction)
	end,
	
	[VisualEffectSystem.EFFECT_REQUEST.END_EMITTER] = function(self, request)
		self:endEmitter(request.emitterObject)
	end,
	
	[VisualEffectSystem.EFFECT_REQUEST.INIT_EFFECT] = function(self, request)
		self:spawnVisualEffect(request.effectType, request.x, request.y, request.direction, 
			request.emitterObject)
	end,
	
	[VisualEffectSystem.EFFECT_REQUEST.END_EFFECT] = function(self, request)
		--not even needed?
	end,
	
}

function VisualEffectSystem:getAction(actionSetId, actionId, emitter)
	local eventObj = self.actionLoaderRequestPool:getCurrentAvailableObject()
	
	eventObj.actionSetId = actionSetId
	eventObj.actionId = actionId
	eventObj.component = emitter
	eventObj.callback = self:getActionRequestCallbackMethod()
	
	self.eventDispatcher:postEvent(1, 1, eventObj)
	self.actionLoaderRequestPool:incrementCurrentIndex()
end

function VisualEffectSystem:getActionRequestCallbackMethod()
	return function (component, actionObject)
		--component = emitter
		if actionObject then
			self:setActionOnEmitter(component, actionObject) 
			self.ACTION_METHODS:resetAction(component)
			self:startEmitter(component)
		else
			--emitter resets before activation, so no need to reset it here
		end
	end
end

function VisualEffectSystem:setActionOnEmitter(emitter, actionObject)
	emitter.action = actionObject
end

function VisualEffectSystem:initEmitter(emitterType, focusEntity, x, y, direction)
	--activate emitter, set same as template, get action, start action cycle
	
	local emitter = self.emitterObjectPool:getCurrentAvailableObject()
	local emitterTemplate = self.emitterTemplateTable[emitterType]
	
	if emitter and emitterTemplate then
		self:resetEmitter(emitter)
		
		emitter.role = self.ENTITY_ROLE.VISUAL_EFFECT
		emitter.x = x + emitterTemplate.deviationX
		emitter.y = y + emitterTemplate.deviationY
		emitter.deviationX = emitterTemplate.deviationX
		emitter.deviationY = emitterTemplate.deviationY
		emitter.w = emitterTemplate.w
		emitter.h = emitterTemplate.h
		
		emitter.direction = direction + emitterTemplate.direction
		
		emitter.focus = emitterTemplate.focus
		emitter.focusEntity = focusEntity
		
		if emitter.focusEntity and emitterTemplate.overwriteDimensions then
			emitter.focusEntity.effectEmitter = emitter
			emitter.w = emitter.focusEntity.w
			emitter.h = emitter.focusEntity.h
		end
		
		emitter.actionSetId = emitterTemplate.actionSetId
		
		self:getAction(emitterTemplate.actionSetId, emitterTemplate.actionId, emitter)
		self:registerEmitterOnSpatialSystem(emitter)
	end
end

function VisualEffectSystem:startEmitter(emitter)
	emitter.active = true
end

function VisualEffectSystem:runEmitter(emitter, dt)
	if emitter.focus then
		if emitter.focusEntity then
			self:moveEmitter(emitter)
		else
			self:endEmitter(emitter)
		end
	end
	
	self.ACTION_METHODS:playAction(dt, self, emitter)
end

function VisualEffectSystem:moveEmitter(emitter)
	emitter.x = emitter.focusEntity.x + emitter.deviationX
	emitter.y = emitter.focusEntity.y + emitter.deviationY
end

function VisualEffectSystem:onActionEnd(emitter)
	self:endEmitter(emitter)
end

function VisualEffectSystem:endEmitter(emitter)
	if emitter then
		emitter.active = false
		self:unregisterEmitterOnSpatialSystem(emitter)
		self:removeEmitterFromParentEntity(emitter)
		self:resetEffectList(emitter)
	end
end

function VisualEffectSystem:removeEmitterFromParentEntity(emitter)
	emitter.focusEntity.effectEmitter = nil
	emitter.focusEntity = nil
end

function VisualEffectSystem:resetEmitter(emitter)
	emitter.active = false
	emitter.emitterType = 0
	emitter.x = 0
	emitter.y = 0
	emitter.w = 0
	emitter.h = 0
	emitter.focus = false
	emitter.focusEntity = nil
	emitter.actionSetId = nil
	emitter.action = nil
	emitter.currentTime = 0
	emitter.updatePoint = 0
	emitter.frameCounter = 0
	emitter.currentMethodIndex = 1
	self:resetEmitterMethodThreads(emitter)
	self:resetEffectList(emitter)
end

function VisualEffectSystem:resetEmitterMethodThreads(emitter)
	for i=#emitter.methodThreads, 1, -1 do
		table.remove(emitter.methodThreads)
	end
end

function VisualEffectSystem:resetEffectList(emitter)
	for i=#emitter.effectList, 1, -1 do
		emitter.effectList[i].active = false
		table.remove(emitter.effectList)
	end
end

function VisualEffectSystem:addEffectToEmitter(emitter, effect)
	effect.parentEmitter = emitter
	table.insert(emitter.effectList, effect)
end

function VisualEffectSystem:removeEffectFromEmitter(emitter, effect)
	for i=1, #emitter.effectList do
		if emitter.effectList[i] == effect then
			table.remove(emitter.effectList, i)
			break
		end
	end
end

function VisualEffectSystem:registerEmitterOnSpatialSystem(emitter)
	local queryObj = self.registerEmitterSpatialQueryPool:getCurrentAvailableObjectDefault()
	--queryObj.querySubType = 1
	--queryObj.responseCallback = nil
	queryObj.entityType = self.ENTITY_TYPE.VISUAL_EFFECT
	queryObj.entityRole = emitter.role
	queryObj.newRole = emitter.role
	queryObj.entity = emitter
	
	local spatialSystemRequest = self.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = queryObj
	self.eventDispatcher:postEvent(2, 1, spatialSystemRequest)
	
	self.registerEmitterSpatialQueryPool:incrementCurrentIndex()
	self.spatialSystemRequestPool:incrementCurrentIndex()
end

function VisualEffectSystem:unregisterEmitterOnSpatialSystem(emitter)
	local queryObj = self.unregisterEmitterSpatialQueryPool:getCurrentAvailableObjectDefault()
	--queryObj.querySubType = 1
	--queryObj.responseCallback = nil
	queryObj.entityType = self.ENTITY_TYPE.VISUAL_EFFECT
	queryObj.entityRole = emitter.role
	queryObj.entity = emitter
	
	local spatialSystemRequest = self.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = queryObj
	self.eventDispatcher:postEvent(2, 1, spatialSystemRequest)
	
	self.unregisterEmitterSpatialQueryPool:incrementCurrentIndex()
	self.spatialSystemRequestPool:incrementCurrentIndex()
end

function VisualEffectSystem:spawnVisualEffect(templateType, x, y, direction, parentEmitter)
	local template = self.effectTemplateTable[templateType]
	local effect = self.effectObjectPool:getCurrentAvailableObject()
	
	if effect ~= nil then
		self:initVisualEffect(x, y, direction, template, effect)
		
		if parentEmitter ~= nil then
			self:addEffectToEmitter(parentEmitter, effect)
		else
			self:addEffectToEmitter(self.globalEmitter, effect)
		end
	end
end

function VisualEffectSystem:initVisualEffect(x, y, direction, template, effect)
	effect.active = true
	effect.components.state.currentTime = 0.0
	effect.components.state.updatePoint = 0.0
	effect.components.state.currentMethodIndex = 0
	effect.components.state.currentControlMethod = 1
	effect.components.state.animationCurrentTime = 0
	effect.components.state.animationUpdatePoint = 0
	effect.components.state.animationCurrentIndex = 1
	effect.components.state.methodArguments = nil
	effect.components.spatial.x = x
	effect.components.spatial.y = y
	effect.components.spatial.direction = direction
	effect.components.sprite.rotation = 0
	
	if effect.components.state.effectType ~= template.effectType then
		effect.components.state.effectType = template.effectType
		effect.components.spatial.velocity = template.velocity
		effect.components.sprite.spritesheetId = template.spritesheetId
		effect.components.sprite.spritesheetQuad = template.spritesheetQuad
		effect.components.sprite.defaultQuad = template.spritesheetQuad
		effect.components.sprite.spriteOffsetX = template.spriteOffsetX
		effect.components.sprite.spriteOffsetY = template.spriteOffsetY
		effect.controller = template.controller
	end
	
	local controller = self.controllerTable[effect.controller]
	self:resetAnimation(effect.components.state, controller)
	self:updateVisualEffect(effect.components.state,controller)
end

function VisualEffectSystem:runVisualEffect(effect, dt)
	local controller = self.controllerTable[effect.controller]
	local stateComponent = effect.components.state
	
	stateComponent.currentTime = stateComponent.currentTime + dt
	
	if stateComponent.currentTime >= controller.totalTime then
		if controller.loop then
			self:resetVisualEffect(effect)
			self:resetAnimation(stateComponent, controller)
			self:updateVisualEffect(stateComponent, controller)
		else
			self:destroyVisualEffect(effect)
		end
	else
		self.controlMethods[stateComponent.currentControlMethod](self, 
			effect, stateComponent.methodArguments, dt)
		
		if controller.animation then
			self:runAnimation(controller, stateComponent, dt)
		end
		
		if stateComponent.currentTime >= stateComponent.updatePoint then
			self:updateVisualEffect(stateComponent, controller)
		end
	end
end

function VisualEffectSystem:updateVisualEffect(stateComponent, controller)
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

function VisualEffectSystem:runAnimation(controller, stateComponent, dt)
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

function VisualEffectSystem:destroyVisualEffect(effect)
	effect.active = false
	self:removeEffectFromEmitter(effect.parentEmitter, effect)
end

function VisualEffectSystem:resetVisualEffect(effect)
	local stateComponent = effect.components.state
	stateComponent.currentTime = 0.0
	stateComponent.currentMethodIndex = 0
	stateComponent.updatePoint = 0
	stateComponent.currentControlMethod = 0
	stateComponent.methodArguments = nil
end

function VisualEffectSystem:resetAnimation(stateComponent, controller)
	if controller.animation then
		stateComponent.animationCurrentTime = 0
		stateComponent.animationCurrentIndex = 1
		stateComponent.animationUpdatePoint = controller.animationMap[1].updateTime	--check array length
		stateComponent.self.components.sprite.spritesheetQuad = 
			stateComponent.self.components.sprite.defaultQuad
	end
end

function VisualEffectSystem:updateAnimation(stateComponent, controller)
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

----------------
--Return Module:
----------------

VisualEffectSystem:createEmitterObjectPool(50)
VisualEffectSystem:createEffectObjectPool(300)
VisualEffectSystem:createEmitterTemplateTable()
VisualEffectSystem:createEffectTemplateTable()
VisualEffectSystem:createControllerTable()
VisualEffectSystem:createGlobalEmitter()

return VisualEffectSystem