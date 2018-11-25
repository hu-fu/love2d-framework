----------------------
--Scene Script System:
----------------------

local EntityScriptSystem = {}

---------------
--Dependencies:
---------------

require '/entity script/EntityScriptObjects'
require '/event/EventObjectPool'
EntityScriptSystem.EVENT_TYPES = require '/event/EVENT_TYPE'
EntityScriptSystem.SCRIPT = require '/entity script/ENTITY_SCRIPT'
EntityScriptSystem.SCRIPT_ASSETS = require '/entity script/ENTITY_SCRIPT_ASSET'
EntityScriptSystem.FLAG = require '/flag/FLAG'
EntityScriptSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityScriptSystem.ENTITY_ROLE = require '/entity/ENTITY_ROLE'
EntityScriptSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityScriptSystem.ENTITY_SCRIPT_REQUEST = require '/entity script/ENTITY_SCRIPT_REQUEST'
EntityScriptSystem.INPUT_ACTION = require '/input/PLAYER_SIMULATION_INPUT_ACTION'
EntityScriptSystem.ENTITY_STATE = require '/entity state/ENTITY_STATE'
EntityScriptSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
EntityScriptSystem.MOVEMENT_REQUEST = require '/entity movement/MOVEMENT_REQUEST'
EntityScriptSystem.IDLE_REQUEST = require '/entity idle/IDLE_REQUEST'
EntityScriptSystem.TARGETING_REQUEST = require '/target/TARGETING_REQUEST'
EntityScriptSystem.SPAWN_REQUEST = require '/spawn/SPAWN_REQUEST'
EntityScriptSystem.DESPAWN_REQUEST = require '/despawn/DESPAWN_REQUEST'

-------------------
--System Variables:
-------------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
EntityScriptSystem.id = SYSTEM_ID.ENTITY_SCRIPT

EntityScriptSystem.assetsFolderPath = '/entity script/asset/'

EntityScriptSystem.scriptComponentTable = nil
EntityScriptSystem.flagDb = nil
EntityScriptSystem.requestStack = {}

EntityScriptSystem.movementRequestPool = EventObjectPool.new(EntityScriptSystem.EVENT_TYPES.MOVEMENT, 5)
EntityScriptSystem.idleRequestPool = EventObjectPool.new(EntityScriptSystem.EVENT_TYPES.IDLE, 5)
EntityScriptSystem.targetingRequestPool = EventObjectPool.new(EntityScriptSystem.EVENT_TYPES.TARGETING, 5)
EntityScriptSystem.despawnRequestPool = EventObjectPool.new(EntityScriptSystem.EVENT_TYPES.ENTITY_DESPAWN, 5)

EntityScriptSystem.eventListenerList = {}
EntityScriptSystem.eventDispatcher = nil

----------------
--Event Methods:
----------------

EntityScriptSystem.eventMethods = {

	[1] = {
		[1] = function(request)
			--set entity table
			EntityScriptSystem:setScriptComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--set flag db
			EntityScriptSystem:setFlagDatabase(request.flagDb)
		end,
		
		[3] = function(request)
			--request into stack
			EntityScriptSystem:addRequestToStack(request)
		end,
		
		--...
	}
}

---------------
--Init Methods:
---------------

function EntityScriptSystem:setScriptComponentTable(entityDb)
	self.scriptComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.SCRIPT)
	self:initializeAutoScripts()
	self:reset()
end

function EntityScriptSystem:reset()
	self.movementRequestPool:resetCurrentIndex()
	self.idleRequestPool:resetCurrentIndex()
	self.targetingRequestPool:resetCurrentIndex()
	self.despawnRequestPool:resetCurrentIndex()
end

function EntityScriptSystem:initializeAutoScripts()
	for i=1, #self.scriptComponentTable do
		if self.scriptComponentTable[i].state and self.scriptComponentTable[i].autoScriptId then
			self:initScript(self.scriptComponentTable[i].autoScriptId, self.scriptComponentTable[i])
		end
	end
end

function EntityScriptSystem:setFlagDatabase(flagDb)
	self.flagDb = flagDb
end

function EntityScriptSystem:init()
	
end

---------------
--Exec Methods:
---------------

function EntityScriptSystem:update(dt)
	self:resolveRequestStack()
	self:runScripts(dt)
end

function EntityScriptSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function EntityScriptSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function EntityScriptSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function EntityScriptSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

EntityScriptSystem.resolveRequestMethods = {
	[EntityScriptSystem.ENTITY_SCRIPT_REQUEST.START_SCRIPT] = function(self, request)
		self:initScript(request.scriptId, request.scriptComponent)
	end
}

function EntityScriptSystem:loadScriptAsset(scriptId)
	local scriptAsset = self.SCRIPT_ASSETS[scriptId]
	if scriptAsset ~= nil then
		local path = self.assetsFolderPath .. scriptAsset.filepath
		local assetFile = require(path)
		return assetFile
	end
	return nil
end

function EntityScriptSystem:stopScript(component)
	component.currentTime = 0
	component.activeScript = nil
	
	if component.autoScriptId then
		self:initScript(component.autoScriptId, component)
	else
		component.state = false
	end
end

function EntityScriptSystem:restartScript(component)
	component.state = true
	component.currentTime = 0
	component.activeScript.initMethod(self, component.activeScript, component)
end

function EntityScriptSystem:runScripts(dt)
	for i=1, #self.scriptComponentTable do
		if self.scriptComponentTable[i].state and self.scriptComponentTable[i].activeScript then
			self:runScript(self.scriptComponentTable[i], dt)
		end
	end
end

function EntityScriptSystem:runScript(component, dt)
	component.currentTime = component.currentTime + dt
	
	if component.currentTime < component.activeScript['variables'].totalTime then
		for i=1, #component.activeScript.methodThreads do
			component.activeScript.methodThreads[i](self, component.activeScript, component, dt)
		end
	else
		if component.activeScript['variables'].replay then
			self:restartScript(component)
		else
			self:stopScript(component)
		end
	end
end

function EntityScriptSystem:initScript(scriptId, component)
	local scriptAsset = self:loadScriptAsset(scriptId)
	
	if scriptAsset then
		local scriptPlayer = ScriptPlayer.new(scriptAsset['id'], scriptAsset)
		component.activeScript = scriptPlayer
		component.activeScript.initMethod(self, component.activeScript, component)
		component.state = true
	end
end

function EntityScriptSystem:requestMovementAction(movementComponent, requestType)
	local movementSystemRequest = self.movementRequestPool:getCurrentAvailableObject()
	movementSystemRequest.requestType = requestType
	movementSystemRequest.movementComponent = movementComponent
	self.eventDispatcher:postEvent(1, 2, movementSystemRequest)
	self.movementRequestPool:incrementCurrentIndex()
end

function EntityScriptSystem:requestIdleAction(idleComponent, requestType)
	local idleSystemRequest = self.idleRequestPool:getCurrentAvailableObject()
	idleSystemRequest.requestType = requestType
	idleSystemRequest.idleComponent = idleComponent
	self.eventDispatcher:postEvent(2, 2, idleSystemRequest)
	self.idleRequestPool:incrementCurrentIndex()
end

function EntityScriptSystem:requestTargetingAction(targetingComponent, requestType)
	local targetingSystemRequest = self.targetingRequestPool:getCurrentAvailableObject()
	targetingSystemRequest.requestType = requestType
	targetingSystemRequest.targetingComponent = targetingComponent
	self.eventDispatcher:postEvent(3, 2, targetingSystemRequest)
	self.targetingRequestPool:incrementCurrentIndex()
end

function EntityScriptSystem:requestDespawnAction(despawnComponent, requestType)
	local despawnSystemRequest = self.despawnRequestPool:getCurrentAvailableObject()
	despawnSystemRequest.requestType = requestType
	despawnSystemRequest.despawnComponent = despawnComponent
	self.eventDispatcher:postEvent(4, 2, despawnSystemRequest)
	self.despawnRequestPool:incrementCurrentIndex()
end

----------------
--Return Module:
----------------

return EntityScriptSystem