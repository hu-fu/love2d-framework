local ANIMATIONS = require '/animation/ANIMATION'
local SET_ID = ANIMATIONS.SET_ID.PLAYER_B

return {
	[ANIMATIONS.ANIMATION_ID[SET_ID].IDLE] = {
		id = 1,
		spritesheetId = 11,
		totalTime = 0.1,
		frameUpdates = {
			{
				updateTime = 0.1,
				frameIndex = 1
			},
		},
		replay = true,
		
		quads = {
			UP = {1},			--{quad number, ...}
			UP_LEFT = {2},
			LEFT = {3},
			DOWN_LEFT = {4},
			DOWN = {5},
			DOWN_RIGHT = {6},
			RIGHT = {7},
			UP_RIGHT = {8}
		}
	},
	
	[ANIMATIONS.ANIMATION_ID[SET_ID].WALK] = {
		id = 2,
		spritesheetId = 11,
		totalTime = 0.35,
		frameUpdates = {
			{
				updateTime = 0.1,
				frameIndex = 1
			},
			{
				updateTime = 0.2,
				frameIndex = 2
			},
			{
				updateTime = 0.25,
				frameIndex = 3
			},
		},
		replay = true,
		
		quads = {
			UP = {10, 9, 11, 9},			--{quad number, ...}
			UP_LEFT = {13, 12, 14, 12},
			LEFT = {16, 15, 17, 15},
			DOWN_LEFT = {19, 18, 20, 18},
			DOWN = {22, 21, 23, 21},
			DOWN_RIGHT = {25, 24, 26, 24},
			RIGHT = {28, 27, 29, 27},
			UP_RIGHT = {31, 30, 32, 30}
		}
	},
	
	[ANIMATIONS.ANIMATION_ID[SET_ID].ATTACK] = {
		id = 3,
		spritesheetId = 11,
		totalTime = 0.1,
		frameUpdates = {
			
		},
		replay = false,
		
		quads = {
			UP = {1},			--{quad number, ...}
			UP_LEFT = {2},
			LEFT = {3},
			DOWN_LEFT = {4},
			DOWN = {5},
			DOWN_RIGHT = {6},
			RIGHT = {7},
			UP_RIGHT = {8}
		}
	},
	
	[ANIMATIONS.ANIMATION_ID[SET_ID].HIT] = {
		id = 4,
		spritesheetId = 11,
		totalTime = 0.1,
		frameUpdates = {
			
		},
		replay = true,
		
		quads = {
			UP = {1},			--{quad number, ...}
			UP_LEFT = {2},
			LEFT = {3},
			DOWN_LEFT = {4},
			DOWN = {5},
			DOWN_RIGHT = {6},
			RIGHT = {7},
			UP_RIGHT = {8}
		}
	}
}