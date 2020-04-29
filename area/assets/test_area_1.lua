return {
	--general:
	id = 3,
	tag = 'test_area_1',
	
	--spatial:
	w = 2186,
	h = 5009,
	unitWidth = 64,
	unitHeight = 64,
	maxUnitWidth = 35,
	maxUnitHeight = 79,
	minimumNodeWidth = 256,
	minimumNodeHeight = 128,
	nodeSizeMultiplier = 3,
	
	--image:
	backgroundImageId = 4,
	backgroundX = 0,
	backgroundY = 0,
	backgroundXSpeed = 1,
	backgroundYSpeed = 1,
	foregroundImageId = 5,
	foregroundX = 0,
	foregroundY = 3863,
	foregroundXSpeed = 1,
	foregroundYSpeed = 1,
	
	--scrolling background
	infiniteScrollingBackgroundImageId = nil,
	infiniteScrollingBackgroundX = 0,
	infiniteScrollingBackgroundY = 0,
	infiniteScrollingBackgroundDirection = 3,	--UP/LEFT/DOWN/RIGHT
	infiniteScrollingBackgroundSpeed = 1000,
	infiniteScrollingBackgroundImageWidth = 1024,
	infiniteScrollingBackgroundImageHeight = 654,
	
	--spawn
	spawn = {
		{id = 'generic_spawn_1', x = 400, y = 4000},
		{id = 'generic_spawn_2', x = 400, y = 4000}
	}
}