require '/spatial/SpatialPartitioningObjects'
require 'misc'

---------------------
--spatial grid class:
---------------------

SpatialGrid = {}
SpatialGrid.__index = SpatialGrid

setmetatable(SpatialGrid, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialGrid.new (minimumNodeWidth, minimumNodeHeight, nodeSizeMultiplier)
	local self = setmetatable ({}, SpatialGrid)
		
		self:setMinimumNodeSize(minimumNodeWidth, minimumNodeHeight)
		self:setNodeSizeMultiplier(nodeSizeMultiplier)
		
		self.subGrids = {}
		
	return self
end

function SpatialGrid:setMinimumNodeSize(minimumNodeWidth, minimumNodeHeight)
	self.minimumNodeWidth, self.minimumNodeHeight = minimumNodeWidth, minimumNodeHeight
	if self.minimumNodeWidth < 64 then self.minimumNodeWidth = 64 end
	if self.minimumNodeHeight < 64 then self.minimumNodeHeight = 64 end
end

function SpatialGrid:setNodeSizeMultiplier(nodeSizeMultiplier)
	if nodeSizeMultiplier <= 1 then
		nodeSizeMultiplier = 2
	end
	self.nodeSizeMultiplier = nodeSizeMultiplier
end

function SpatialGrid:buildGrid(maxWidth, maxHeight)
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

function SpatialGrid:buildSubGrid(nodeWidth, nodeHeight, maxWidth, maxHeight)
	local subGrid = SpatialSubGrid.new(nodeWidth, nodeHeight)
	local maxHeight, maxWidth = maxHeight-1, maxWidth-1
	
	for i=0, maxHeight, nodeHeight do
		local nodeRow = {}
		for j=0, maxWidth, nodeWidth do
			local nodeBottom, nodeRight = nodeHeight+i, nodeWidth+j
			table.insert(nodeRow, SpatialGridNode.new(i, j, nodeBottom, nodeRight))
		end
		table.insert(subGrid.nodes, nodeRow)
	end
	
	self:createSubGridDefaultNode(subGrid)
	
	return subGrid
end

function SpatialGrid:createSubGridDefaultNode(subGrid)
	--TODO: expand on this
	
	local defaultNodeY = SpatialGridNode.new(-1, -1, 0, 0)
	local defaultNodeX = SpatialGridNode.new(-1, -1, 0, 0)
	
	setDefaultTableValue(subGrid.nodes, defaultNodeY)
	setDefaultTableValue(defaultNodeY, defaultNodeX)
	
	for i=1, #subGrid.nodes do
		setDefaultTableValue(subGrid.nodes[i], defaultNodeX)
	end
end

function SpatialGrid:getEntityGridLevel(width, height)
	--aka spatial level
	for i=1, #self.subGrids do
		if width <= self.subGrids[i].nodeWidth and
				height <= self.subGrids[i].nodeHeight then
			return i
		end
	end
	return #self.subGrids	--OR return -1
end

function SpatialGrid:getSubGridIndex(subGrid, x, y)
	--using ceil makes a 0 ccordinate = index 0
	return math.floor(x/subGrid.nodeWidth) + 1, math.floor(y/subGrid.nodeHeight) + 1
end

function SpatialGrid:getSubGridIndexBySubGridNumber(subGridNumber, indexX, indexY)
	--only works upwards
	local divider = subGridNumber*self.nodeSizeMultiplier
	return math.ceil(indexX/divider), math.ceil(indexY/divider)
end

function SpatialGrid:getNextSubGridIndex(indexX, indexY)
	return math.ceil(indexX/self.nodeSizeMultiplier), math.ceil(indexY/self.nodeSizeMultiplier)
end

function SpatialGrid:getPreviousSubGridIndex(indexX, indexY)
	--?
end

--new names for these functions?
function SpatialGrid:nodeLeftRangeCheck(node, x)
	if x < node.left then return true end
	return false
end

function SpatialGrid:nodeRightRangeCheck(node, x)
	if x > node.right then return true end
	return false
end

function SpatialGrid:nodeTopRangeCheck(node, y)
	if y < node.top then return true end
	return false
end

function SpatialGrid:nodeBottomRangeCheck(node, y)
	if y > node.bottom then return true end
	return false
end

function SpatialGrid:createSpatialEntityTables(roleEnum)
	for i=1, #self.subGrids do
		local subGrid = self.subGrids[i]
		for roleName, roleId in pairs(roleEnum) do
			subGrid.entityTables[roleId] = SpatialEntityTable.new()
			subGrid.entityTables[roleId]:buildEntityTable(#subGrid.nodes[#subGrid.nodes], #subGrid.nodes)
		end
	end
end

--debug func:
function SpatialGrid:drawSubGrid(camera, subGridIndex)
	if (self.subGrids[subGridIndex] ~= nil) then
		self.subGrids[subGridIndex]:draw(camera)
	end
end

-------------------------
--spatial sub grid class:
-------------------------

SpatialSubGrid = {}
SpatialSubGrid.__index = SpatialSubGrid

setmetatable(SpatialSubGrid, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialSubGrid.new (nodeWidth, nodeHeight)
	local self = setmetatable ({}, SpatialSubGrid)
		
		self.nodeWidth = nodeWidth
		self.nodeHeight = nodeHeight
		
		self.nodes = {}
		self.entityTables = {}
	return self
end

--debug funcs:
function SpatialSubGrid:draw(x, y)
	for i=1, #self.nodes do
		for j=1, #self.nodes[i] do
			local w, h = self.nodeWidth, self.nodeHeight
			local node = self.nodes[i][j]
			if x and y then
				love.graphics.rectangle('line', node.left - x, node.top - y, w, h)
			else
				love.graphics.rectangle('line', node.left, node.top, w, h)
			end
		end
	end
end

function SpatialSubGrid:displayTableOccupation(entityTableIdentifier, x, y)
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

SpatialGridNode = {}
SpatialGridNode.__index = SpatialGridNode

setmetatable(SpatialGridNode, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialGridNode.new (top, left, bottom, right)
	local self = setmetatable ({}, SpatialGridNode)
		
		self.top = top
		self.left = left
		self.bottom = bottom
		self.right = right
		
	return self
end