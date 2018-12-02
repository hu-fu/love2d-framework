-------------------------
--Movement System Module:
-------------------------

--[[
Global system id = 

TODO: needs an upgrade
	sends animation messages every frame - fucking stupid
]]

local entityMovementSystem = {}

---------------
--Dependencies:
---------------

entityMovementSystem.ENTITY_ACTION = require 'ENTITY_ACTION'
entityMovementSystem.EVENT_TYPES = require '/event/EVENT_TYPE'
local SYSTEM_ID = require '/system/SYSTEM_ID'

require 'eventDataObjectPool'
entityMovementSystem.idleRequestPool = eventDataObjectPool.new(2, 
	{'idle row index', 'state'}, 1)
entityMovementSystem.idleRequestPool:buildObjectPool()

entityMovementSystem.animationRequestPool = EventObjectPool.new(entityMovementSystem.EVENT_TYPES.ANIMATION, 100)

-------------------
--Static Variables:
-------------------

-------------------
--System Variables:
-------------------

entityMovementSystem.id = SYSTEM_ID.ENTITY_MOVEMENT

entityMovementSystem.spriteBoxComponentTable = {}
entityMovementSystem.hitBoxComponentTable = {}
entityMovementSystem.entityMovementComponentTable = {}

entityMovementSystem.eventDispatcher = nil
entityMovementSystem.eventListenerList = {}

entityMovementSystem.actionRequestStack = {}

entityMovementSystem.movementObjectRepositoryList = {}

----------------
--Event Methods:
----------------

entityMovementSystem.eventMethods = {
	[1] = {
		[1] = function(movementActionRequest)
			table.insert(entityMovementSystem.actionRequestStack, movementActionRequest)
		end
	}
}

---------------
--Init Methods:
---------------

function entityMovementSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function entityMovementSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function entityMovementSystem:setEntityMovementComponentTable(entityMovementComponentTable)
	self.entityMovementComponentTable = entityMovementComponentTable
end

function entityMovementSystem:setSpriteBoxComponentTable(spriteBoxComponentTable)
	self.spriteBoxComponentTable = spriteBoxComponentTable
end

function entityMovementSystem:setHitBoxComponentTable(hitBoxComponentTable)
	self.hitBoxComponentTable = hitBoxComponentTable
end

function entityMovementSystem:setMovementObjectRepository(id, movementObjectRepository)
	self.movementObjectRepositoryList[id] = movementObjectRepository
end

---------------
--Exec Methods:
---------------

entityMovementSystem.directionMultipliers = {
	[1] = function()
		return 0, -1
	end,
	[2] = function()
		return -1, -1
	end,
	[3] = function()
		return -1, 0
	end,
	[4] = function()
		return -1, 1
	end,
	[5] = function()
		return 0, 1
	end,
	[6] = function()
		return 1, 1
	end,
	[7] = function()
		return 1, 0
	end,
	[8] = function()
		return 1, -1
	end
}

entityMovementSystem.movementActionMethods = {
	--movementActionRequest = {action id, movement row index, direction, x, y, hitbox row index, movement start}
	
	[entityMovementSystem.ENTITY_ACTION.IDLE] = function(dt, actionRequest)
		local movementRow = actionRequest[2]
		local hitBoxRow = actionRequest[6]
		local spriteBoxRow = hitBoxRow.componentTable.spritebox
		entityMovementSystem:resetMovementAnimationCycle(movementRow, spriteBoxRow)
		if spriteBoxRow.componentTable.idle then
			local idleRequest = entityMovementSystem.idleRequestPool:getCurrentAvailableObject()
			idleRequest[1], idleRequest[2] = spriteBoxRow.componentTable.idle, movementRow.direction
			entityMovementSystem.eventDispatcher:postEvent(1, 1, idleRequest)
		end
	end,
	
	[entityMovementSystem.ENTITY_ACTION.MOVE] = function(dt, actionRequest)
		local movementRow = actionRequest[2]
		local hitBoxRow = actionRequest[6]
		local spriteBoxRow = hitBoxRow.componentTable.spritebox
		local x, y = entityMovementSystem:getPositionIncrementValues(dt, movementRow, actionRequest[3])
		
		entityMovementSystem:incrementHitboxPosition(hitBoxRow, x, y)
		entityMovementSystem:incrementSpriteboxPosition(spriteBoxRow, x, y)
		entityMovementSystem:updateMovementAnimationCycle(movementRow, spriteBoxRow)
		entityMovementSystem:updateEntityDirection(movementRow, spriteBoxRow, actionRequest[3])
		
		--update entity on grid spatial request
	end,
	
	[entityMovementSystem.ENTITY_ACTION.MOVE_START] = function (dt, actionRequest)
		local movementRow = actionRequest[2]
		if movementRow.currentTime == 0 then
			local hitBoxRow = actionRequest[6]
			local spriteBoxRow = hitBoxRow.componentTable.spritebox
			entityMovementSystem:resetMovementAnimationCycle(movementRow, spriteBoxRow)
			if spriteBoxRow.componentTable.idle then
				local idleRequest = entityMovementSystem.idleRequestPool:getCurrentAvailableObject()
				idleRequest[1], idleRequest[2] = spriteBoxRow.componentTable.idle, movementRow.direction
				entityMovementSystem.eventDispatcher:postEvent(1, 2, idleRequest)
			end
		end
	end
}

function entityMovementSystem:main(dt)
	self.animationRequestPool:resetCurrentIndex()
	for i=#self.actionRequestStack, 1, -1 do
		self.movementActionMethods[self.actionRequestStack[i][1]](dt, self.actionRequestStack[i])
		table.remove(self.actionRequestStack)
	end
end

function entityMovementSystem:getPositionIncrementValues(dt, movementRow, direction)
	local xMultiplier, yMultiplier = self.directionMultipliers[direction]()
	local x = math.floor(movementRow.velocity*dt)
	local y = x
	x, y = x*xMultiplier, y*yMultiplier
	return x, y
end

function entityMovementSystem:incrementHitboxPosition(hitBoxRow, x, y)
	hitBoxRow.x = hitBoxRow.x + x
	hitBoxRow.y = hitBoxRow.y + y
end

function entityMovementSystem:setHitboxPosition(hitBoxRow, x, y)
	hitBoxRow.x = x
	hitBoxRow.y = y
end

function entityMovementSystem:incrementSpriteboxPosition(spriteBoxRow, x, y)
	spriteBoxRow.x = spriteBoxRow.x + x
	spriteBoxRow.y = spriteBoxRow.y + y
end

function entityMovementSystem:setSpriteboxPosition(spriteBoxRow, x, y)
	spriteBoxRow.x = x
	spriteBoxRow.y = y
end

function entityMovementSystem:getCurrentAnimationQuadIndex(movementRow)
	--return movementRow.defaultQuad + (movementRow.direction - 1)*
	--	(movementRow.totalTime/movementRow.frequency) + 
	--	math.floor(movementRow.updatePoint/movementRow.frequency) - 1
end

function entityMovementSystem:getInitialAnimationQuadIndex(movementRow)
	--return movementRow.defaultQuad + (movementRow.direction - 1)*
	--	(movementRow.totalTime/movementRow.frequency)
end

function entityMovementSystem:setCurrentAnimationQuad(spriteBoxRow, quadIndex)
	--spriteBoxRow.quad = quadIndex
end

function entityMovementSystem:incrementCurrentAnimationQuad(spriteBoxRow)
	--spriteBoxRow.quad = spriteBoxRow.quad + 1
end

function entityMovementSystem:resetMovementAnimationCycle(movementRow, spriteboxRow)
	--send 'start animation' request to animation system
	
	local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
	animationRequest.animationSetId = movementRow.animationSetId
	animationRequest.animationId = movementRow.animationId
	animationRequest.spritebox = spriteboxRow
	
	self.eventDispatcher:postEvent(2, 2, animationRequest)
	self.animationRequestPool:incrementCurrentIndex()
	
	--[[
	movementRow.currentTime = 0
	movementRow.updatePoint = movementRow.frequency
	self:setCurrentAnimationQuad(spriteBoxRow, self:getInitialAnimationQuadIndex(movementRow))
	]]
end

function entityMovementSystem:updateMovementAnimationCycle(movementRow, spriteBoxRow)
	--send 'refresh animation' request to animation system
	
	local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
	animationRequest.spritebox = spriteBoxRow
	
	self.eventDispatcher:postEvent(2, 3, animationRequest)
	self.animationRequestPool:incrementCurrentIndex()
	
	--[[
	movementRow.currentTime = movementRow.currentTime + 1
	
	if movementRow.currentTime >= movementRow.updatePoint then
		if movementRow.currentTime == movementRow.totalTime then
			self:resetMovementAnimationCycle(movementRow, spriteBoxRow)
			return
		end
		movementRow.updatePoint = movementRow.updatePoint + movementRow.frequency
		self:incrementCurrentAnimationQuad(spriteBoxRow)
	end
	]]
end

function entityMovementSystem:updateEntityDirection(movementRow, spriteBoxRow, newDirection)
	if movementRow.direction ~= newDirection then
		movementRow.direction = newDirection
		--self:setCurrentAnimationQuad(spriteBoxRow, self:getCurrentAnimationQuadIndex(movementRow))
	end
end

----------------
--Return Module:
----------------

return entityMovementSystem