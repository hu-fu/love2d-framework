--------------------
--Action area class:
--------------------

actionArea = {}
actionArea.__index = actionArea

setmetatable(actionArea, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function actionArea.new (x, y)
	local self = setmetatable ({}, actionArea)
		
		self.x = x
		self.y = y
		
		self.areas = {}
	return self
end

function actionArea:createAreaQuad(tx, ty, w, h)
	local areaQuad = actionAreaQuad.new(tx, ty, w, h)
	self:addAreaQuad(areaQuad)
end

function actionArea:addAreaQuad(areaQuad)
	local quadArea = self:getAreaQuadArea(areaQuad)
	local insertIndex = 1
	
	for i=1, #self.areas do
		local a = self:getAreaQuadArea(self.areas[i])
		
		if quadArea <= a then
			insertIndex = i
			i = #self.areas
		end
	end
	
	table.insert(self.areas, insertIndex, areaQuad)
end

function actionArea:getAreaQuadArea(areaQuad)
	return areaQuad.w*areaQuad.h
end

function actionArea:sortAreasBySize()
	--needed?
end

function actionArea:incrementPosition(incrementX, incrementY)
	self.x = self.x + incrementX
	self.y = self.y + incrementY
end

function actionArea:changePosition(x, y)
	self.x = x
	self.y = y
end

function actionArea:getAreaQuadPosition(areaQuad)
	return self.x + areaQuad.tx, self.y + areaQuad.ty
end

function actionArea:getSmallestArea()
	if self.areas[1] ~= nil then
		return self.areas[1]
	end
end

function actionArea:getLargestArea()
	if self.areas[#self.areas] ~= nil then
		return self.areas[#self.areas]
	end
end

-------------------
--Action area quad:
-------------------
--tx, ty are relative coordinates (if tx = 100, then position = x + 100)

actionAreaQuad = {}
actionAreaQuad.__index = actionAreaQuad

setmetatable(actionAreaQuad, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function actionAreaQuad.new (tx, ty, w, h)
	local self = setmetatable ({}, actionAreaQuad)
		
		self.tx = tx
		self.ty = ty
		self.w = w
		self.h = h
		
	return self
end