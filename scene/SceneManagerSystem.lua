--[[
1. change scene (scene stack)
2. set scene on systems (area + entity + ...)

load scene (orginal) -> load in-game db struct -> 
	modify original scene file -> distribute to other systems

how the other systems interpret the scene file is of no concern to this system - important
create an area event/scripting/flag system -> can be used for pretty much everything, 
	even sending spawn requests according to flags

...

this should gtfo, the loader takes care of everything
]]

----------------
--Entity system:
----------------

local SceneManagementSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
require '/scene/SceneObjects'
SceneManagementSystem.SCENE = '/scene/SCENE'

-------------------
--System Variables:
-------------------

SceneManagementSystem.id = SYSTEM_ID.SCENE_MANAGER

SceneManagementSystem.sceneStack = nil

----------------
--Event Methods:
----------------

SceneManagementSystem.eventMethods = {
	
	[1] = {
		[1] = function(request)
			
		end
	}
}

---------------
--Init Methods:
---------------

function SceneManagementSystem:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function SceneManagementSystem:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function SceneManagementSystem:buildSceneStack()

end

---------------
--Exec Methods:
---------------

function SceneManagementSystem:changeScene()
	
end

function SceneManagementSystem:initScene()
	
end

