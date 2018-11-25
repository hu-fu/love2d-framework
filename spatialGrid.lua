require 'misc'

---------------------
--spatial grid class:
---------------------

spatialGrid = {}
spatialGrid.__index = spatialGrid

setmetatable(spatialGrid, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function spatialGrid.new (minimumNodeWidth, minimumNodeHeight, nodeSizeMultiplier)
	local self = setmetatable ({}, spatialGrid)
		
		self:setMinimumNodeSize(minimumNodeWidth, minimumNodeHeight)
		self:setNodeSizeMultiplier(nodeSizeMultiplier)
		
		self.subGrids = {}
		
	return self
end

function spatialGrid:setMinimumNodeSize(minimumNodeWidth, minimumNodeHeight)
	self.minimumNodeWidth, self.minimumNodeHeight = minimumNodeWidth, minimumNodeHeight
	if self.minimumNodeWidth < 64 then self.minimumNodeWidth = 64 end
	if self.minimumNodeHeight < 64 then self.minimumNodeHeight = 64 end
end

function spatialGrid:setNodeSizeMultiplier(nodeSizeMultiplier)
	if nodeSizeMultiplier <= 1 then
		nodeSizeMultiplier = 2
	end
	self.nodeSizeMultiplier = nodeSizeMultiplier
end

function spatialGrid:buildGrid(maxWidth, maxHeight)
	--reset grids, or make a new grid object
	
	local nodeWidth, nodeHeight = self.minimumNodeWidth, self.minimumNodeHeight
	
	while nodeWidth <= maxWidth and nodeHeight <= maxHeight do
		
		if nodeWidth > maxWidth then nodeWidth = maxWidth end
		if nodeHeight > maxHeight then nodeHeight = maxHeight end
		
		table.insert(self.subGrids, self:buildSubGrid(nodeWidth, nodeHeight, maxWidth, maxHeight))
	
		nodeWidth = nodeWidth*self.nodeSizeMultiplier
		nodeHeight = nodeHeight*self.nodeSizeMultiplier
	end
	
	table.insert(self.subGrids, self:buildSubGrid(maxWidth, maxHeight, maxWidth, maxHeight))
end

function spatialGrid:buildSubGrid(nodeWidth, nodeHeight, maxWidth, maxHeight)
	local subGrid = spatialSubGrid.new(nodeWidth, nodeHeight)
	local maxHeight, maxWidth = maxHeight-1, maxWidth-1
	
	for i=0, maxHeight, nodeHeight do
		local nodeRow = {}
		for j=0, maxWidth, nodeWidth do
			local nodeBottom, nodeRight = nodeHeight+i, nodeWidth+j
			table.insert(nodeRow, spatialGridNode.new(i, j, nodeBottom, nodeRight))
		end
		table.insert(subGrid.nodes, nodeRow)
	end
	
	self:createSubGridDefaultNode(subGrid)
	
	return subGrid
end

function spatialGrid:createSubGridDefaultNode(subGrid)
	--TODO: expand on this
	
	local defaultNodeY = spatialGridNode.new(-1, -1, 0, 0)
	local defaultNodeX = spatialGridNode.new(-1, -1, 0, 0)
	
	setDefaultTableValue(subGrid.nodes, defaultNodeY)
	setDefaultTableValue(defaultNodeY, defaultNodeX)
	
	for i=1, #subGrid.nodes do
		setDefaultTableValue(subGrid.nodes[i], defaultNodeX)
	end
end

function spatialGrid:getEntityGridLevel(width, height)
	--aka spatial level
	for i=1, #self.subGrids do
		if width <= self.subGrids[i].nodeWidth and 
				height <= self.subGrids[i].nodeHeight then
			return i
		end
	end
	return #self.subGrids	--OR return -1
end

function spatialGrid:getSubGridIndex(subGrid, x, y)
	--using ceil makes a 0 ccordinate = index 0
	return math.floor(x/subGrid.nodeWidth) + 1, math.floor(y/subGrid.nodeHeight) + 1
end

function spatialGrid:getSubGridIndexBySubGridNumber(subGridNumber, indexX, indexY)
	--only works upwards
	local divider = subGridNumber*self.nodeSizeMultiplier
	return math.ceil(indexX/divider), math.ceil(indexY/divider)
end

function spatialGrid:getNextSubGridIndex(indexX, indexY)
	return math.ceil(indexX/self.nodeSizeMultiplier), math.ceil(indexY/self.nodeSizeMultiplier)
end

function spatialGrid:getPreviousSubGridIndex(indexX, indexY)
	--?
end

--new names for these functions?
function spatialGrid:nodeLeftRangeCheck(node, x)
	if x < node.left then return true end
	return false
end

function spatialGrid:nodeRightRangeCheck(node, x)
	if x > node.right then return true end
	return false
end

function spatialGrid:nodeTopRangeCheck(node, y)
	if y < node.top then return true end
	return false
end

function spatialGrid:nodeBottomRangeCheck(node, y)
	if y > node.bottom then return true end
	return false
end

function spatialGrid:createSpatialEntityTables(indexList)
	for i=1, #self.subGrids do
		local subGrid = self.subGrids[i]
		for j=1, #indexList do
			subGrid.entityTables[indexList[j]] = spatialEntityTable.new()
			subGrid.entityTables[indexList[j]]:buildEntityTable(#subGrid.nodes[#subGrid.nodes], #subGrid.nodes)
		end
	end
end

--debug func:
function spatialGrid:drawSubGrid(camera, subGridIndex)
	if (self.subGrids[subGridIndex] ~= nil) then
		self.subGrids[subGridIndex]:draw(camera)
	end
end

-------------------------
--spatial sub grid class:
-------------------------

spatialSubGrid = {}
spatialSubGrid.__index = spatialSubGrid

setmetatable(spatialSubGrid, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function spatialSubGrid.new (nodeWidth, nodeHeight)
	local self = setmetatable ({}, spatialSubGrid)
		
		self.nodeWidth = nodeWidth
		self.nodeHeight = nodeHeight
		
		self.nodes = {}
		self.entityTables = {}
	return self
end

--debug funcs:
function spatialSubGrid:draw(camera)
	for i=1, #self.nodes do
		for j=1, #self.nodes[i] do
			local w, h = self.nodeWidth, self.nodeHeight
			local node = self.nodes[i][j]
			love.graphics.rectangle('line', node.left - camera.x, node.top - camera.y, w, h)
		end
	end
end

function spatialSubGrid:displayTableOccupation(entityTableIdentifier, x, y)
	if self.entityTables[entityTableIdentifier] ~= nil then
		local entityTable = self.entityTables[entityTableIdentifier].entityTable
		for i=1, #entityTable do
			for j=1, #entityTable[i] do
				love.graphics.print(#entityTable[i][j], x + (j*10), y + (i*10))
			end
		end
	end
end

--------------------------
--spatial grid node class:
--------------------------

spatialGridNode = {}
spatialGridNode.__index = spatialGridNode

setmetatable(spatialGridNode, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function spatialGridNode.new (top, left, bottom, right)
	local self = setmetatable ({}, spatialGridNode)
		
		self.top = top
		self.left = left
		self.bottom = bottom
		self.right = right
		
	return self
end