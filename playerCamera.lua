---------------------
--playerCamera class:
---------------------

--playerCamera_STATE = {['FREE'] = 1, ['FIXED'] = 2, ['FOLLOW'] = 3}

--Ability to travel along an itinerary -> move vec
--Ability to look at and follow targets
--Ability to control the playerCamera
--cycle through targets
--lerp, shake and other effects
--zoom? how do you even do this <- love2d has this function
--focus on other stuff while following target <- good for lockon

playerCamera = {}
playerCamera.__index = playerCamera

setmetatable(playerCamera, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function playerCamera.new (x, y, w, h, vel)
	local self = setmetatable ({}, playerCamera)
		
		self.x = x
		self.y = y
		self.w = w
		self.h = h
		
		self.zoomX = 1
		self.zoomY = 1
		
		self.vel = vel
		
		--previous frame information (currently bonked):
		self.previousX = x
		self.previousY = y
		
	return self
end

function playerCamera:getTilemapIndex(tileW, tileH)
	return math.floor(self.x/tileW)+1, math.floor(self.y/tileH)+1
end

function playerCamera:tilemapIndexModification(tileW, tileH)
	local currentIndexX, currentIndexY, previousIndexX, previousIndexY = math.floor(self.x/tileW)+1, math.floor(self.y/tileH)+1, math.floor(self.previousX/tileW)+1, math.floor(self.previousY/tileH)+1
	
	if currentIndexX ~= previousIndexX or currentIndexY ~= previousIndexY then
		return true, currentIndexX, currentIndexY
	else
		return false, currentIndexX, currentIndexY
	end
end

--[[
Input/Movement functions
Just for testing the map scroll.
has a bug in the previousX, Y vars assignment
]]

function playerCamera:keyHold()
	if love.keyboard.isDown('w') then
		self:move(0, self.vel*-1)
	end
	if love.keyboard.isDown('a') then
		self:move(self.vel*-1, 0)
	end
	if love.keyboard.isDown('s') then
		self:move(0, self.vel)
	end
	if love.keyboard.isDown('d') then
		self:move(self.vel, 0)
	end
end

function playerCamera:keyPress(key)
	if key == 'w' then
	
	elseif key == 'a' then
	
	elseif key == 's' then
	
	elseif key == 'd' then
	
	end
end

function playerCamera:keyRelease(key)
	if key == 'w' then
	
	elseif key == 'a' then
	
	elseif key == 's' then
	
	elseif key == 'd' then
	
	end
end

function playerCamera:move(xVel, yVel)
	self.previousY = self.y
	self.previousX = self.x
	self.x = self.x + xVel
	self.y = self.y + yVel
end