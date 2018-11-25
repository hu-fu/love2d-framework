local ANIMATIONS = require '/animation/ANIMATION'
local SET_ID = ANIMATIONS.SET_ID.PLAYER_MAIN

return {
	[ANIMATIONS.ANIMATION_ID[SET_ID].IDLE] = {
		id = 1,
		spritesheetId = 2,
		totalTime = 0.6,
		frameUpdates = {
			{
				updateTime = 0.3,
				frameIndex = 1		--end time
			},
			{
				updateTime = 0.6,
				frameIndex = 2
			}
		},
		replay = true,
		
		quads = {
			UP = {33, 34},			--{quad number, ...}
			UP_LEFT = {35, 36},
			LEFT = {37, 38},
			DOWN_LEFT = {39, 40},
			DOWN = {41, 42},
			DOWN_RIGHT = {43, 44},
			RIGHT = {45, 46},
			UP_RIGHT = {47, 48}
		}
	},
	
	[ANIMATIONS.ANIMATION_ID[SET_ID].WALK] = {
		id = 2,
		spritesheetId = 2,
		totalTime = 0.3,
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
				updateTime = 0.3,
				frameIndex = 3
			}
		},
		replay = true,
		
		quads = {
			UP = {9, 10, 11},			--{quad number, ...}
			UP_LEFT = {12, 13, 14},
			LEFT = {15, 16, 17},
			DOWN_LEFT = {18, 19, 20},
			DOWN = {21, 22, 23},
			DOWN_RIGHT = {24, 25, 26},
			RIGHT = {27, 28, 29},
			UP_RIGHT = {30, 31, 32}
		}
	},
	
	[ANIMATIONS.ANIMATION_ID[SET_ID].ATTACK] = {
		id = 3,
		spritesheetId = 2,
		totalTime = 0.3,
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
				updateTime = 0.3,
				frameIndex = 3
			}
		},
		replay = false,
		
		quads = {
			UP = {52, 53, 54},
			UP_LEFT = {49, 50, 51},
			LEFT = {70, 71, 72},
			DOWN_LEFT = {67, 68, 69},
			DOWN = {64, 65, 66},
			DOWN_RIGHT = {61, 62, 63},
			RIGHT = {58, 59, 60},
			UP_RIGHT = {55, 56, 57}
		}
	},
	
	[ANIMATIONS.ANIMATION_ID[SET_ID].HIT] = {
		id = 4,
		spritesheetId = 2,
		totalTime = 0.1,
		frameUpdates = {
			{
				updateTime = 0.0,
				frameIndex = 1
			}
		},
		replay = true,
		
		quads = {
			UP = {74},
			UP_LEFT = {73},
			LEFT = {80},
			DOWN_LEFT = {79},
			DOWN = {78},
			DOWN_RIGHT = {77},
			RIGHT = {76},
			UP_RIGHT = {75}
		}
	}
}