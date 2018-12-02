---------------------------------
--movementObjectRepository class:
---------------------------------
--[[
Modifies entity movement information in the movement row according to the movement object.
Use it to set new movement parameters when performing different actions
]]

movementObjectRepository = {}
movementObjectRepository.__index = movementObjectRepository

setmetatable(movementObjectRepository, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function movementObjectRepository.new (id)
	local self = setmetatable ({}, movementObjectRepository)
		self.id = id
		self.movementObjectList = {}
		
		--substitute this for the db enum!
		self.MOVEMENT_TABLE_VELOCITY = 3
		self.MOVEMENT_TABLE_SPRITESHEET_ID = 5
		self.MOVEMENT_TABLE_DEFAULT_QUAD = 6
		self.MOVEMENT_TABLE_TOTAL_TIME = 7
		self.MOVEMENT_TABLE_FREQUENCY = 9
	return self
end

function movementObjectRepository:createMovementObject(id, velocity, spriteSheetId, defaultQuad, totalTime, frequency)
	self.movementObjectList[id] = movementObject.new(id, velocity, spriteSheetId, defaultQuad, totalTime, frequency)
end

function movementObjectRepository:setEntityMovementData(movementObjectId, movementRow)
	local movementObject = self.movementObjectList[movementObjectId]
	movementRow[self.MOVEMENT_TABLE_VELOCITY] = movementObject.velocity
	movementRow[self.MOVEMENT_TABLE_SPRITESHEET_ID] = movementObject.spritesheetId
	movementRow[self.MOVEMENT_TABLE_DEFAULT_QUAD] = movementObject.defaultQuad
	movementRow[self.MOVEMENT_TABLE_TOTAL_TIME] = movementObject.totalTime
	movementRow[self.MOVEMENT_TABLE_FREQUENCY] = movementObject.frequency
end

function movementObjectRepository:deleteMovementObject(movementObjectId)
	self.movementObjectList[movementObjectId] = nil
end

-----------------------
--movementObject class:
-----------------------
--Holds movement data. Methods are in the repository class.

movementObject = {}
movementObject.__index = movementObject

setmetatable(movementObject, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function movementObject.new (id, velocity, spriteSheetId, defaultQuad, totalTime, frequency)
	local self = setmetatable ({}, movementObject)
		self.id = id
		self.velocity = velocity
		self.spritesheetId = spritesheetId
		self.defaultQuad = defaultQuad
		self.totalTime = totalTime
		self.frequency = frequency
	return self
end