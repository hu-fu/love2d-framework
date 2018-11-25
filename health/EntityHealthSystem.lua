---------------------
--Entity Idle System:
----------------------

local EntityHealthSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
EntityHealthSystem.EVENT_TYPE = require '/event/EVENT_TYPE'
EntityHealthSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityHealthSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityHealthSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
EntityHealthSystem.HEALTH_REQUEST = require '/health/HEALTH_REQUEST'
EntityHealthSystem.HEALTH_POOL_SCRIPT = require '/health/HEALTH_POOL_SCRIPT'
EntityHealthSystem.HEALTH_EFFECT_SCRIPT = require '/health/HEALTH_EFFECT_SCRIPT'
EntityHealthSystem.DESPAWN_REQUEST = require '/despawn/DESPAWN_REQUEST'

-------------------
--System Variables:
-------------------

EntityHealthSystem.id = SYSTEM_ID.HEALTH

EntityHealthSystem.despawnRequestPool = EventObjectPool.new(EntityHealthSystem.EVENT_TYPE.ENTITY_DESPAWN, 100)

EntityHealthSystem.healthComponentTable = {}
EntityHealthSystem.requestStack = {}

EntityHealthSystem.eventDispatcher = nil
EntityHealthSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

EntityHealthSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--set entity component table (request.entityDb)
			EntityHealthSystem:setHealthComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--request into stack
			EntityHealthSystem:addRequestToStack(request)
		end
	}
}

---------------
--Init Methods:
---------------

function EntityHealthSystem:setHealthComponentTable(entityDb)
	self.healthComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.HEALTH)
end

function EntityHealthSystem:init()
	
end

---------------
--Exec Methods:
---------------

function EntityHealthSystem:update(dt)
	self:resolveRequestStack()
	
	for i=1, #self.healthComponentTable do
		local component = self.healthComponentTable[i]
		
		if component.state and component.effects then
			self:updateEntity(dt, component)
		end
	end
	
	self.despawnRequestPool:resetCurrentIndex()
end

function EntityHealthSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function EntityHealthSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function EntityHealthSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function EntityHealthSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

EntityHealthSystem.resolveRequestMethods = {
	[EntityHealthSystem.HEALTH_REQUEST.SET_EFFECT] = function(self, request)
		EntityHealthSystem:setEffectScript(request.healthComponent, request.effectId, request.effectState)
	end,
	
	[EntityHealthSystem.HEALTH_REQUEST.MODIFY_HEALTH_POINTS] = function(self, request)
		EntityHealthSystem:modifyHealthPoints(request.healthComponent, request.value)
	end,
	
}

function EntityHealthSystem:modifyHealthPoints(component, value)
	local finalValue = value
	--finalValue = value - component.healthPointsResistance	--for example
	
	if component.healthPointsScript then
		local script = self:getHealthPoolScript(component.healthPointsScript)
		currentP = self:getPercentage(component.healthPoints, component.maxHealthPoints)
		finalP = self:getPercentage(component.healthPoints + finalValue, component.maxHealthPoints)
		self:runHealthPoolScript(script, component, currentP, finalP)
	end
	
	component.healthPoints = component.healthPoints + finalValue
	
	if component.healthPoints > component.maxHealthPoints then
		component.healthPoints = component.maxHealthPoints
	elseif component.healthPoints < 0 then
		component.healthPoints = 0
	end
end

function EntityHealthSystem:runHealthPoolScript(script, component, currentPercentage, finalPercentage)
	if currentPercentage > finalPercentage then
		--pool value decreases
		
		script.onHit(self, script, component)
		
		for i=1, #script.onLoss do
			if script.onLoss[i].activationPercentage < currentPercentage and 
				script.onLoss[i].activationPercentage >= finalPercentage then
				
				script.onLoss[i].method(self, script, component)
			end
		end
		
	elseif currentPercentage < finalPercentage then
		--pool value increases
		script.onRegen(self, script, component)
		
		for i=1, #script.onGain do
			if script.onGain[i].activationPercentage > currentPercentage and 
				script.onGain[i].activationPercentage <= finalPercentage then
				
				script.onGain[i].method(self, script, component)
			end
		end
	else
		--equal, nothing happens
	end
end

function EntityHealthSystem:getHealthPoolScript(scriptId)
	return EntityHealthSystem.HEALTH_POOL_SCRIPT.SCRIPT[scriptId]
end

function EntityHealthSystem:setEffectScript(component, scriptId, state)
	if not component.effects then return nil end
	
	local script = false
	
	for i=1, #component.activeScripts do
		if component.activeScripts[i] == scriptId then
			script = true
			break
		end
	end
	
	if state and not script then
		self:activateEffectScript(component, scriptId)
	elseif not state and script then
		self:deactivateEffectScript(component, scriptId)
	end
end

function EntityHealthSystem:updateEntity(dt, component)
	for i=1, #component.activeScripts do
		local script = self:getEffectScript(component.activeScripts[i])
		self:runEffectScript(script, component, dt)
	end
end

function EntityHealthSystem:activateEffectScript(component, scriptId)
	local script = self:getEffectScript(scriptId)
	
	if script then
		self:addScriptToComponent(component, scriptId)
		self:startScript(script, component)
	end
end

function EntityHealthSystem:deactivateEffectScript(component, scriptId)
	self:removeScriptFromComponent(component, scriptId)
	local script = self:getEffectScript(scriptId)
	self:endScript(script, component)
end

function EntityHealthSystem:getEffectScript(scriptId)
	return EntityHealthSystem.HEALTH_EFFECT_SCRIPT.SCRIPT[scriptId]
end

function EntityHealthSystem:runEffectScript(script, component, dt)
	script.onRun(self, script, component, dt)
end

function EntityHealthSystem:startScript(script, component)
	script.onStart(self, script, component)
end

function EntityHealthSystem:endScript(script, component)
	script.onEnd(self, script, component)
end

function EntityHealthSystem:removeScriptFromComponent(component, scriptId)
	for i=1, #component.activeScripts do
		if component.activeScripts[i] == scriptId then
			table.remove(component.activeScripts, i)
			break
		end
	end
end

function EntityHealthSystem:addScriptToComponent(component, scriptId)
	table.insert(component.activeScripts, scriptId)
end

function EntityHealthSystem:getPercentage(currentValue, maxValue)
	return (currentValue*100)/maxValue
end

function EntityHealthSystem:sendDespawnRequest(healthComponent, despawnRequestType, actionSetId, actionId)
	local effectRequest = self.despawnRequestPool:getCurrentAvailableObject()
	local despawnComponent = healthComponent.componentTable.despawn
	
	effectRequest.requestType = despawnRequestType
	effectRequest.despawnComponent = despawnComponent
	effectRequest.actionSetId = actionSetId
	effectRequest.actionId = actionId
	
	self.eventDispatcher:postEvent(1, 2, effectRequest)
	self.despawnRequestPool:incrementCurrentIndex()
end

----------------
--Return module:
----------------

return EntityHealthSystem