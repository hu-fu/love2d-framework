return {
	header = {
		id = 1,
		
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
	},
	
	footer = {
		method = function(self, system, player)
			--script on end dialogue
		end
	}
}