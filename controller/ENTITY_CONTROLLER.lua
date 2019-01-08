return {
	['player_generic'] = function()
		require '/controller/entity controller/GenericPlayerController'
		return GenericPlayerController.new()
	end,
	
	--...
}