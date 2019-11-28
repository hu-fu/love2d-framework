-----------------------
--Game Database System:
-----------------------
--[[
NAV:
getPersistentTableObjectFromFile
getPersistentTableObjectFromFileMethods
modifyTable
modifyTableRow
modifyTableRowMethods
createTableString
createTableStringMethods
getDatabaseTable
getDatabaseRows
getDatabaseRow
getDatabaseRowMethods
writeToDatabase
writeToDatabaseMethods
]]

local GameDatabaseSystem = {}

---------------
--Dependencies:
---------------

require '/persistent/GameDatabase'
local SYSTEM_ID = require '/system/SYSTEM_ID'
GameDatabaseSystem.TABLES = require '/persistent/DATABASE_TABLE'
GameDatabaseSystem.QUERY = require '/persistent/DATABASE_QUERY'
GameDatabaseSystem.JSON_ENCODE = require '/json/json'

-------------------
--System Variables:
-------------------

GameDatabaseSystem.id = SYSTEM_ID.GAME_DATABASE

GameDatabaseSystem.gameDatabase = nil

---------------
--Init Methods:
---------------

function GameDatabaseSystem:init()
	self:buildDatabase()
end

function GameDatabaseSystem:buildDatabase()
	self.gameDatabase = require '/persistent/GAME_DATABASE'
end

----------------
--Event Methods:
----------------

GameDatabaseSystem.eventMethods = {
	
	[1] = {
		[1] = function(request)
			GameDatabaseSystem:runQuery(request.databaseQuery)
			--INFO_STR = INFO_STR .. ' ' .. request.databaseQuery.queryParameters.tableId
		end
	}
}

---------------
--Exec Methods:
---------------

function GameDatabaseSystem:resetDatabase()
	self.gameDatabase = nil
	--build from file again
end

function GameDatabaseSystem:initTableFromFile(tableId, file)
	local persistentTableObject = self:getPersistentTableObjectFromFile(tableId, file)
	self:modifyTable(tableId, persistentTableObject)
end

function GameDatabaseSystem:getPersistentTableObjectFromFile(tableId, file)
	return self.getPersistentTableObjectFromFileMethods[tableId](self, file)
end

GameDatabaseSystem.getPersistentTableObjectFromFileMethods = {
	['generic_table'] = function(self, file)
		--parse file(JSON string) into lua object
		local tempTable = self.JSON_ENCODE:decode(file)
		return tempTable
	end,
	
	['generic_entity'] = function(self, file)
		--EXAMPLE
		--in this case the file for the generic entity is the same as the file for the area
		--solution: this method parses the file(string) and returns only the entity data table
		--the area data table is returned by the area method, using the same file string
	end,
	
	['settings'] = function(self, file)
		--parse file(JSON string) into lua object
		local tempTable = self.JSON_ENCODE:decode(file)
		return tempTable
	end,
	
	--...
}

function GameDatabaseSystem:modifyTable(tableId, persistentTableObject)
	self:modifyTable(tableId, persistentTableObject)
end

function GameDatabaseSystem:modifyTable(tableId, persistentTableObject)
	self.modifyTableMethods[tableId](self, persistentTableObject)
end

GameDatabaseSystem.modifyTableMethods = {
	['generic_table'] = function(self, persistentTableObject)
		--write from persistentObject to row
			--there was a for ROW do loop before this, but it's better to do it here
			--for persistentTableObject[ROW] modify getDatabaseRow
			--or just see settings below
		
		local databaseTable = self.gameDatabase['generic_table']
		
		for key, val in pairs(persistentTableObject) do
			databaseTable[key] = val
		end
	end,
	
	['settings'] = function(self, persistentTableObject)
		--write from persistentObject to table
		local databaseTable = self.gameDatabase['settings']
		
		for key, val in pairs(persistentTableObject) do
			databaseTable[key] = val
		end
	end,
	
	--...
}

function GameDatabaseSystem:createTableString(tableId)
	return self.createTableStringMethods[tableId](self)
end

GameDatabaseSystem.createTableStringMethods = {
	['generic_table'] = function(self)
		--parse lua object into string
		--for testing purposes only!
		local tableString = self.JSON_ENCODE:encode_pretty(self.gameDatabase['generic_table'])
		return tableString
	end,
	
	['generic_entity'] = function(self)
		--EXAMPLE
		--in this case the file for the generic entity is the same as the file for the area
		--solution: both methods do the same
		--create both the entities and the area string in both methods
		return ''
	end,
	
	['settings'] = function(self)
		--parse lua object into string
		local tableString = self.JSON_ENCODE:encode_pretty(self.gameDatabase['settings'])
		return tableString
	end,
}

function GameDatabaseSystem:getDatabaseTable(tableId)
	return self.gameDatabase[tableId]
end

function GameDatabaseSystem:getDatabaseRows(tableId, indexList)
	local results = {}
	
	for i=1, #indexList do
		table.insert(results, self.getDatabaseRowMethods[tableId](self, indexList[i]))
	end
	
	return results
end

function GameDatabaseSystem:getDatabaseRow(tableId, index)
	--dunno if this is needed
	return self.getDatabaseRowMethods[tableId](self, index)
end

GameDatabaseSystem.getDatabaseRowMethods = {
	['generic_table'] = function(self, index)
		--this table is for testing only!
		
		local row = nil
		
		for i=1, #self.gameDatabase['generic_table'] do
			if self.gameDatabase['generic_table'][i].id == index then
				row = self.gameDatabase['generic_table'][i]
				break
			end
		end
		
		return row
	end,
	
	['generic_entity'] = function(self, index)
		--db index == entity id
		local row = self.gameDatabase['generic_entity'][index]
		--if row==nil try a linear search
		return row
	end,
	
	['settings'] = function(self, index)
		--no need for index
		return self.gameDatabase['settings']
	end,
	
	--...
}

function GameDatabaseSystem:writeToDatabase(tableId, object)
	self.writeToDatabaseMethods[tableId](self, object)
end

GameDatabaseSystem.writeToDatabaseMethods = {
	['generic_table'] = function(self, object)
		--for testing purposes: object is the single player entity
		
		local row = self:getDatabaseRow('generic_table', object.components.main.id)
		
		--save player position to database
		row.x = object.components.hitbox.x
		row.y = object.components.hitbox.y
	end,
	
	['generic_entity'] = function(self, object)
		--EXAMPLE:
		local index = object.components.main.id
		local row = self:getDatabaseRow(tableId, index)
		--write from object -> row
	end,
	
	['settings'] = function(self, object)
		
	end,
	
	--...
}

function GameDatabaseSystem:runQuery(query)
	self.runQueryMethods[query.queryType](self, query)
end

GameDatabaseSystem.runQueryMethods = {
	[GameDatabaseSystem.QUERY.GENERIC] = function(self, query)
		--get *
		--run callback(results)
		--test stuff
		
		local entityList = self.gameDatabase[query.queryParameters.tableId]
		query.responseCallback(entityList)
	end
	
	--...
}

----------------
--Return Module:
----------------

return GameDatabaseSystem