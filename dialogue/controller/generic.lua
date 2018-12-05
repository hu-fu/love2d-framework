local DIALOGUE = require '/dialogue/DIALOGUE'

return {
	header = {
		id = DIALOGUE.GENERIC.id,
		
		method = function(self, system, player)
			--script on start dialogue
		end
	},
	
	body = {
		--append custom behavior to lines
		
		{
			lineId = "choice_1",
			
			method = function(self, system, player)
				
			end
		}
	}
	
	footer = {
		method = function(self, system, player)
			--script on end dialogue
		end
	}
}