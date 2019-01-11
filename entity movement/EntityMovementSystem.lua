-------------------------
--Entity Movement System:
-------------------------

local EntityMovementSystem = {}

---------------
--Dependencies:
---------------

require '/event/EventObjectPool'
local SYSTEM_ID = require '/system/SYSTEM_ID'
EntityMovementSystem.EVENT_TYPES = require '/event/EVENT_TYPE'
EntityMovementSystem.ENTITY_TYPE = require '/entity/ENTITY_TYPE'
EntityMovementSystem.ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
EntityMovementSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
EntityMovementSystem.ENTITY_DIRECTION = require '/entity state/ENTITY_DIRECTION'
EntityMovementSystem.MOVEMENT_REQUEST = require '/entity movement/MOVEMENT_REQUEST'

-------------------
--System Variables:
-------------------

EntityMovementSystem.id = SYSTEM_ID.ENTITY_MOVEMENT

EntityMovementSystem.animationRequestPool = EventObjectPool.new(EntityMovementSystem.EVENT_TYPES.ANIMATION, 100)

EntityMovementSystem.movementComponentTable = {}
EntityMovementSystem.requestStack = {}

----------------
--Event Methods:
----------------

EntityMovementSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--set entity component table (request.entityDb)
			EntityMovementSystem:setMovementComponentTable(request.entityDb)
		end,
		
		[2] = function(request)
			--request into stack
			EntityMovementSystem:addRequestToStack(request)
		end
	}
}

---------------
--Init Methods:
---------------

function EntityMovementSystem:setMovementComponentTable(entityDb)
	self.movementComponentTable = entityDb:getComponentTable(self.ENTITY_TYPE.GENERIC_ENTITY, 
		self.ENTITY_COMPONENT.MOVEMENT)
end

function EntityMovementSystem:init()
	
end

---------------
--Exec Methods:
---------------

function EntityMovementSystem:update(dt)
	self:resolveRequestStack()
	
	for i=1, #self.movementComponentTable do
		if self.movementComponentTable[i].state then
			self:moveEntity(dt, self.movementComponentTable[i])
		end
	end
	
	self.animationRequestPool:resetCurrentIndex()
end

function EntityMovementSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function EntityMovementSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function EntityMovementSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function EntityMovementSystem:resolveRequest(request)
	self.resolveRequestMethods[request.requestType](self, request)
end

EntityMovementSystem.resolveRequestMethods = {
	[EntityMovementSystem.MOVEMENT_REQUEST.START_MOVEMENT] = function(self, request)
		self:startMovement(request.movementComponent)
	end,
	
	[EntityMovementSystem.MOVEMENT_REQUEST.STOP_MOVEMENT] = function(self, request)
		self:stopMovement(request.movementComponent)
	end,
	
	[EntityMovementSystem.MOVEMENT_REQUEST.UPDATE_MOVEMENT] = function(self, request)
		--needed? not if the rotation is set in the controllers (not needed)
	end,
	
	[EntityMovementSystem.MOVEMENT_REQUEST.INCREMENT_POSITION] = function(self, request)
		self:incrementEntityPosition(request.movementComponent, request.x, request.y)
	end,
	
	[EntityMovementSystem.MOVEMENT_REQUEST.SET_POSITION] = function(self, request)
		self:setEntityPosition(request.movementComponent, request.x, request.y)
	end,
	
	[EntityMovementSystem.MOVEMENT_REQUEST.START_MOVEMENT_CUSTOM] = function(self, request)
		if request.animationSetId then
			self:startMovementCustom(request.movementComponent, request.animationSetId, request.animationId)
		else
			self:startMovement(request.movementComponent)
		end
	end,
	
	[EntityMovementSystem.MOVEMENT_REQUEST.STOP_MOVEMENT_CUSTOM] = function(self, request)
		--same as stop movement
	end,
	
	[EntityMovementSystem.MOVEMENT_REQUEST.RESET_MOVEMENT] = function(self, request)
		self:resetMovement(request.movementComponent)
	end,
	
	[EntityMovementSystem.MOVEMENT_REQUEST.RESET_MOVEMENT_CUSTOM] = function(self, request)
		if request.animationSetId then
			self:resetMovementCustom(request.movementComponent, request.animationSetId, request.animationId)
		else
			self:resetMovement(request.movementComponent)
		end
	end,
}

function EntityMovementSystem:resetMovement(movementComponent)
	if movementComponent.state then
		self:startMovement(movementComponent)
	end
end

function EntityMovementSystem:resetMovementCustom(movementComponent, actionSetId, actionId)
	if movementComponent.state then
		self:startMovementCustom(movementComponent, actionSetId, actionId)
	end
end

function EntityMovementSystem:startMovementCustom(movementComponent, animationSetId, animationId)
	movementComponent.state = true
	movementComponent.animationSetId = animationSetId
	movementComponent.animationId = animationId
	self:startAnimation(movementComponent)
end

function EntityMovementSystem:startMovement(movementComponent)
	movementComponent.state = true
	movementComponent.animationSetId = movementComponent.defaultAnimationSetId
	movementComponent.animationId = movementComponent.defaultAnimationId
	self:startAnimation(movementComponent)
end

function EntityMovementSystem:updateMovement(movementComponent)
	--not needed?
end

function EntityMovementSystem:stopMovement(movementComponent)
	movementComponent.state = false
	self:stopAnimation(movementComponent)
end

function EntityMovementSystem:moveEntity(dt, movementComponent)
	local vel = movementComponent.velocity*dt
	local x, y = math.cos(movementComponent.rotation)*vel, math.sin(movementComponent.rotation)*vel
	local spritebox, hitbox = movementComponent.componentTable.spritebox,
		movementComponent.componentTable.hitbox
	
	spritebox.direction = self.ENTITY_DIRECTION:getDirection(movementComponent.rotation)
	spritebox.x, spritebox.y = spritebox.x + x, spritebox.y - y
	hitbox.x, hitbox.y = hitbox.x + x, hitbox.y - y
end

function EntityMovementSystem:incrementEntityPosition(movementComponent, x, y)
	local spritebox, hitbox = movementComponent.componentTable.spritebox,
		movementComponent.componentTable.hitbox
	
	spritebox.x, spritebox.y = spritebox.x + x, spritebox.y + y
	hitbox.x, hitbox.y = hitbox.x + x, hitbox.y + y
end

function EntityMovementSystem:setEntityPosition(movementComponent, x, y)
	local spritebox, hitbox = movementComponent.componentTable.spritebox,
		movementComponent.componentTable.hitbox
	
	spritebox.direction = self.ENTITY_DIRECTION:getDirection(movementComponent.rotation)
	spritebox.x, spritebox.y = x, y
	hitbox.x, hitbox.y = x, y
end

function EntityMovementSystem:startAnimation(movementComponent)
	local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
	animationRequest.animationSetId = movementComponent.animationSetId
	animationRequest.animationId = movementComponent.animationId
	animationRequest.spritebox = movementComponent.componentTable.spritebox
	
	self.eventDispatcher:postEvent(2, 2, animationRequest)
	self.animationRequestPool:incrementCurrentIndex()
end

function EntityMovementSystem:refreshAnimation(movementComponent)
	--direction is updated in the spritebox every frame, so this isn't needed
end

function EntityMovementSystem:stopAnimation(movementComponent)
	--not even needed rofl
end

function EntityMovementSystem:resetToDefaultAnimation(movementComponent)
	movementComponent.animationSetId = movementComponent.defaultAnimationSetId
	movementComponent.animationId = movementComponent.defaultAnimationId
end

----------------
--Return module:
----------------

return EntityMovementSystem