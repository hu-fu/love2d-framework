------------------
--Movement mapper:
------------------

MovementActionMapper = {}
MovementActionMapper.__index = MovementActionMapper

setmetatable(MovementActionMapper, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function MovementActionMapper.new ()
	local self = setmetatable ({}, MovementActionMapper)
		
		self.MOVEMENT_DIRECTION_MAP = {
			{2,1,8},
			{3,false,7},
			{4,5,6}
		}
		
		self.MOVEMENT_DIRECTION_MAP_DEFAULT_X_INDEX = 2
		self.MOVEMENT_DIRECTION_MAP_DEFAULT_Y_INDEX = 2
		self.movementDirectionMapXIndex = 2
		self.movementDirectionMapYIndex = 2
		
		self.MOVEMENT_ROTATION_MAP = {
			{math.rad(135),math.rad(90),math.rad(45)},
			{math.rad(180),false,math.rad(0)},
			{math.rad(225),math.rad(270),math.rad(315)}
		}
		
		self.MOVEMENT_ROTATION_MAP_DEFAULT_X_INDEX = 2
		self.MOVEMENT_ROTATION_MAP_DEFAULT_Y_INDEX = 2
		self.movementRotationMapXIndex = 2
		self.movementRotationMapYIndex = 2
		
		self.movementKeyPress = false
		self.movementKeyRelease = false
	return self
end

function MovementActionMapper:resetMovementDirectionMapXIndex()
	self.movementDirectionMapXIndex = self.MOVEMENT_DIRECTION_MAP_DEFAULT_X_INDEX
end

function MovementActionMapper:resetMovementDirectionMapYIndex()
	self.movementDirectionMapYIndex = self.MOVEMENT_DIRECTION_MAP_DEFAULT_Y_INDEX
end

function MovementActionMapper:setMovementDirectionMapXIndex(value)
	self.movementDirectionMapXIndex = value
end

function MovementActionMapper:setMovementDirectionMapYIndex(value)
	self.movementDirectionMapYIndex = value
end

function MovementActionMapper:incrementMovementDirectionMapXIndex(value)
	self.movementDirectionMapXIndex = self.movementDirectionMapXIndex + value
	if self.movementDirectionMapXIndex > 3 or self.movementDirectionMapXIndex < 1 then
		self.movementDirectionMapXIndex = self.movementDirectionMapXIndex - value
	end
end

function MovementActionMapper:incrementMovementDirectionMapYIndex(value)
	self.movementDirectionMapYIndex = self.movementDirectionMapYIndex + value
	if self.movementDirectionMapYIndex > 3 or self.movementDirectionMapYIndex < 1 then
		self.movementDirectionMapYIndex = self.movementDirectionMapYIndex - value
	end
end

function MovementActionMapper:getCurrentMovementDirection()
	return self.MOVEMENT_DIRECTION_MAP[self.movementDirectionMapYIndex][self.movementDirectionMapXIndex]
end

function MovementActionMapper:resetMovementRotationMapXIndex()
	self.movementRotationMapXIndex = self.MOVEMENT_ROTATION_MAP_DEFAULT_X_INDEX
end

function MovementActionMapper:resetMovementRotationMapYIndex()
	self.movementRotationMapYIndex = self.MOVEMENT_ROTATION_MAP_DEFAULT_Y_INDEX
end

function MovementActionMapper:setMovementRotationMapXIndex(value)
	self.movementRotationMapXIndex = value
end

function MovementActionMapper:setMovementRotationMapYIndex(value)
	self.movementRotationMapYIndex = value
end

function MovementActionMapper:incrementMovementRotationMapXIndex(value)
	self.movementRotationMapXIndex = self.movementRotationMapXIndex + value
	if self.movementRotationMapXIndex > 3 or self.movementRotationMapXIndex < 1 then
		self.movementRotationMapXIndex = self.movementRotationMapXIndex - value
	end
end

function MovementActionMapper:incrementMovementRotationMapYIndex(value)
	self.movementRotationMapYIndex = self.movementRotationMapYIndex + value
	if self.movementRotationMapYIndex > 3 or self.movementRotationMapYIndex < 1 then
		self.movementRotationMapYIndex = self.movementRotationMapYIndex - value
	end
end

function MovementActionMapper:getCurrentMovementRotation()
	return self.MOVEMENT_ROTATION_MAP[self.movementRotationMapYIndex][self.movementRotationMapXIndex]
end

function MovementActionMapper:getMovementKeyPress()
	return self.movementKeyPress
end

function MovementActionMapper:setMovementKeyPress()
	self.movementKeyPress = true
end

function MovementActionMapper:resetMovementKeyPress()
	self.movementKeyPress = false
end

function MovementActionMapper:getMovementKeyRelease()
	return self.movementKeyRelease
end

function MovementActionMapper:setMovementKeyRelease()
	self.movementKeyRelease = true
end

function MovementActionMapper:resetMovementKeyRelease()
	self.movementKeyRelease = false
end

function MovementActionMapper:resetMapping()
	self:resetMovementDirectionMapXIndex()
	self:resetMovementDirectionMapYIndex()
	self:resetMovementRotationMapXIndex()
	self:resetMovementRotationMapYIndex()
	self:resetMovementKeyPress()
	self:resetMovementKeyRelease()
end