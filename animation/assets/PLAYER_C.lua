local ANIMATIONS = require '/animation/ANIMATION'
local SET_ID = ANIMATIONS.SET_ID.PLAYER_C

return {
	[ANIMATIONS.ANIMATION_ID[SET_ID].IDLE] = {
		id = 1,
		spritesheetId = 24,
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
		spritesheetId = 24,
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
			UP = {9, 10, 11, 10},			--{quad number, ...}
			UP_LEFT = {12, 13, 14, 13},
			LEFT = {15, 16, 17, 16},
			DOWN_LEFT = {18, 19, 20, 19},
			DOWN = {21, 22, 23, 22},
			DOWN_RIGHT = {24, 25, 26, 25},
			RIGHT = {27, 28, 29, 28},
			UP_RIGHT = {30, 31, 32, 31}
		}
	},
	
	[ANIMATIONS.ANIMATION_ID[SET_ID].ATTACK] = {
		id = 3,
		spritesheetId = 24,
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
	
	[ANIMATIONS.ANIMATION_ID[SET_ID].HIT] = {
		id = 4,
		spritesheetId = 24,
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
	}
}