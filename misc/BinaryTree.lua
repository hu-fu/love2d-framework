--------------
--Binary tree:
--------------
--index -> value (unique, change to value list if needed)
--barebones as fuck, you can't even add nodes when you want or store more than one value in a node
--TODO: expand this (or not)

BinaryTree = {}
BinaryTree.__index = BinaryTree

setmetatable(BinaryTree, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function BinaryTree.new ()
	local self = setmetatable ({}, BinaryTree)
		self.nodes = nil
		
	return self
end

function BinaryTree:buildTree(valueTable)
	table.sort(valueTable)
	local stemNode = BinaryTreeNode.new()
	self.nodes = stemNode
	self:divideNode(self.nodes, valueTable)
end

function BinaryTree:divideNode(node, valueTable)
	
	if #valueTable < 1 then
		--leaf node
	else
		local splitIndex = self:getSplitIndex(valueTable)
		node.splitValue = valueTable[splitIndex]
		table.remove(valueTable, splitIndex)
		
		local lessTable, largerTable = self:divideValueTable(node.splitValue, valueTable)
		
		node.firstChild = BinaryTreeNode.new()
		node.secondChild = BinaryTreeNode.new()
		
		self:divideNode(node.firstChild, lessTable)
		self:divideNode(node.secondChild, largerTable)
	end
end

function BinaryTree:getSplitIndex(valueTable)
	return math.ceil(#valueTable/2)
end

function BinaryTree:divideValueTable(splitValue, valueTable)
	local lessTable, largerTable = {}, {}
	
	for i=1, #valueTable do
		if valueTable[i] <= splitValue then
			table.insert(lessTable, valueTable[i])
		else
			table.insert(largerTable, valueTable[i])
		end
	end
	
	return lessTable, largerTable
end

function BinaryTree:getChildNode(node, value)
	if value < node.splitValue then
		return node.firstChild
	else
		return node.secondChild
	end
end

function BinaryTree:isLeaf(node)
	if node.splitValue == nil then
		return false
	end
	return true
end

function BinaryTree:getLeafByIndex(index)
	local node = self.nodes
	while node.splitValue ~= nil do
		node = self:getChildNode(node, index)
	end
	return node
end

function BinaryTree:storeValueInLeaf(index, value)
	local node = self:getLeafByIndex(index)
	node.value = value
end

function BinaryTree:getValue(index)
	local node = self:getLeafByIndex(index)
	return node.value
end

--DEBUG:
function BinaryTree:outputNodes(node)
	if node.splitValue ~= nil then
		debugger.debugStrings[2] = debugger.debugStrings[2] .. node.splitValue .. ', '
	end
	if node.firstChild ~= nil then 
		self:outputNodes(node.firstChild)
	end
	if node.secondChild ~= nil then 
		self:outputNodes(node.secondChild)
	end
end

function BinaryTree:outputLeaves(node)
	if node.splitValue == nil then
		debugger.debugStrings[1] = debugger.debugStrings[1] + 1
	end
	if node.firstChild ~= nil then 
		self:outputLeaves(node.firstChild)
	end
	if node.secondChild ~= nil then 
		self:outputLeaves(node.secondChild)
	end
end

function BinaryTree:outputValues(node)
	if node.splitValue == nil then
		debugger.debugStrings[1] = debugger.debugStrings[1] .. node.value .. ', '
	end
	if node.firstChild ~= nil then 
		self:outputValues(node.firstChild)
	end
	if node.secondChild ~= nil then 
		self:outputValues(node.secondChild)
	end
end

function BinaryTree:outputPath(value, node)
	if node.splitValue == nil then
		return 0
	end
	debugger.debugStrings[1] = debugger.debugStrings[1] .. node.splitValue .. ', '
	
	if value < node.splitValue then
		self:outputPath(value, node.firstChild)
	else
		self:outputPath(value, node.secondChild)
	end
end

-------------------
--Binary tree node:
-------------------

BinaryTreeNode = {}
BinaryTreeNode.__index = BinaryTreeNode

setmetatable(BinaryTreeNode, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function BinaryTreeNode.new ()
	local self = setmetatable ({}, BinaryTreeNode)
		
		self.splitValue = nil
		self.firstChild = nil
		self.secondChild = nil
		
		self.value = 0
	return self
end