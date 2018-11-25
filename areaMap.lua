require 'misc'

-------------
--tile class:
-------------

tile = {}
tile.__index = tile

setmetatable(tile, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function tile.new (x, y, quad, collision)
	local self = setmetatable ({}, tile)
	
		self.x = x
		self.y = y
		self.quad = quad
		self.collision = collision
		
	return self
end

----------------
--areaMap class:
----------------
--needs a rewrite (not urgent)

areaMap = {}
areaMap.__index = areaMap

setmetatable(areaMap, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function areaMap.new (maxX, maxY, tileW, tileH)
	local self = setmetatable ({}, areaMap)
		
		self.maxX = maxX
		self.maxY = maxY
		self.tileW = tileW
		self.tileH = tileH
		
		self.tileLayer1 = {}
		self.tileLayer2 = {}
		
	return self
end

function areaMap:createTileLayer1(layer1Quad, layer1Collision)
	local x, y = 0
	local tileRow = {}
	
	for i=1, #layer1Quad do
		y = i*self.tileH - self.tileH
			for j=1, #layer1Quad[i] do
				x = j*self.tileW - self.tileW
				if layer1Quad[i][j] > 0 then
					table.insert(tileRow, tile.new(x, y, layer1Quad[i][j], layer1Collision[i][j]))
				else
					table.insert(tileRow, false)
				end
			end
		table.insert(self.tileLayer1, tileRow)
		tileRow = {}
	end
	
	self:setTileLayer1DefaultValue()
end

function areaMap:createTileLayer2(layer2Quad, layer2Collision)
	local x, y = 0
	local tileRow = {}
	
	for i=1, #layer2Quad do
		y = i*self.tileH - self.tileH
			for j=1, #layer2Quad[i] do
				x = j*self.tileW - self.tileW
				if layer2Quad[i][j] > 0 then
					table.insert(tileRow, tile.new(x, y, layer2Quad[i][j], layer2Collision[i][j]))
				else
					table.insert(tileRow, false)
				end
			end
		table.insert(self.tileLayer2, tileRow)
		tileRow = {}
	end
	
	self:setTileLayer2DefaultValue()
end

function areaMap:setTileLayer1DefaultValue()
	if #self.tileLayer1 > 0 then
		local defaultRow = {}
		for i=1, #self.tileLayer1[1] do
			table.insert(defaultRow, false)
		end
		setDefaultTableValue(self.tileLayer1, defaultRow)
	end
end

function areaMap:setTileLayer2DefaultValue()
	if #self.tileLayer2 > 0 then
		local defaultRow = {}
		for i=1, #self.tileLayer2[1] do
			table.insert(defaultRow, false)
		end
		setDefaultTableValue(self.tileLayer2, defaultRow)
	end
end

function areaMap:getMapDimensions()
	return self.tileW*#self.tileLayer1{1}, self.tileH*#self.tileLayer1
end