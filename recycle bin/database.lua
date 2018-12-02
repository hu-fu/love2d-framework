--[[
dbTable & tableLink classes
]]--

------------------
--ENTITY DATABASE:
------------------
--generic container for component tables - expand on this if needed

entityComponentDatabase = {}
entityComponentDatabase.__index = entityComponentDatabase

setmetatable(entityComponentDatabase, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function entityComponentDatabase.new (id, name)
	local self = setmetatable ({}, entityComponentDatabase)
		
		self.id = id
		self.name = name
		
		self.tables = {}	--['table name string'] = componentTable
	return self
end

function entityComponentDatabase:indexTable(index, tbl)
	self.tables[index] = tbl
end

function entityComponentDatabase:getTable(tableIndex)
	return self.tables[tableIndex]
end

function entityComponentDatabase:getTableRows(tableIndex)
	local tbl = self.tables[tableIndex]
	if tbl ~= nil then
		return tbl.rows
	end
	return {}
end

function entityComponentDatabase:createComponentTable(tableIndex, id, name, numberOfColumns, columnNames)
	self.tables[tableIndex] = componentTable.new(id, name, numberOfColumns, columnNames)
end

------------------
--COMPONENT TABLE:
------------------

componentTable = {}
componentTable.__index = componentTable

setmetatable(componentTable, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function componentTable.new (id, name, numberOfColumns, columnNames)
	local self = setmetatable ({}, componentTable)
		
		self.id = id
		self.name = name
		
		self.rows = {}
		self.numberOfColumns = numberOfColumns
		self.columnNames = columnNames	--dictionary
		
		self.parentLinks = {}
		self.childLinks = {}
		
	return self
end

function componentTable:isRowValid(row)
	if #row ~= self.numberOfColumns then
		return false
	end
	for i, link in pairs(self.parentLinks) do
		if link:parentTableRowExists(row[link.childTableColumnNumber]) == false or 
		link:isParentTableRowAvailable(row[link.childTableColumnNumber]) == false then
			return false
		end
	end
	for i, link in pairs(self.childLinks) do
		if row[link.parentTableColumnNumber] ~= false then
			return false
		end
	end
	return true
end

function componentTable:createRow(newRow)
	if self:isRowValid(newRow) then

		table.insert(self.rows, {})
		for i=1, self.numberOfColumns do
			self.rows[#self.rows][i] = newRow[i]
		end
	
		self:updateRow(#self.rows)
		return self.rows[#self.rows]
	end

	return false
end

function componentTable:copyRow(fromIndex, toIndex)
	for i=1, self.numberOfColumns do
		self.rows[toIndex][i] = self.rows[fromIndex][i]
	end
	self:updateRow(toIndex)
end

function componentTable:deleteRow(rowIndex)
	self:unregisterRowOnParentRows(rowIndex)
	self:deleteAllChildRows(rowIndex)
	
	if rowIndex ~= #self.rows then
		self:copyRow(#self.rows, rowIndex)
	end
	
	self.rows[#self.rows] = nil
end

function componentTable:unregisterRowOnParentRows(rowIndex)
	for i, link in pairs(self.parentLinks) do
		link:setParentTableColumnValue(self.rows[rowIndex][link.childTableColumnNumber], false)
	end
end

function componentTable:deleteChildRow(rowIndex, childTableId)
	if self.childLinks[childTableId] ~= nil then
		local link = self.childLinks[childTableId]
		local childTableRowIndex = self.rows[rowIndex][link.parentTableColumnNumber]
		if link:childTableRowExists(childTableRowIndex) then
			link:deleteChildTableRow(childTableRowIndex)
		end
	end
end

function componentTable:deleteAllChildRows(rowIndex)
	for i, link in pairs(self.childLinks) do
		local childTableRowIndex = self.rows[rowIndex][link.parentTableColumnNumber]
		if link:childTableRowExists(childTableRowIndex) then
			link:deleteChildTableRow(childTableRowIndex)
		end
	end
end

function componentTable:updateRow(rowIndex)
	for i, link in pairs(self.parentLinks) do
		link:setParentTableColumnValue(self.rows[rowIndex][link.childTableColumnNumber], rowIndex)
	end
	for i, link in pairs(self.childLinks) do
		local childTableRowIndex = self.rows[rowIndex][link.parentTableColumnNumber]
		if link:childTableRowExists(childTableRowIndex) then
			link:setChildTableColumnValue(childTableRowIndex, rowIndex)
		end
	end
end

-----------------------
--COMPONENT TABLE LINK:
-----------------------
--links two columns on different tables

componentTableLink = {}
componentTableLink.__index = componentTableLink

setmetatable(componentTableLink, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function componentTableLink.new (parentTableReference, parentTableColumnNumber, childTableReference, childTableColumnNumber)
	local self = setmetatable ({}, componentTableLink)
	
		self.parentTableReference = parentTableReference
		self.parentTableColumnNumber = parentTableColumnNumber
		self.childTableReference = childTableReference
		self.childTableColumnNumber = childTableColumnNumber
		self.childTableReference.parentLinks[self.parentTableReference.id] = self
		self.parentTableReference.childLinks[self.childTableReference.id] = self
		
	return self
end

function componentTableLink:registerSelfOnLinkedTables()
	self.childTableReference.parentLinks[self.parentTableReference.id] = self
	self.parentTableReference.childLinks[self.childTableReference.id] = self
end

function componentTableLink:unregisterSelfOnLinkedTables()
	self.childTableReference.parentLinks[self.parentTableReference.id] = nil
	self.parentTableReference.childLinks[self.childTableReference.id] = nil
end

function componentTableLink:parentTableRowExists(parentRowIndex)
	if self.parentTableReference.rows[parentRowIndex] == nil then
		return false
	end
	return true
end

function componentTableLink:childTableRowExists(childRowIndex)
	if self.childTableReference.rows[childRowIndex] == nil then
		return false
	end
	return true
end

function componentTableLink:isParentTableRowAvailable(parentRowIndex)
	if self.parentTableReference.rows[parentRowIndex][self.parentTableColumnNumber] == false then
		return true
	end
	return false
end

function componentTableLink:fetchParentTableLinkedColumnValue(parentRowIndex)
	return self.parentTableReference.rows[parentRowIndex][self.parentTableColumnNumber]
end

function componentTableLink:fetchChildTableLinkedColumnValue(childRowIndex)
	return self.childTableReference.rows[childRowIndex][self.childTableColumnNumber]
end

function componentTableLink:fetchParentTableColumnValue(parentRowIndex, columnNumber)
	return self.parentTableReference.rows[parentRowIndex][self.columnNumber]
end

function componentTableLink:fetchChildTableColumnValue(childRowIndex, columnNumber)
	return self.childTableReference.rows[childRowIndex][columnNumber]
end

function componentTableLink:fetchParentTableRow(parentRowIndex)
	return self.parentTableReference.rows[parentRowIndex]
end

function componentTableLink:fetchChildTableRow(childRowIndex)
	return self.childTableReference.rows[childRowIndex]
end

function componentTableLink:setParentTableColumnValue(parentRowIndex, value)
	self.parentTableReference.rows[parentRowIndex][self.parentTableColumnNumber] = value
end

function componentTableLink:setChildTableColumnValue(childRowIndex, value)
	self.childTableReference.rows[childRowIndex][self.childTableColumnNumber] = value
end

function componentTableLink:deleteChildTableRow(childRowIndex)
	self.childTableReference:deleteRow(childRowIndex)
end