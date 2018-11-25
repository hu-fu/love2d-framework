local UPDATE_AREA = require '/spatial update/UPDATE_AREA'

local updateAreaNone = SpatialUpdateArea.new('none', -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
local updateAreaSmall = SpatialUpdateArea.new('small', 5, 0.1, 0.1, 0, 0, 0, 0, 0, 0, 0, 0)
local updateAreaNormal = SpatialUpdateArea.new('normal', 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0)
local updateAreaMedium = SpatialUpdateArea.new('medium', 10, 1.2, 1.2, 0, 0, 0, 0, 0, 0, 0, 0)
local updateAreaLarge = SpatialUpdateArea.new('large', 20, 1.5, 1.5, 0, 0, 0, 0, 0, 0, 0, 0)
local updateAreaAll = SpatialUpdateArea.new('all', -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

function updateAreaNone:updateArea(x, y, w, h)
	self.x = -1
	self.y = -1
	self.w = 0
	self.h = 0
end

function updateAreaSmall:updateArea(x, y, w, h)
	self.x = (x+w)/2
	self.y = (y+h)/2
	self.w = self.x
	self.h = self.y
	--self:updateBounds()
end

function updateAreaNormal:updateArea(x, y, w, h)
	self.x = x
	self.y = y
	self.w = w
	self.h = h
end

function updateAreaAll:updateArea(x, y, w, h)
	self.x = 0
	self.y = 0
	self.w = 10000
	self.h = 10000
end

local updateAreaTable = {
	[UPDATE_AREA.NONE] = updateAreaNone,
	[UPDATE_AREA.SMALL] = updateAreaSmall,
	[UPDATE_AREA.NORMAL] = updateAreaNormal,
	[UPDATE_AREA.MEDIUM] = updateAreaMedium,
	[UPDATE_AREA.LARGE] = updateAreaLarge,
	[UPDATE_AREA.ALL] = updateAreaAll
}

return updateAreaTable