------------------------------
--Static Idle System Module:
------------------------------

--[[
~~~~~~~~~~~~~~~*DEPRECATED*~~~~~~~~~~~~~~~~~~

Global system id = 

'staticIdle' component TABLE:
--------------------------------
| PARENT | state | defaultQuad |
--------------------------------
| 1 -> 2 |   3   |      4      |
--------------------------------

State:
false -> inactive
1 - 8 -> active

The quad is pre calculated via the current state vs default quad
send the quad to the spritebox
This can be used with static entities like items
It doesn't need to run()
]]

local PARENT_1 = 1
local SPRITE_BOX_ROW_INDEX = 2
local STATE = 3
local DEFAULT_QUAD = 4

local staticIdleSystem = {}

staticIdleSystem.staticIdleComponentTable = {}
staticIdleSystem.eventDispatcher = nil
staticIdleSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

staticIdleSystem.eventMethods = {
--[listener index] -> associated methods array
	
	[1] = {
		[1] = function(argumentList)
			--start state
			--argumentList = {staticIdleRowIndex, state}
			local staticIdleRow = staticIdleSystem.staticIdleComponentTable.rows[argumentList[1]]
			staticIdleSystem:startState(staticIdleRow, argumentList[2])
		end,
		
		[2] = function(argumentList)
			--end state
			--argumentList = {staticIdleRowIndex}
			local staticIdleRow = staticIdleSystem.staticIdleComponentTable.rows[argumentList[1]]
			staticIdleSystem:setState(staticIdleRow, false)
		end
	}
}

---------------
--Init Methods:
---------------

function staticIdleSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function staticIdleSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function staticIdleSystem:setStaticIdleComponentTable(staticIdleComponentTable)
	self.staticIdleComponentTable = staticIdleComponentTable
end

---------------
--Exec Methods:
---------------

function staticIdleSystem:startState(staticIdleRow, newState)
	self:setState(staticIdleRow, newState)
	self:setSprite(staticIdleRow)
end

function staticIdleSystem:setState(staticIdleRow, newState)
	staticIdleRow[STATE] = newState
end

function staticIdleSystem:setSprite(staticIdleRow)
	--the quad has to be calculated first
	local eventData = {staticIdleRow[SPRITE_BOX_ROW_INDEX], false, staticIdleRow[DEFAULT_QUAD]}
	staticIdleSystem.eventDispatcher:postEvent(1, 2, eventData)
end

----------------
--Return Module:
----------------

return staticIdleSystem