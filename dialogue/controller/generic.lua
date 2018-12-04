local DIALOGUE = require '/dialogue/DIALOGUE'
local LINE_TYPE = require '/dialogue/LINE_TYPE'

return {
	header = {
		id = DIALOGUE.GENERIC.id,
		
		method = function(self, system, player, component)
			--script on start dialogue
		end
	},
	
	body = {
		--append custom behavior to lines
		
		{
			line = 3,
			lineId = "choice_1",
			
			method = function(self, system, player, component)
				
			end
		}
	}
	
	footer = {
		method = function(self, system, player, component)
			--script on end dialogue
		end
	}
}