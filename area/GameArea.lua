--------------
--Area Object:
--------------

GameArea = {}
GameArea.__index = GameArea

setmetatable(GameArea, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function GameArea.new ()
	local self = setmetatable ({}, GameArea)
		
		self.main = {
			id = 0,
			tag = ''
		}
		
		self.spatial = {
			unitWidth = 0,
			unitHeight = 0,
			maxUnitWidth = 0,
			maxUnitHeight = 0,
			w = 0,
			h = 0,
			minimumNodeWidth = 0,
			minimumNodeHeight = 0,
			nodeSizeMultiplier = 0
		}
		
		self.background = {
			imageId = nil,
			x = 0,
			y = 0,
			xSpeed = 1,
			ySpeed = 1
		}
		
		self.foreground = {
			imageId = nil,
			x = 0,
			y = 0,
			xSpeed = 1,
			ySpeed = 1
		}
		
		self.spawn = {}
		
	return self
end