--player file

--MAIN MODULE

local id = 1

local name = 'player_1'
	
local x = 1800

local y = 800

local w = 100

local h = 100
	
local spritesheet = love.graphics.newImage("player.png")
	
local spritesheet_quads = {
		{love.graphics.newQuad(0, 0, 100, 100, 1000, 2000), love.graphics.newQuad(100, 0, 100, 100, 1000, 2000), love.graphics.newQuad(200, 0, 100, 100, 1000, 2000), love.graphics.newQuad(300, 0, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(400, 0, 100, 100, 1000, 2000), love.graphics.newQuad(500, 0, 100, 100, 1000, 2000), love.graphics.newQuad(600, 0, 100, 100, 1000, 2000), love.graphics.newQuad(700, 0, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(0, 100, 100, 100, 1000, 2000), love.graphics.newQuad(100, 100, 100, 100, 1000, 2000), love.graphics.newQuad(200, 100, 100, 100, 1000, 2000), love.graphics.newQuad(300, 100, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(400, 100, 100, 100, 1000, 2000), love.graphics.newQuad(500, 100, 100, 100, 1000, 2000), love.graphics.newQuad(600, 100, 100, 100, 1000, 2000), love.graphics.newQuad(700, 100, 100, 100, 1000, 2000)},	
		{love.graphics.newQuad(0, 1000, 100, 100, 1000, 2000), love.graphics.newQuad(100, 1000, 100, 100, 1000, 2000), love.graphics.newQuad(200, 1000, 100, 100, 1000, 2000), love.graphics.newQuad(300, 1000, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(400, 1000, 100, 100, 1000, 2000), love.graphics.newQuad(500, 1000, 100, 100, 1000, 2000), love.graphics.newQuad(600, 1000, 100, 100, 1000, 2000), love.graphics.newQuad(700, 1000, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(0, 1100, 100, 100, 1000, 2000), love.graphics.newQuad(100, 1100, 100, 100, 1000, 2000), love.graphics.newQuad(200, 1100, 100, 100, 1000, 2000), love.graphics.newQuad(300, 1100, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(400, 1100, 100, 100, 1000, 2000), love.graphics.newQuad(500, 1100, 100, 100, 1000, 2000), love.graphics.newQuad(600, 1100, 100, 100, 1000, 2000), love.graphics.newQuad(700, 1100, 100, 100, 1000, 2000)},		
	
		{love.graphics.newQuad(0, 200, 100, 100, 1000, 2000), love.graphics.newQuad(100, 200, 100, 100, 1000, 2000), love.graphics.newQuad(200, 200, 100, 100, 1000, 2000), love.graphics.newQuad(300, 200, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(0, 200, 100, 100, 1000, 2000), love.graphics.newQuad(100, 200, 100, 100, 1000, 2000), love.graphics.newQuad(200, 200, 100, 100, 1000, 2000), love.graphics.newQuad(300, 200, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(0, 200, 100, 100, 1000, 2000), love.graphics.newQuad(100, 200, 100, 100, 1000, 2000), love.graphics.newQuad(200, 200, 100, 100, 1000, 2000), love.graphics.newQuad(300, 200, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(0, 200, 100, 100, 1000, 2000), love.graphics.newQuad(100, 200, 100, 100, 1000, 2000), love.graphics.newQuad(200, 200, 100, 100, 1000, 2000), love.graphics.newQuad(300, 200, 100, 100, 1000, 2000)},	
		{love.graphics.newQuad(0, 200, 100, 100, 1000, 2000), love.graphics.newQuad(100, 200, 100, 100, 1000, 2000), love.graphics.newQuad(200, 200, 100, 100, 1000, 2000), love.graphics.newQuad(300, 200, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(0, 200, 100, 100, 1000, 2000), love.graphics.newQuad(100, 200, 100, 100, 1000, 2000), love.graphics.newQuad(200, 200, 100, 100, 1000, 2000), love.graphics.newQuad(300, 200, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(0, 200, 100, 100, 1000, 2000), love.graphics.newQuad(100, 200, 100, 100, 1000, 2000), love.graphics.newQuad(200, 200, 100, 100, 1000, 2000), love.graphics.newQuad(300, 200, 100, 100, 1000, 2000)},
		{love.graphics.newQuad(0, 200, 100, 100, 1000, 2000), love.graphics.newQuad(100, 200, 100, 100, 1000, 2000), love.graphics.newQuad(200, 200, 100, 100, 1000, 2000), love.graphics.newQuad(300, 200, 100, 100, 1000, 2000)}		
	}

local player = player.new(id, name, x, y, w, h, spritesheet, spritesheet_quads)

--IDLE MODULE

local idle_id = id

local idle_name = 'pl_idle'

local idle_timer = 0.9

local idle_ani_change = {0.3, 0.6}

local idle_spritesheet = love.graphics.newImage("idle.png")

local idle_spritesheet_quads = {
		{love.graphics.newQuad(0, 0, 100, 100, 600, 400), love.graphics.newQuad(100, 0, 100, 100, 600, 400), love.graphics.newQuad(200, 0, 100, 100, 600, 400)},
		{love.graphics.newQuad(300, 0, 100, 100, 600, 400), love.graphics.newQuad(400, 0, 100, 100, 600, 400), love.graphics.newQuad(500, 0, 100, 100, 600, 400)},
		{love.graphics.newQuad(0, 100, 100, 100, 600, 400), love.graphics.newQuad(100, 100, 100, 100, 600, 400), love.graphics.newQuad(200, 100, 100, 100, 600, 400)},
		{love.graphics.newQuad(300, 100, 100, 100, 600, 400), love.graphics.newQuad(400, 100, 100, 100, 600, 400), love.graphics.newQuad(500, 100, 100, 100, 600, 400)},
		{love.graphics.newQuad(0, 200, 100, 100, 600, 400), love.graphics.newQuad(100, 200, 100, 100, 600, 400), love.graphics.newQuad(200, 200, 100, 100, 600, 400)},
		{love.graphics.newQuad(300, 200, 100, 100, 600, 400), love.graphics.newQuad(400, 200, 100, 100, 600, 400), love.graphics.newQuad(500, 200, 100, 100, 600, 400)},
		{love.graphics.newQuad(0, 300, 100, 100, 600, 400), love.graphics.newQuad(100, 300, 100, 100, 600, 400), love.graphics.newQuad(200, 300, 100, 100, 600, 400)},
		{love.graphics.newQuad(300, 300, 100, 100, 600, 400), love.graphics.newQuad(400, 300, 100, 100, 600, 400), love.graphics.newQuad(500, 300, 100, 100, 600, 400)}
	}

local idle_sprite_adjust = {
	{0, 0},
	{0, 0},
	{0, 0},
	{0, 0},
	{0, 0},
	{0, 0},
	{0, 0},
	{0, 0}
}

local idle = idle.new(idle_id, idle_name, idle_timer, idle_ani_change, idle_spritesheet, idle_spritesheet_quads, idle_sprite_adjust)

--MOVEMENT MODULE

local mov_id = id

local mov_name = 'pl_movement'
	
local movement = movement.new(mov_id, mov_name)
	movement.active_type = MOVEMENT_TYPE['VELOCITY']

local vel = 350.0

local ani_cycle = 12

local ani_cycle_divider = 4

local mov_vel = mov_vel.new(id, vel, ani_cycle, ani_cycle_divider)

local mov_vec = mov_vec.new(id, vel/100, ani_cycle, ani_cycle_divider)
	mov_vec.itinerary = {rect.new(100,100,100,100), rect.new(0,0,100,100)}

--LOCKON MODULE

local lockon = lockon.new(id, 1)	

--COLLISION MODULE

local collider = collision_module.new (id, 1, 1)

--APPEND

player.idle = idle
idle.entity = player

movement.mov_vel = mov_vel
mov_vel.movement = movement

movement.mov_vec = mov_vec
mov_vec.movement = movement

movement:set_mov()

player.movement = movement
movement.entity = player

player.movement.mov[1].box = {player.sprite_box, player.hit_box[1].box}
player.movement.mov[2].box = {player.sprite_box, player.hit_box[1].box}

player.lockon = lockon
lockon.entity = player

player.collider = collider
collider.entity = player

player.collider.box = {player.sprite_box, player.hit_box[1].box}
player.collider.box = {player.sprite_box, player.hit_box[1].box}

player.collider:set_entity_methods()

--RETURN

return {
	player = player
}