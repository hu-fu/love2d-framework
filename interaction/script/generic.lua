local INTERACTION_ID = require '/interaction/INTERACTION'

return {
	[INTERACTION_ID.GENERIC] = function(interactionSystem, interaction)
		--Interact with object*event proof of concept
			--this starts the EVENT state of caller and target
		
		if #interaction.targets > 0 then
			local target = interaction.targets[1]	--choose closest target with EVENT state
			
			if target.componentTable.event then
				local eventComponent = interaction.origin.componentTable.event
				interactionSystem:requestEventState(eventComponent)
				
				local targetEventComponent = target.componentTable.event
				interactionSystem:requestEventState(targetEventComponent)
			end
		end
	end,
	
	--...
}