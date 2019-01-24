---------------------
--Entity Idle System:
----------------------
	--Action set id must be unique to all the combat actions
	--	Terrible design but I'm not fixing it
	--	There's a command for running custom actionSetId/actionId, use that

local EntityCombatSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
EntityCombatSystem.EVENT_TYPE = require '/event/EVENT_TYPE'
EntityCombatSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityCombatSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityCombatSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
EntityCombatSystem.COMBAT_REQUEST = require '/combat/COMBAT_REQUEST'
EntityCombatSystem.COMBAT_STATE = require '/combat/COMBAT_STATE'
EntityCombatSystem.ACTION_METHODS = require '/action/ACTION_METHOD'
EntityCombatSystem.ATTACK_TYPE = require '/combat/ATTACK_TYPE'
EntityCombatSystem.PROJECTILE_REQUEST = require '/projectile/PROJECTILE_REQUEST'
EntityCombatSystem.PROJECTILE_SPAWN_TYPES = require '/projectile/PROJECTILE_SPAWN_TYPE'
EntityCombatSystem.VISUAL_EFFECT_REQUEST = require '/effect/VISUAL_EFFECT_REQUEST'
EntityCombatSystem.VISUAL_EFFECT_EMITTER_TYPE = require '/effect/EMITTER_TYPE'
EntityCombatSystem.VISUAL_EFFECT_TYPE = require '/effect/EFFECT_TYPE'
EntityCombatSystem.HEALTH_REQUEST = require '/health/HEALTH_REQUEST'
EntityCombatSystem.SOUND = require '/sound/SOUND'
EntityCombatSystem.SOUND_TYPE = require '/sound/SOUND_TYPE'
EntityCombatSystem.SOUND_REQUEST = require '/sound/SOUND_REQUEST'
EntityCombatSystem.DIALOGUE_REQUEST = require '/dialogue/DIALOGUE_REQUEST'
EntityCombatSystem.IDLE_REQUEST = require '/entity idle/IDLE_REQUEST'
EntityCombatSystem.MOVEMENT_REQUEST = require '/entity movement/MOVEMENT_REQUEST'
EntityCombatSystem.ANIMATION_REQUEST = require '/animation/ANIMATION_REQUEST'

-------------------
--System Variables:
-------------------

EntityCombatSystem.id = SYSTEM_ID.COMBAT

EntityCombatSystem.animationRequestPool = EventObjectPool.new(EntityCombatSystem.EVENT_TYPE.ANIMATION, 100)
EntityCombatSystem.actionLoaderRequestPool = EventObjectPool.new(EntityCombatSystem.EVENT_TYPE.ACTION, 100)
EntityCombatSystem.entityInputRequestPool = EventObjectPool.new(EntityCombatSystem.EVENT_TYPE.ENTITY_INPUT, 100)
EntityCombatSystem.projectileRequestPool = EventObjectPool.new(EntityCombatSystem.EVENT_TYPE.PROJECTILE, 100)
EntityCombatSystem.visualEffectRequestPool = EventObjectPool.new(EntityCombatSystem.EVENT_TYPE.VISUAL_EFFECT, 100)
EntityCombatSystem.healthRequestPool = EventObjectPool.new(EntityCombatSystem.EVENT_TYPE.ENTITY_HEALTH, 100)
EntityCombatSystem.soundRequestPool = EventObjectPool.new(EntityCombatSystem.EVENT_TYPE.SOUND, 100)
EntityCombatSystem.dialogueRequestPool = EventObjectPool.new(EntityCombatSystem.EVENT_TYPE.DIALOGUE, 100)
EntityCombatSystem.idleRequestPool = EventObjectPool.new(EntityCombatSystem.EVENT_TYPE.IDLE, 100)
EntityCombatSystem.movementRequestPool = EventObjectPool.new(EntityCombatSystem.EVENT_TYPE.MOVEMENT, 100)

EntityCombatSystem.combatComponentTable = {}
EntityCombatSystem.requestStack = {}

EntityCombatSystem.eventDispatcher = nil
EntityCombatSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

EntityCombatSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--set entity component table (request.entityDb)
			EntityCombatSystem:setCombatComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--request into stack
			EntityCombatSystem:addRequestToStack(request)
		end
	}
}

---------------
--Init Methods:
---------------

function EntityCombatSystem:setCombatComponentTable(entityDb)
	self.combatComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.COMBAT)
	self:createAttackComboStateTables()
end

function EntityCombatSystem:createAttackComboStateTables()
	for i=1, #self.combatComponentTable do
		self:createAttackComboStateTable(self.combatComponentTable[i])
	end
end

function EntityCombatSystem:createAttackComboStateTable(combatComponent)
	combatComponent.attackComboState = {}
	
	for i=1, combatComponent.maxAttackCombo do
		table.insert(combatComponent.attackComboState, 1)
	end
end

function EntityCombatSystem:init()
	
end

---------------
--Exec Methods:
---------------

function EntityCombatSystem:update(dt)
	self:resolveRequestStack()
	
	for i=1, #self.combatComponentTable do
		if self.combatComponentTable[i].state then
			self:updateEntity(dt, self.combatComponentTable[i])
		else
			self:restoreStamina(dt, self.combatComponentTable[i])
		end
	end
	
	self.animationRequestPool:resetCurrentIndex()
	self.actionLoaderRequestPool:resetCurrentIndex()
	self.entityInputRequestPool:resetCurrentIndex()
	self.projectileRequestPool:resetCurrentIndex()
	self.visualEffectRequestPool:resetCurrentIndex()
	self.healthRequestPool:resetCurrentIndex()
	self.soundRequestPool:resetCurrentIndex()
	self.dialogueRequestPool:resetCurrentIndex()
	self.idleRequestPool:resetCurrentIndex()
	self.movementRequestPool:resetCurrentIndex()
	
	--INFO_STR = self.combatComponentTable[3].attackComboState[1] .. ', ' .. 
	--	self.combatComponentTable[3].attackComboState[2] .. ', ' .. 
	--	self.combatComponentTable[3].attackComboState[3]
	
	--INFO_STR = self.combatComponentTable[3].currentTime
end

function EntityCombatSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function EntityCombatSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function EntityCombatSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function EntityCombatSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
	self:isStateOver(request.combatComponent)	--not needed if you fix the damn controller
end

function EntityCombatSystem:getAction(actionSetId, actionId, combatComponent)
	local eventObj = self.actionLoaderRequestPool:getCurrentAvailableObject()
	
	eventObj.actionSetId = actionSetId
	eventObj.actionId = actionId
	eventObj.component = combatComponent
	eventObj.callback = self:getActionRequestCallbackMethod()
	
	self.eventDispatcher:postEvent(1, 1, eventObj)
	self.actionLoaderRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:getActionRequestCallbackMethod()
	return function (component, actionObject)
		if actionObject then
			self:setActionOnComponent(component, actionObject) 
			self.ACTION_METHODS:resetAction(component)
			self:setAnimation(component)
			self:sendChangeStateRequest(component)
			self:setCombatDirection(component)
		else
			self:endState(component)
		end
	end
end

function EntityCombatSystem:setAnimation(component)
	if not component.action.variables.walkAnimation or not 
		component.action.variables.idleAction then
		self:startAnimation(component)
	else
		if component.action.variables.walkAnimation then
			self:modifyWalkAnimation(component, component.action.variables.walkAnimationSetId, 
				component.action.variables.walkAnimationId)
		else
			self:resetWalkAnimation(component)
		end
		
		if component.action.variables.idleAction then
			self:modifyIdleAction(component, component.action.variables.idleActionSetId, 
				component.action.variables.idleActionId)
		else
			self:resetIdleAction(component)
		end
	end
end

function EntityCombatSystem:setActionOnComponent(component, actionObject)
	component.action = actionObject
end

function EntityCombatSystem:stopAction(combatComponent)
	self.ACTION_METHODS:resetComponent(combatComponent)
end

function EntityCombatSystem:onActionEnd(combatComponent)
	self:endState(combatComponent)
end

function EntityCombatSystem:sendChangeStateRequest(combatComponent)
	local eventObj = self.entityInputRequestPool:getCurrentAvailableObject()
	
	eventObj.inputComponent = combatComponent.componentTable.input
	
	if combatComponent.action.variables.free then
		eventObj.actionId = self.ENTITY_ACTION.FREE_COMBAT
	else
		eventObj.actionId = self.ENTITY_ACTION.RESTRICT_COMBAT
	end
	
	self.eventDispatcher:postEvent(3, 4, eventObj)
	self.entityInputRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:sendEndStateRequest(combatComponent)
	local eventObj = self.entityInputRequestPool:getCurrentAvailableObject()
	
	eventObj.actionId = self.ENTITY_ACTION.END_COMBAT
	eventObj.inputComponent = combatComponent.componentTable.input
	
	self.eventDispatcher:postEvent(3, 4, eventObj)
	self.entityInputRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:resetWalkAnimation(component)
	local eventObj = self.movementRequestPool:getCurrentAvailableObject()
	eventObj.movementComponent = combatComponent.componentTable.movement
	
	eventObj.requestType = self.MOVEMENT_REQUEST.RESET_MOVEMENT
	
	self.eventDispatcher:postEvent(10, 2, eventObj)
	self.movementRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:resetIdleAction(component)
	local eventObj = self.idleRequestPool:getCurrentAvailableObject()
	eventObj.inputComponent = combatComponent.componentTable.input
	
	eventObj.requestType = self.IDLE_REQUEST.RESET_IDLE_ACTION
	
	self.eventDispatcher:postEvent(9, 2, eventObj)
	self.idleRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:modifyWalkAnimation(component, animationSetId, animationId)
	local eventObj = self.movementRequestPool:getCurrentAvailableObject()
	eventObj.movementComponent = combatComponent.componentTable.movement
	eventObj.animationSetId = animationSetId
	eventObj.animationId = animationId
	
	eventObj.requestType = self.MOVEMENT_REQUEST.RESET_MOVEMENT_CUSTOM
	
	self.eventDispatcher:postEvent(10, 2, eventObj)
	self.movementRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:modifyIdleAction(component, actionSetId, actionId)
	local eventObj = self.idleRequestPool:getCurrentAvailableObject()
	eventObj.idleComponent = combatComponent.componentTable.idle
	eventObj.actionSetId = actionSetId
	eventObj.actionId = actionId
	
	eventObj.requestType = self.IDLE_REQUEST.RESET_IDLE_ACTION_CUSTOM
	
	self.eventDispatcher:postEvent(9, 2, eventObj)
	self.idleRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:updateEntity(dt, combatComponent)
	self.ACTION_METHODS:playAction(dt, self, combatComponent)
end

function EntityCombatSystem:startAnimation(combatComponent)
	if combatComponent.action then
		local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
		animationRequest.requestType = self.ANIMATION_REQUEST.SET_ANIMATION
		animationRequest.animationSetId = combatComponent.action.animationSetId
		animationRequest.animationId = combatComponent.action.animationId
		animationRequest.spritebox = combatComponent.componentTable.spritebox
		
		self.eventDispatcher:postEvent(2, 2, animationRequest)
		self.animationRequestPool:incrementCurrentIndex()
	end
end

function EntityCombatSystem:stopAnimation(combatComponent)
	--not needed
end

EntityCombatSystem.resolveRequestMethods = {
	[EntityCombatSystem.COMBAT_REQUEST.ATTACK_SLOT_A] = function(self, request)
		local atkIndex = 1
		local actionSetId, actionId = self:getAttackActionByIndex(request.combatComponent, atkIndex)
		self:activateCombatAction(request.combatComponent, actionSetId, actionId, atkIndex)
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.ATTACK_SLOT_B] = function(self, request)
		local atkIndex = 2
		local actionSetId, actionId = self:getAttackActionByIndex(request.combatComponent, atkIndex)
		self:activateCombatAction(request.combatComponent, actionSetId, actionId, atkIndex)
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.ATTACK_SLOT_C] = function(self, request)
		local atkIndex = 3
		local actionSetId, actionId = self:getAttackActionByIndex(request.combatComponent, atkIndex)
		self:activateCombatAction(request.combatComponent, actionSetId, actionId, atkIndex)
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.ATTACK_MELEE] = function(self, request)
	
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.ATTACK_RANGED] = function(self, request)
	
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.ATTACK_INDEX] = function(self, request)
	
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.ATTACK_CUSTOM] = function(self, request)
	
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.LOCKUP] = function(self, request)
		local actionSetId, actionId = self:getLockupAction(request.combatComponent)
		self:activateInterruptAction(request.combatComponent, actionSetId, actionId)
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.KNOCKBACK] = function(self, request)
		local actionSetId, actionId = self:getKnockbackAction(request.combatComponent)
		self:activateInterruptAction(combatComponent, actionSetId, actionId)
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.SPECIAL_MOVE] = function(self, request)
	
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.SPECIAL_ATTACK] = function(self, request)
	
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.END_ATTACK] = function(self, request)
		self:cancelRangedCombatAction(request.combatComponent)
	end,
	
	[EntityCombatSystem.COMBAT_REQUEST.END_COMBAT] = function(self, request)
	
	end,
}

function EntityCombatSystem:activateCombatAction(combatComponent, actionSetId, actionId, atkIndex)
	if self:isAttackActionAllowed(combatComponent) then
		self:getAction(actionSetId, actionId, combatComponent)
		
		if combatComponent.action then
			self:setComponentState(combatComponent, combatComponent.action.variables.combatState)
			self:resetComboActivationState(combatComponent)
			self:depleteStamina(combatComponent.action.variables.staminaCost, combatComponent)
			
			if atkIndex then
				self:incrementAttackComboState(combatComponent, atkIndex)
			end
		end
	else
		
	end
end

function EntityCombatSystem:activateInterruptAction(combatComponent, actionSetId, actionId)
	if self:isInterruptActionAllowed(combatComponent) then
		self:getAction(actionSetId, actionId, combatComponent)
		
		if combatComponent.action then
			self:setComponentState(combatComponent, combatComponent.action.variables.combatState)
			self:resetComboActivationState(combatComponent)
		end
	end
end

function EntityCombatSystem:cancelRangedCombatAction(combatComponent)
	if combatComponent.action and combatComponent.action.variables.cancel then
		combatComponent.currentTime = combatComponent.action.variables.cancelTime
	end
end

function EntityCombatSystem:setComponentState(combatComponent, state)
	combatComponent.state = state
end

function EntityCombatSystem:endState(combatComponent)
	self:stopAction(combatComponent)
	self:stopAnimation(combatComponent)
	self:resetWalkAnimation(combatComponent)
	self:resetCombatComponent(combatComponent)
	self:resetSpriteboxComponent(combatComponent.componentTable.spritebox)
	self:sendEndStateRequest(combatComponent)
end

function EntityCombatSystem:resetCombatComponent(combatComponent)
	combatComponent.state = false
	combatComponent.comboActivation = false
	self:resetAttackComboStateTable(combatComponent)
end

function EntityCombatSystem:resetSpriteboxComponent(spriteboxComponent)
	--use to reset the charsprite
end

function EntityCombatSystem:resetComboActivationState(combatComponent)
	combatComponent.comboActivation = false
end

function EntityCombatSystem:resetAttackComboStateTable(combatComponent)
	for i=1, #combatComponent.attackComboState do
		combatComponent.attackComboState[i] = 1
	end
end

function EntityCombatSystem:getActionIdByAction(actionObj)
	return actionObj.setId, actionObj.id
end

function EntityCombatSystem:getAttackActionByIndex(combatComponent, atkIndex)
	local actionSetId = combatComponent.actionSetId
	local attackId = combatComponent.attackEquipped[atkIndex][combatComponent.attackComboState[atkIndex]]
	return actionSetId, attackId
end

function EntityCombatSystem:getAttackActionById(actionSetId, actionId)
	return actionSetId, actionId
end

function EntityCombatSystem:getAttackActionByAttackType(combatComponent, actionType)
	--oh shit how are you gonna do this???? The attackEquipped table only has the action ids
		--TODO: code on the attack methods a way to get an attack object by id
		--Is this needed?
end

function EntityCombatSystem:getSpecialAttackAction(combatComponent)
	return combatComponent.actionSetId, combatComponent.specialEquipped
end

function EntityCombatSystem:getSpecialMoveAction(combatComponent)
	return combatComponent.actionSetId, combatComponent.moveEquipped
end

function EntityCombatSystem:getKnockbackAction(combatComponent)
	return combatComponent.actionSetId, combatComponent.knockbackEquipped
end

function EntityCombatSystem:getLockupAction(combatComponent)
	return combatComponent.actionSetId, combatComponent.lockupEquipped
end

function EntityCombatSystem:isStateOver(combatComponent)
	if not combatComponent.action then
		self:endState(combatComponent)
		return true
	end
end

function EntityCombatSystem:isAttackActionAllowed(combatComponent)
	if (not combatComponent.action or combatComponent.action.variables.cancel
		or combatComponent.comboActivation) and self:staminaCheck(combatComponent) then
		return true
	else
		return false
	end
end

function EntityCombatSystem:isInterruptActionAllowed(combatComponent)
	--if interrupt == true for example
	return true
end

function EntityCombatSystem:incrementAttackComboState(combatComponent, atkIndex)
	if (combatComponent.attackComboState[atkIndex] + 1) <= #combatComponent.attackEquipped then
		combatComponent.attackComboState[atkIndex] = combatComponent.attackComboState[atkIndex] + 1
	else
		combatComponent.attackComboState[atkIndex] = 1
	end
end

function EntityCombatSystem:setComboActivationState(combatComponent, activationState)
	combatComponent.comboActivation = activationState
end

--#stamina methods:#--

function EntityCombatSystem:staminaCheck(combatComponent)
	if combatComponent.currentStamina > 0 then
		return true
	end
	return false
end

function EntityCombatSystem:restoreStamina(dt, combatComponent)
	--this is supposed to run every frame for every component:
	
	if combatComponent.currentStamina < combatComponent.maxStamina then
		combatComponent.currentStamina = combatComponent.currentStamina + 
			(combatComponent.maxStamina*combatComponent.staminaRecoveryRate*dt)
		
		if combatComponent.currentStamina > combatComponent.maxStamina then
			combatComponent.currentStamina = combatComponent.maxStamina
		end
	end
end

function EntityCombatSystem:depleteStamina(staminaCost, combatComponent)
	if staminaCost then
		combatComponent.currentStamina = combatComponent.currentStamina - staminaCost
	end
end

function EntityCombatSystem:setCombatDirection(component)
	self:setLockDirection(component, component.componentTable.movement.rotation)
end

function EntityCombatSystem:setDirectionLockState(component, state)
	local targetingComponent = component.componentTable.targeting
	
	if targetingComponent then
		targetingComponent.directionLock = state
	end
end

function EntityCombatSystem:setLockDirection(component, direction)
	--should be a request but whatever
	
	local targetingComponent = component.componentTable.targeting
	
	if targetingComponent and targetingComponent.directionLock then
		targetingComponent.direction = direction
	end
end

--#other requests:#--

function EntityCombatSystem:sendProjectileRequest(combatComponent, spawnType, rotation)
	local hitbox = combatComponent.componentTable.hitbox
	local projectileRequest = self.projectileRequestPool:getCurrentAvailableObject()
	local targetingComponent = hitbox.componentTable.targeting
	
	projectileRequest.requestType = self.PROJECTILE_REQUEST.INIT_PROJECTILE
	projectileRequest.spawnType = spawnType
	projectileRequest.senderType = nil
	projectileRequest.senderEntity = hitbox
	projectileRequest.senderRole = hitbox.componentTable.scene.role
	projectileRequest.x = hitbox.x + (hitbox.w/2)
	projectileRequest.y = hitbox.y + (hitbox.h/2)
	projectileRequest.direction = rotation
	
	if targetingComponent then
		projectileRequest.targetEntity = targetingComponent.targetHitbox
			
		if targetingComponent.directionLock then
			projectileRequest.direction = targetingComponent.direction
		end
	end
	
	self.eventDispatcher:postEvent(4, 1, projectileRequest)
	self.projectileRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:sendVisualEffectRequest(combatComponent, emmiterRequestType, emitterType, 
	effectType, focusEntity, x, y, rotation, emitterObject)
	local effectRequest = self.visualEffectRequestPool:getCurrentAvailableObject()
	
	effectRequest.requestType = emmiterRequestType
	effectRequest.emitterType = emitterType
	effectRequest.effectType = effectType
	effectRequest.focusEntity = focusEntity
	effectRequest.x = x
	effectRequest.y = y
	effectRequest.direction = rotation
	effectRequest.emitterObject = emitterObject
	
	self.eventDispatcher:postEvent(5, 1, effectRequest)
	self.projectileRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:sendHealthRequest(combatComponent, healthRequestType, value, state, 
	effectId)
	local effectRequest = self.healthRequestPool:getCurrentAvailableObject()
	local healthComponent = combatComponent.componentTable.health
	
	effectRequest.requestType = healthRequestType
	effectRequest.healthComponent = healthComponent
	effectRequest.value = value
	effectRequest.effectState = state
	effectRequest.effectId = effectId
	
	self.eventDispatcher:postEvent(6, 2, effectRequest)
	self.healthRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:sendSoundRequest(combatComponent, requestType, audioId, soundType, playerId,
	playerName, volumePercentage, loop, effectId, parentEntity, distance, x, y)
	local soundRequest = self.soundRequestPool:getCurrentAvailableObject()
	local hitboxComponent = combatComponent.componentTable.hitbox
	
	soundRequest.requestType = requestType
	
	soundRequest.audioId = audioId
	soundRequest.soundType = soundType
	soundRequest.playerId = playerId
	soundRequest.playerName = playerName
	soundRequest.volumePercentage = volumePercentage
	soundRequest.loop = loop
	soundRequest.effectId = effectId
	soundRequest.parentEntity = parentEntity
	soundRequest.distance = distance
	soundRequest.x = x
	soundRequest.y = y
				
	self.eventDispatcher:postEvent(7, 3, soundRequest)
	self.soundRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:sendDialogueRequest(combatComponent, dialogueRequestType, player,
	playerType, dialogueId, lineNumber, choiceId)
	local dialogueRequest = self.dialogueRequestPool:getCurrentAvailableObject()
	
	dialogueRequest.requestType = dialogueRequestType
	dialogueRequest.player = player
	dialogueRequest.playerType = playerType
	dialogueRequest.dialogueId = dialogueId
	dialogueRequest.parentEntity = combatComponent
	dialogueRequest.lineNumber = lineNumber
	dialogueRequest.choiceId = choiceId
	
	self.eventDispatcher:postEvent(8, 1, dialogueRequest)
	self.dialogueRequestPool:incrementCurrentIndex()
end

function EntityCombatSystem:sendInputControllerRequest(combatComponent, actionId)
	local eventObj = self.entityInputRequestPool:getCurrentAvailableObject()
	
	eventObj.actionId = actionId
	eventObj.inputComponent = combatComponent.componentTable.input
	
	self.eventDispatcher:postEvent(3, 4, eventObj)
	self.entityInputRequestPool:incrementCurrentIndex()
end

----------------
--Return module:
----------------

return EntityCombatSystem