-------------
--Area Stack:
-------------

AreaStack = {}
AreaStack.__index = AreaStack

setmetatable(AreaStack, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function AreaStack.new (maxAreas)
	local self = setmetatable ({}, AreaStack)
		--some kind of LIFO stack I don't know I'm not an engineer
		
		self.stack = {}
		self.maxAreas = maxAreas
	return self
end

function AreaStack:pushArea(area)
	self:removeAreaById(area.main.id)
	
	table.insert(self.stack, 1, area)
	
	if #self.stack > self.maxAreas then
		self:popArea()
	end
end

function AreaStack:popArea()
	table.remove(self.stack)
end

function AreaStack:getCurrent()
	if #self.stack > 0 then
		return self.stack[1]
	end
	return nil	--default empty area
end

function AreaStack:getArea(areaId)
	for i=2, #self.stack do
		if self.stack[i].main.id == areaId then
			return self.stack[i]
		end
	end
	return nil
end

function AreaStack:clear()
	for i=#self.stack, -1, 1 do
		self:destroyArea(self.stack[i])
		table.remove(self.stack)
	end
end

function AreaStack:removeArea(area)
	for i=1, #self.stack do
		if self.stack[i] == area then
			table.remove(self.stack, i)
			return nil
		end
	end
end

function AreaStack:removeAreaById(areaId)
	for i=1, #self.stack do
		if self.stack[i].main.id == areaId then
			table.remove(self.stack, i)
			return nil
		end
	end
end

function AreaStack:destroyArea(area)
	--do stuff
end