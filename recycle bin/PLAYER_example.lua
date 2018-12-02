require 'combat'
require 'idle'
require 'lockon'
require 'movement'
require 'rects'

------------------
--PL_ACTIVE (LV1):
------------------

PL_ACTIVE = {['DISABLED'] = false, ['ENABLED'] = true}

-----------------
--PL_STATE (LV2):
-----------------

PL_STATE = {['IDLE'] = 1, ['MOVE'] = 2, ['SP_MOVE'] = 3, ['WEAPON_1'] = 4, ['WEAPON_2'] = 5, 
['WEAPON_3'] = 6}

---------------
--player class:
---------------

player = {}
player.__index = player

setmetatable(player, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function player.new (id, name, x, y, w, h, spritesheet, spritesheet_quads)
	local self = setmetatable ({}, player)
		
		--database identification
		self.id = id
		self.name = name
		
		--box (has to be modified to accept different values for each box)
		self.sprite_box = rect.new(x, y, w, h)
		self.hit_box = {hitbox_rect.new(id, self, x, y, w, h, 1, true, true, true)}	--should be done in the constructor
		self.attack_box = rect.new(x, y, w, w)	--used for attack hitbox placement
		self.central_hitbox_index = 1	--self.hit_box[central_hitbox_index] is the central entity hitbox (try to default to 1)
		
		--sprites for idle/move
		self.spritesheet = spritesheet
		self.spritesheet_quads = spritesheet_quads
		
		--camera module
		self.camera = nil
		self.is_visible = true
		
		--movement module
		self.movement = nil
		
		--special move module
		self.sp_move = nil
		
		--lockon module
		self.lockon = nil
		
		--equipment/attack module
		self.weapon_1 = nil
		self.weapon_2 = nil
		self.weapon_3 = nil
		self.active_attack = nil	--attack being executed (find an alternative to this)
		
		--control/state management
		self.active = PL_ACTIVE['ENABLED']
		self.state = PL_STATE['IDLE']
		self.direction = MOVEMENT_DIRECTION['UP']
		
		--action management
		self.action_timer = 0
		self.action_timer_stop = 0
		
		--collision module
		self.collider = nil
		
	return self
end

function player:handle_key_press (key)
--PROTOTYPE

	if self.state == PL_STATE['MOVE'] or self.state == PL_STATE['IDLE'] then
	
		--MOVE
		if key == 'up' then
			self.movement.mov[self.movement.active_type]:decrease_y()
		elseif key == 'left' then
			self.movement.mov[self.movement.active_type]:decrease_x()
		elseif key == 'down' then
			self.movement.mov[self.movement.active_type]:increase_y()
		elseif key == 'right' then
			self.movement.mov[self.movement.active_type]:increase_x()

		--SP_MOVE
		elseif key == 'lshift' and self.is_moving_check() == true then
			--self:dodge()

		--WEAPON_1
		elseif key == 'z' then
			--check additional stuff here, like combo number or dodge active
			self:attack(self.weapon_1.attack_1, PL_STATE['WEAPON_1']) --go to self:attack
		
		elseif key == 't' then
			if self.lockon.state == false then
				self.lockon.state = true
			elseif self.lockon.state == true then
				self.lockon.state = false
			end

		end
		
		self:set_move()
	end
end

function player:handle_key_release (key)

	if self.state == PL_STATE['MOVE'] then

		if key == 'up' then
			self.movement.mov[self.movement.active_type]:increase_y()
		elseif key == 'left' then
			self.movement.mov[self.movement.active_type]:increase_x()
		elseif key == 'down' then
			self.movement.mov[self.movement.active_type]:decrease_y()
		elseif key == 'right' then
			self.movement.mov[self.movement.active_type]:decrease_x()
		end
		
		self:set_idle ()
	end
end

function player:handle_key_hold ()

	if self.state == PL_STATE['SP_MOVE'] or (self.state >= PL_STATE['WEAPON_1'] and self.state <= PL_STATE['WEAPON_3']) then
		
		if love.keyboard.isDown('up') then
			self.movement.mov[self.movement.active_type]:decrease_y()
		end
		if love.keyboard.isDown('left') then
			self.movement.mov[self.movement.active_type]:decrease_x()
		end
		if love.keyboard.isDown('down') then
			self.movement.mov[self.movement.active_type]:increase_y()
		end
		if love.keyboard.isDown('right') then
			self.movement.mov[self.movement.active_type]:increase_x()
		end
		
		self:set_idle ()
	end
end

function player:move (dt)
--active module move function -> moving check -> movement corrections

	if self.state == PL_STATE['IDLE'] or self.state == PL_STATE['MOVE'] then
		self.movement.mov[self.movement.active_type]:move(dt)
		if self:is_moving_check() == true then
			self.movement.mov[self.movement.active_type]:move_correction()
		end

	elseif (self.state >= PL_STATE['WEAPON_1'] and self.state <= PL_STATE['WEAPON_3']) then
		self.active_attack:move(dt)
	end
end

function player:show (camera)

	if rect_vs_rect(camera.box, self.sprite_box) == true then
		self.is_visible = true
	
		if self.state == PL_STATE['MOVE'] then
			self.movement.mov[self.movement.active_type]:show(self.lockon.dir_modifier)
		
		elseif (self.state == PL_STATE['SP_MOVE']) then

		elseif (self.state >= PL_STATE['WEAPON_1'] and self.state <= PL_STATE['WEAPON_3']) then
			self.active_attack:show(self.lockon.dir_modifier)
		
			--TEST hitboxes:
			for i = 1, #self.active_attack.hit_box do
				self.active_attack.hit_box[i]:draw()
			end
		
		else
			--IDLE as default
			self.idle:show(self.lockon.dir_modifier)
		end
		
	else
		self.is_visible = false
	end
end

function player:is_moving_check ()
	if self.movement.mov[self.movement.active_type].x_vel ~= 0 or self.movement.mov[self.movement.active_type].y_vel ~= 0 then
		return true
	else
		return false
	end
end

function player:action_handler (dt)
	
	if self.state == PL_STATE['IDLE'] then

		self.idle:action(dt)
		self.action_timer = self.action_timer + dt

	elseif self.state == PL_STATE['SP_MOVE'] then

	elseif (self.state >= PL_STATE['WEAPON_1'] and self.state <= PL_STATE['WEAPON_3']) then

		self.active_attack:action(dt, nil)
		self.action_timer = self.action_timer + dt
		
		if self.action_timer > self.action_timer_stop then
		--END OF STATE prototype. This should be yet another function!
		--Don't do it until you know how special moves and combos are going to function
			self.active_attack = nil
			
			self.action_timer = 0
			self.action_timer_stop = 0
			
			self.movement.mov[self.movement.active_type].x_vel = 0
			self.movement.mov[self.movement.active_type].y_vel = 0
			
			self:handle_key_hold()
			self.state = PL_STATE['MOVE']
			self:set_idle ()
		end

	else
		--standard
	end
end

function player:set_camera (camera)
	camera.box.x = (self.sprite_box.x + (self.sprite_box.w/2)) - SCREEN_W/2
	camera.box.y = (self.sprite_box.y + (self.sprite_box.h/2)) - SCREEN_H/2
end

function player:attack(attack, state)
--PROTOTYPE
	self:reset_action_timer()
	self.action_timer_stop = attack.action_timer_stop
	self.state = state
	self.active_attack = attack
end

function player:update_attack_box()
--the attack hitbox placement is relative to this SQUARE (x+;y+)
	self.attack_box.x = self.hit_box[1].box.x
	self.attack_box.y = self.hit_box[1].box.y
	self.attack_box.w = self.hit_box[1].box.w
	self.attack_box.h = self.hit_box[1].box.h
end

function player:get_attack_box()
	return self.attack_box.x, self.attack_box.y, self.attack_box.w, self.attack_box.h
end

function player:set_idle ()
	if self.state == PL_STATE['MOVE'] and self:is_moving_check() == false then
		self.idle:start_state()
		self.state = PL_STATE['IDLE']
	end
end

function player:set_move()
	if self.state == PL_STATE['IDLE'] and self:is_moving_check() == true then
		self.state = PL_STATE['MOVE']
		self:reset_action_timer()
	end
end

function player:reset_action_timer()
	self.action_timer = 0.0
end