local ANIMATION = {}

ANIMATION.SET_ID = {
	PLAYER_MAIN = 1,
	PLAYER_B = 2,
	
}

ANIMATION.ANIMATION_ID = {
	[ANIMATION.SET_ID.PLAYER_MAIN] = {
		IDLE = 1,
		WALK = 2,
		ATTACK = 3,
		HIT = 4
		--...
	},
	
	[ANIMATION.SET_ID.PLAYER_B] = {
		IDLE = 1,
		WALK = 2,
		ATTACK = 3,
		HIT = 4
		--...
	},
	
	--...
}

return ANIMATION