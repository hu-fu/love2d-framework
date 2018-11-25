-----------------
--areaGrid nodes:
-----------------
--DEPRECATED BUT HAS GOOD IDEAS

gridNode = {}
gridNode.__index = gridNode

setmetatable(gridNode, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function gridNode.new (x, y, w, h, overflowLimit)
	local self = setmetatable ({}, gridNode)
		self.x = x
		self.y = y
		self.w = w
		self.h = h
		
		self.overflowCounter = 0
		self.overflowLimit = overflowLimit
		
		self.entityList = {};
	return self
end

function gridNode:incrementOverflowCounter()
	self.overflowCounter = self.overflowCounter + 1
end

function gridNode:decrementOverflowCounter()
	self.overflowCounter = self.overflowCounter - 1
end

function gridNode:addEntityToEntityList(hitBoxRowIndex)
	table.insert(self.entityList, hitBoxRowIndex)
	self:incrementOverflowCounter()
end

function gridNode:removeEntityFromEntityList(hitBoxRowIndex)
	local entityIndex = false
	
	for i=1, #self.entityList do
		if self.entityList[i] == hitBoxRowIndex then
			entityIndex = i
			break
		end
	end
	
	if entityIndex then
		if entityIndex ~= #self.entityList then
			self.entityList[entityIndex] = self.entityList[#self.entityList]
			self.entityList[#self.entityList] = nil
			self:decrementOverflowCounter()
		end
	end
end