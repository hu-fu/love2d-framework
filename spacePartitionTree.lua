-----------------------------
--partition tree class (k-d):
-----------------------------

partitionTree = {}
partitionTree.__index = partitionTree

setmetatable(partitionTree, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function partitionTree.new (nodeOverflow)
	local self = setmetatable ({}, partitionTree)
	
		self.nodeOverflow = nodeOverflow
		
		self.nodes = nil
		
		--debug:
		self.numberOfNodes = 1
	return self
end

function partitionTree:buildTree(areaMap, areaQuads)
	local stemNode = partitionTreeNode.new(false, quad.new(0, 0, areaMap.maxX*areaMap.tileW, 
		areaMap.maxY*areaMap.tileH), nil, nil)
	for i=1, #areaQuads do
		table.insert(stemNode.areaQuads, areaQuads[i])
	end
	self.nodes = stemNode
	self:divideNode(self.nodes)
end

function partitionTree:divideNode(node)
	
	if #node.areaQuads >= self.nodeOverflow then
		
		local heuristicValueX, splittingValueX = self:getBestSplittingValueByAxis(node.quad, 1, node.areaQuads)
		local heuristicValueY, splittingValueY = self:getBestSplittingValueByAxis(node.quad, 2, node.areaQuads)
		
		if heuristicValueX == false or heuristicValueY == false then
			if heuristicValueX ~= false then
				node.splitDimension = 1
				node.splitValue = splittingValueX
			elseif heuristicValueY ~= false then
				node.splitDimension = 2
				node.splitValue = splittingValueY
			else
				return
			end
		elseif heuristicValueX < heuristicValueY then
			node.splitDimension = 1
			node.splitValue = splittingValueX
		else
			node.splitDimension = 2
			node.splitValue = splittingValueY
		end
		
		local firstPartitionQuad, secondPartitionQuad = self:divideQuad(node.quad, node.splitDimension, node.splitValue)
		node.firstChild = partitionTreeNode.new(node, firstPartitionQuad, nil, nil)
		node.secondChild = partitionTreeNode.new(node, secondPartitionQuad, nil, nil)
		
		self:allocateAreaQuadsToPartitions(node)
		node.areaQuads = {}
		
		--absolute madman:
		self:divideNode(node.firstChild)
		self:divideNode(node.secondChild)
	end
end

function partitionTree:allocateAreaQuadsToPartitions(node)
	for i=1, #node.areaQuads do
		if node.splitDimension == 1 then
			if node.areaQuads[i].x < node.splitValue then
				table.insert(node.firstChild.areaQuads, quad.new(node.areaQuads[i].x, node.areaQuads[i].y, 
					node.areaQuads[i].w, node.areaQuads[i].h))
			end
			if (node.areaQuads[i].x + node.areaQuads[i].w) > node.splitValue then
				table.insert(node.secondChild.areaQuads, quad.new(node.areaQuads[i].x, node.areaQuads[i].y, 
					node.areaQuads[i].w, node.areaQuads[i].h))
			end
		else
			if node.areaQuads[i].y < node.splitValue then
				table.insert(node.firstChild.areaQuads, quad.new(node.areaQuads[i].x, node.areaQuads[i].y, 
					node.areaQuads[i].w, node.areaQuads[i].h))
			end
			if (node.areaQuads[i].y + node.areaQuads[i].h) > node.splitValue then
				table.insert(node.secondChild.areaQuads, quad.new(node.areaQuads[i].x, node.areaQuads[i].y, 
					node.areaQuads[i].w, node.areaQuads[i].h))
			end
		end
	end
end

function partitionTree:getSurfaceAreaHeuristicValue(parentNodeQuad, splitDimension, splitValue, areaQuads)
	local areaTotal = parentNodeQuad.w*parentNodeQuad.h
	local areaFirstPartition = 0
	local areaSecondPartition = 0
	
	if splitDimension == 1 then
		areaFirstPartition = (splitValue - parentNodeQuad.x)*parentNodeQuad.h
		areaSecondPartition = ((parentNodeQuad.x + parentNodeQuad.w) - splitValue)*parentNodeQuad.h
	else
		areaFirstPartition = parentNodeQuad.w*(splitValue - parentNodeQuad.y)
		areaSecondPartition = parentNodeQuad.w*((parentNodeQuad.y + parentNodeQuad.h) - splitValue)
	end
	
	local firstPartitionQuadNumber = 0
	local secondPartitionQuadNumber = 0
	
	for i=1, #areaQuads do
		local firstPartition, secondPartition = self:getQuadAllocationInPartition(splitDimension, splitValue, areaQuads[i])
		if firstPartition then
			firstPartitionQuadNumber = firstPartitionQuadNumber + 1
		end
		if secondPartition then
			secondPartitionQuadNumber = secondPartitionQuadNumber + 1
		end
	end
	
	return (areaFirstPartition/areaTotal)*firstPartitionQuadNumber + (areaSecondPartition/areaTotal)*secondPartitionQuadNumber
end

function partitionTree:getQuadAllocationInPartition(splitDimension, splitValue, areaQuad)
	local firstPartition = false
	local secondPartition = false
	
	if splitDimension == 1 then
		if areaQuad.x < splitValue then
			firstPartition = true
		end
		if (areaQuad.x + areaQuad.w) > splitValue then
			secondPartition = true
		end
	else
		if areaQuad.y < splitValue then
			firstPartition = true
		end
		if (areaQuad.y + areaQuad.h) > splitValue then
			secondPartition = true
		end
	end
	
	return firstPartition, secondPartition
end

function partitionTree:divideQuad(quad, splitDimension, splitValue)
	local firstPartitionQuad = nil
	local secondPartitionQuad = nil
	
	if splitDimension == 1 then
		firstPartitionQuad = quad.new(quad.x, quad.y, splitValue - quad.x, quad.h)
		secondPartitionQuad = quad.new(splitValue, quad.y, (quad.x + quad.w) - splitValue, quad.h)
	else
		firstPartitionQuad = quad.new(quad.x, quad.y, quad.w, splitValue - quad.y)
		secondPartitionQuad = quad.new(quad.x, splitValue, quad.w, (quad.y + quad.h) - splitValue)
	end
	return firstPartitionQuad, secondPartitionQuad
end

function partitionTree:getBestSplittingValueByAxis(parentNodeQuad, splitDimension, areaQuads)
	local splitValue = false
	local currentSplitValue = false
	local lowestHeuristicValue = false
	local currentHeuristicValue = false
	local parentQuadFirstLimit, parentQuadSecondLimit = self:getQuadLimitsByAxis(parentNodeQuad, splitDimension)
	
	--self:sortAreaQuads(areaQuads, splitDimension)	--can be used to optimize the algorithm(?)
	
	for i=1, #areaQuads do
		local firstLimit, secondLimit = self:getQuadLimitsByAxis(areaQuads[i], splitDimension)
		
		local firstLimitHeuristicValue = self:getSurfaceAreaHeuristicValue(parentNodeQuad, splitDimension, firstLimit, areaQuads)
		local secondLimitHeuristicValue = self:getSurfaceAreaHeuristicValue(parentNodeQuad, splitDimension, secondLimit, areaQuads)
		
		if firstLimit <= parentQuadFirstLimit or secondLimit >= parentQuadSecondLimit then
			--one of the limits is out of bounds
			if firstLimit > parentQuadFirstLimit then
				currentHeuristicValue = firstLimitHeuristicValue
				currentSplitValue = firstLimit
			elseif secondLimit < parentQuadSecondLimit then
				currentHeuristicValue = secondLimitHeuristicValue
				currentSplitValue = secondLimit
			else
				
			end
		elseif firstLimitHeuristicValue <= secondLimitHeuristicValue then
			currentHeuristicValue = firstLimitHeuristicValue
			currentSplitValue = firstLimit
		else
			currentHeuristicValue = secondLimitHeuristicValue
			currentSplitValue = secondLimit
		end
		
		if lowestHeuristicValue == false or currentHeuristicValue < lowestHeuristicValue then
			lowestHeuristicValue = currentHeuristicValue
			splitValue = currentSplitValue
		end
	end
	
	return lowestHeuristicValue, splitValue
end

function partitionTree:getQuadLimitsByAxis(areaQuad, axis)
	if axis == 1 then
		return areaQuad.x, areaQuad.x + areaQuad.w
	else
		return areaQuad.y, areaQuad.y + areaQuad.h
	end
end

function partitionTree:sortAreaQuads(quads, axis)
	if axis == 1 then
		table.sort(quads, function(a,b) return a.x < b.x end)
	else
		table.sort(quads, function(a,b) return a.y < b.y end)
	end
end

--debug functions:

function partitionTree:drawNodes(node, camera)
	self.numberOfNodes = self.numberOfNodes + 1	--debug!
	
	local quad = node.quad
		
	love.graphics.rectangle('line', quad.x - camera.x, quad.y - camera.y, quad.w, quad.h)
		
	if node.firstChild ~= nil then self:drawNodes(node.firstChild, camera) end
	if node.secondChild ~= nil then self:drawNodes(node.secondChild, camera) end
end

function partitionTree:getHeight(node)
	if node.firstChild ~= nil then
		local leftHeight = self:getHeight(node.firstChild)
		local rightHeight = self:getHeight(node.secondChild)
		if leftHeight > rightHeight then
			return leftHeight + 1
		else
			return rightHeight + 1
		end
	else
		return 0
	end
end

----------------------------
--partition tree node class:
----------------------------

partitionTreeNode = {}
partitionTreeNode.__index = partitionTreeNode

setmetatable(partitionTreeNode, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function partitionTreeNode.new (parentNode, quad, splitDimension, splitValue)
	local self = setmetatable ({}, partitionTreeNode)
		
		self.parentNode = parentNode
		
		self.quad = quad	--the quad is needed for the surface area heuristic calculation
		
		self.splitDimension = splitDimension
		self.splitValue = splitValue
		
		self.firstChild = nil
		self.secondChild = nil
		
		self.areaQuads = {}
	return self
end