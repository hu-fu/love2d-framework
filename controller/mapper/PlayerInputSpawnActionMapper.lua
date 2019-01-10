-------------------
--targeting mapper:
-------------------

SpawnActionMapper = {}
SpawnActionMapper.__index = SpawnActionMapper

setmetatable(SpawnActionMapper, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpawnActionMapper.new ()
	local self = setmetatable ({}, SpawnActionMapper)
		
		self.input = false
		self.startSpawn = false
		self.endSpawn = false
		self.startDespawn = false
		self.endDespawn = false
	return self
end

function SpawnActionMapper:setStartSpawn()
	self.input = true
	self.startSpawn = true
	self.endSpawn = false
	self.startDespawn = false
	self.endDespawn = false
end

function SpawnActionMapper:setStartDespawn()
	self.input = true
	self.startSpawn = false
	self.endSpawn = false
	self.startDespawn = true
	self.endDespawn = false
end

function SpawnActionMapper:setEndSpawn()
	self.input = true
	self.startSpawn = false
	self.endSpawn = true
	self.startDespawn = false
	self.endDespawn = false
end

function SpawnActionMapper:setEndDespawn()
	self.input = true
	self.startSpawn = false
	self.endSpawn = false
	self.startDespawn = false
	self.endDespawn = true
end

function SpawnActionMapper:resetMapping()
	self.input = false
	self.startSpawn = false
	self.endSpawn = false
	self.startDespawn = false
	self.endDespawn = false
end