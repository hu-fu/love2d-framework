--level file

local name = "TEST_MAP1"

local collision_list = {
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,2,2,2,2,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,2,2,2,2,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,2,2,2,2,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,2,2,2,2,2,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,2,1,1,1,2,2,2,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,2,1,1,1,2,1,2,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
	}
	
local texture_list = {
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,2,2,2,2,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,2,2,2,2,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,2,2,2,2,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,2,2,2,2,2,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,2,1,1,1,2,2,2,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,2,1,1,1,2,1,2,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1},
		{1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
	}

local max_x = 2048
local max_y = 1280

local tile_w = 64
local tile_h = 64
	
local tileset = love.graphics.newImage("bricks.png")
	
local tileset_quads = {
	love.graphics.newQuad(0, 0, 64, 64, 128, 64),
	love.graphics.newQuad(64, 0, 64, 64, 128, 64)
}

local map = map.new(max_x, max_y, tile_w, tile_h, tileset, tileset_quads, collision_list, texture_list)

--RETURN:

return {
	map = map
}