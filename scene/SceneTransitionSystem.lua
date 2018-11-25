--[[
---------------------------------------- START! ----------------------------------------

1. Request to transition scene:
	- sent from the area event system (TODO) or any other bullshit system

2. Area transition areas:
	- generic entity -> role: area event; managed by the area event system
	
4. Area spawn areas (coordinates):
	- Parameters of the area object: {id, x, y}
	
3. Request composition:
	- load scene id
	- entity(ies) that triggered change event
	- area spawn id (this, so much this holy shit)
	
4. Prepare for state change:
	- set trigger entities spawn component .areaSpawnId
	- SAVE AREA + ENTITY DATA TO INGAME DB - very important!!!!
	- sceneInitializer = GameSceneInitializer.new(1)
	- set extra entities on scene initializer (cool idea)
	
5. Stack states: scene load(2), transition(1)
	- stateInitializer = StateInitializer.new(4)
	- stateInitializer = StateInitializer.new(4)
	
6. Transition state run()
	- removes itself from state stack when over

7. Scene Load state run()
	- loads state normally, passes sceneInitializer.areaSpawnId to entity spawn system

8. Entity Spawn System
	- if entity spawn component .areaSpawnId then change (x, y) ; set .areaSpawnId = nil

9. Elevators and other stuff:
	--at area event always check if ROLE: player+elevator/transporter collide with the event area
	--both entities are passed as change event triggers
	--they are both set with the areaSpawnId variable
	--they both spawn @ at the designated spawn point
		--how to set the spawn point for entities of varying sizes?

----------------------------------------- DONE! ----------------------------------------
]]

----------------
--Camera System:
----------------

local SceneTransitionSystem = {}

---------------
--Dependencies:
---------------

require '/camera/CameraObjects'
require '/event/EventObjectPool'
local SYSTEM_ID = require '/system/SYSTEM_ID'
SceneTransitionSystem.EVENT_TYPES = require '/event/EVENT_TYPE'

-------------------
--System Variables:
-------------------

SceneTransitionSystem.id = SYSTEM_ID.SCENE_TRANSITION

SceneTransitionSystem.eventDispatcher = nil
SceneTransitionSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

SceneTransitionSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			
		end,
		
	}
}

---------------
--Init Methods:
---------------

function SceneTransitionSystem:init()
	
end

---------------
--Exec Methods:
---------------



----------------
--Return module:
----------------

return SceneTransitionSystem