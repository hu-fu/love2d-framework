---------------
--entity class:
---------------

entity = {}
entity.__index = entity

setmetatable(entity, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function entity.new (index, id)
	local self = setmetatable ({}, entity)
		
		self.index = index
		self.id = id
		
		self.playerState = nil	--1
		
		self.position = nil		--2
		self.sprite = nil		--3
		self.hitbox = nil		--4
		
		self.idle = nil			--5
		self.movement = nil		--6
		self.attack = nil		--7
		self.interrupt = nil	--8
		
		self.collider = nil		--9
		
	return self
end

--------------------
--generic component:
--------------------

--This is just for testing

componentA = {}
componentA.__index = componentA

setmetatable(componentA, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function componentA.new (index, entity, value)
	local self = setmetatable ({}, componentA)
		
		self.index = index		--componentAList index
		self.entity = entity	--components should have pointers to parent entity
		
		self.value = value
	return self
end

componentB = {}
componentB.__index = componentB

setmetatable(componentB, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function componentB.new (index, entity, componentA, value)
	local self = setmetatable ({}, componentB)
		
		self.index = index
		self.entity = entity
		
		self.componentA = componentA	--dependency
		
		self.value = value
	return self
end