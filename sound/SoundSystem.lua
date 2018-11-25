---------------
--Sound System:
---------------
--BGM and SFX - on same system please

local SoundSystem = {}

---------------
--Dependencies:
---------------

-------------------
--System Variables:
-------------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
SoundSystem.id = SYSTEM_ID.SOUND

SoundSystem.eventDispatcher = nil
SoundSystem.eventListenerList = {}

----------------
--Event Methods:
----------------

SoundSystem.eventMethods = {

	[1] = {
		[1] = function(request)
			
		end,
		
	}
}

---------------
--Init Methods:
---------------

function SoundSystem:init()

end

---------------
--Exec Methods:
---------------

----------------
--Return Module:
----------------

return SoundSystem