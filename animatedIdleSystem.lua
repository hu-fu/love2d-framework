------------------------------
--Animated Idle System Module:
------------------------------

--[[
Global system id = 

spriteAnimationId = id of animation object on the animation repository
T = total state time
t = current state time (default = 0)
f = animation update frequency
UT = update point (default = 0)

State:
false -> inactive
1 - 8 (direction) -> active

should just be 'IdleSystem'
]]

local animatedIdleSystem = {}

---------------
--Dependencies:
---------------

require 'eventDataObjectPool'
require '/event/EventObjectPool'
require '/event/EventObjectStack'
local SYSTEM_ID = require '/system/SYSTEM_ID'

--[[
animatedIdleSystem.animationRequestPool = eventDataObjectPool.new(5, 
	{'spritebox row', 'spritesheetId', 'quad', 'spriteAnimationId', 'interval'}, 6)
animatedIdleSystem.animationRequestPool:buildObjectPool()
]]

animatedIdleSystem.EVENT_TYPES = require '/event/EVENT_TYPE'

animatedIdleSystem.animationRequestPool = EventObjectPool.new(animatedIdleSystem.EVENT_TYPES.ANIMATION, 100)
animatedIdleSystem.eventObjectStack = EventObjectStack.new() --TODO: use this

-------------------
--Static Variables:
-------------------

-------------------
--System Variables:
-------------------

animatedIdleSystem.id = SYSTEM_ID.IDLE

animatedIdleSystem.animatedIdleComponentTable = {}

animatedIdleSystem.eventDispatcher = nil
animatedIdleSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

animatedIdleSystem.eventMethods = {
	--idleRequest = {animatedIdleRowIndex, state}
	
	[1] = {
		[1] = function(idleRequest)
			--start state
			animatedIdleSystem:startState(idleRequest[1], idleRequest[2])
		end,
		
		[2] = function(idleRequest)
			--end state
			animatedIdleSystem:endState(idleRequest[1])
		end,
		
		[3] = function(idleRequest)
			--update state
			animatedIdleSystem:updateAnimation(idleRequest[1])
		end
	}
}

---------------
--Init Methods:
---------------

function animatedIdleSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function animatedIdleSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function animatedIdleSystem:setAnimatedIdleComponentTable(animatedIdleComponentTable)
	self.animatedIdleComponentTable = animatedIdleComponentTable
end

---------------
--Exec Methods:
---------------

function animatedIdleSystem:main(dt)
	self.animationRequestPool:resetCurrentIndex()
	for i=1, #self.animatedIdleComponentTable do
		if self.animatedIdleComponentTable[i].state then
			self:runState(self.animatedIdleComponentTable[i], dt)
		end
	end
end

function animatedIdleSystem:startState(animatedIdleRow, newState)
	self:setState(animatedIdleRow, newState)
	self:startAnimation(animatedIdleRow, newState)
	--self:resetTimer(animatedIdleRow)
	--self:updateAnimation(animatedIdleRow)
end

function animatedIdleSystem:endState(animatedIdleRow)
	--self:resetTimer(animatedIdleRow)
	self:setState(animatedIdleRow, false)
end

function animatedIdleSystem:resetState(animatedIdleRow)
	--self:startAnimation(animatedIdleRow)
	--self:resetTimer(animatedIdleRow)
	self:updateAnimation(animatedIdleRow)
end

function animatedIdleSystem:startAnimation(animatedIdleRow)
	local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
	animationRequest.animationSetId = animatedIdleRow.animationSetId
	animationRequest.animationId = animatedIdleRow.animationId
	animationRequest.spritebox = animatedIdleRow.componentTable.spritebox
	
	self.eventDispatcher:postEvent(1, 2, animationRequest)
	self.animationRequestPool:incrementCurrentIndex()
	
	--[[
	local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
	animationRequest[1], animationRequest[2], animationRequest[3] = 
		animatedIdleRow.componentTable.spritebox, false, 
			animatedIdleRow.defaultQuad + (animatedIdleRow.state - 1) * (animatedIdleRow.totalTime/animatedIdleRow.frequency)
	self.eventDispatcher:postEvent(1, 2, animationRequest)
	self.animationRequestPool:incrementCurrentIndex()
	]]
end

function animatedIdleSystem:runState(animatedIdleRow, dt)
	--no need for a main() method? absoulte genius lol
	
	--[[
	animatedIdleRow.currentTime = animatedIdleRow.currentTime + dt
	
	if animatedIdleRow.currentTime >= animatedIdleRow.totalTime then
		self:resetState(animatedIdleRow)
	end
	
	if animatedIdleRow.currentTime >= animatedIdleRow.updatePoint then
		self:updateAnimation(animatedIdleRow)
	end
	]]
end

function animatedIdleSystem:updateAnimation(animatedIdleRow)
	local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
	animationRequest.spritebox = animatedIdleRow.componentTable.spritebox
	
	self.eventDispatcher:postEvent(1, 3, animationRequest)
	self.animationRequestPool:incrementCurrentIndex()
	
	--[[
	local updateInterval = self:getCurrentUpdateInterval(animatedIdleRow)
	self:setNewUpdatePoint(animatedIdleRow)
	
	local animationRequest = self.animationRequestPool:getCurrentAvailableObject()
	animationRequest[1], animationRequest[4], animationRequest[5] = 
		animatedIdleRow.componentTable.spritebox, animatedIdleRow.spriteAnimationId, updateInterval
	self.eventDispatcher:postEvent(1, 1, animationRequest)
	self.animationRequestPool:incrementCurrentIndex()
	]]
end

function animatedIdleSystem:setState(animatedIdleRow, newState)
	animatedIdleRow.state = newState
end

function animatedIdleSystem:setNewUpdatePoint(animatedIdleRow)
	--animatedIdleRow.updatePoint = animatedIdleRow.updatePoint + animatedIdleRow.frequency
end

function animatedIdleSystem:getCurrentUpdateInterval(animatedIdleRow)
	--float to int conversion (as in 0.2 = 2);
	--I don't like this
	--return animatedIdleRow.updatePoint*10
end

function animatedIdleSystem:resetTimer(animatedIdleRow)
	--animatedIdleRow.currentTime = 0
	--animatedIdleRow.updatePoint = 0
end

----------------
--Return Module:
----------------

return animatedIdleSystem