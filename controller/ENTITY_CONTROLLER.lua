return {
	['player_generic'] = function()
		require '/controller/entity controller/GenericPlayerController'
		return GenericPlayerController.new()
	end,
	
	['entity_generic'] = function()
		require '/controller/entity controller/EntityController'
		return EntityController.new()
	end,
	
	--...
}