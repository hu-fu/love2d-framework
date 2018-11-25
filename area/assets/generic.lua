return {
	--general:
	id = 1,
	tag = 'generic area',
	
	--spatial:
	w = 0,
	h = 0,
	unitWidth = 64,
	unitHeight = 64,
	maxUnitWidth = 32,
	maxUnitHeight = 20,
	minimumNodeWidth = 256,
	minimumNodeHeight = 128,
	nodeSizeMultiplier = 3,
	
	--image:
	backgroundImageId = 1,
	backgroundX = 0,
	backgroundY = -600,
	backgroundXSpeed = 0.5,
	backgroundYSpeed = 0.5,
	foregroundImageId = nil,
	foregroundX = nil,
	foregroundY = nil,
	foregroundXSpeed = 1,
	foregroundYSpeed = 1,
	
	--spawn
	spawn = {
		{id = 'generic_spawn_1', x = 75, y = 75},
		{id = 'generic_spawn_2', x = 500, y = 500}
	}
}