--[[
DEPRECATED!!

TAGS:

'SCENE'
	'AREA'
	'ENTITY'
		'NPC'
		'ITEM'
'PLAYER'
'SETTINGS'
...

tree system linked by string tags (wtf????)
created at program init
asset -> loader -> load system -> simDB (inverse relation for saving)
very basic stuff - just a generic data holder. the loaders do all the work

scrap this shit, make it much more simple !!!!
]]

----------------
--Game Database:
----------------

GameDatabase = {}
GameDatabase.__index = GameDatabase

setmetatable(GameDatabase, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function GameDatabase.new(id, name)
	local self = setmetatable ({}, GameDatabase)
		self.id = id
		self.name = name
		self.nodes = {}
	return self
end

function GameDatabase:getNode(tags)
	if #tags > 0 then
		local targetNode = self.nodes[tags[1]]
		
		for i=2, #tags do
			local targetNode = targetNode.nodes[tags[i]]
			if targetNode == nil then break end
		end
		
		return targetNode
	end
	
	return nil
end

function GameDatabase:getNodeData(tags)
	local node = self:getNode(tags)
	if node ~= nil then
		return node.data
	end
	return nil
end

function GameDatabase:indexNode(tags, node)
	local targetNode = self:getNode(tags)
	if targetNode ~= nil then
		targetNode:indexNode(node)
	end
end

function GameDatabase:addNode(tag, destinationTags)
	local node = GameDatabaseNode.new(tag)
	self:indexNode(destinationTags, node)
end

function GameDatabase:createDatabase(nodeMap)
	self.nodes = {}
	
	for tag, childTags in pairs(nodeMap) do
		local parentNode = GameDatabaseNode.new(tag)
		self:createNodes(parentNode, childTags)
		self.nodes[tag] = parentNode
	end
end

function GameDatabase:createNodes(parentNode, tags)
	for tag, childTags in pairs(tags) do
		local node = GameDatabaseNode.new(tag)
		parentNode:indexNode(node)
		self:createNodes(node, childTags)
	end
end

function GameDatabase:createNode(parentNode, tag)
	local node = GameDatabaseNode.new(tag)
	parentNode:indexNode(node)
end

---------------------
--Game Database Node:
---------------------

GameDatabaseNode = {}
GameDatabaseNode.__index = GameDatabaseNode

setmetatable(GameDatabaseNode, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function GameDatabaseNode.new(tag)
	local self = setmetatable ({}, GameDatabaseNode)
		self.tag = tag
		self.data = nil
		self.nodes = {}
	return self
end

function GameDatabaseNode:indexNode(node)
	self.nodes[node.tag] = node
end