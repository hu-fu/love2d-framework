local FileHandlingSystem = {}

---------------
--Dependencies:
---------------

FileHandlingSystem.TABLES = require '/persistent/DATABASE_TABLE'

-------------------
--System Variables:
-------------------

--json save file folder paths:
FileHandlingSystem.genericFilePath = ''

---------------
--Init Methods:
---------------

function FileHandlingSystem:init()
	
end

---------------
--Exec Methods:
---------------

function FileHandlingSystem:getAllFiles(tableId)
	self.getAllFilesMethods[tableId](self)
end

FileHandlingSystem.getAllFilesMethods = {
	['generic_table'] = function(self)
		
	end,
	
	--...
}

function FileHandlingSystem:getFile(tableId, fileName)
	return self.getFileMethods[tableId](self, fileName)
end

FileHandlingSystem.getFileMethods = {
	['generic_table'] = function(self, fileName)
		--EXAMPLE:
		--fileName = genericname.json -> name it here since its an unique file
		--local path = self.genericFilePath .. fileName
		--local file = love.getfile(path) or something who knows???
		--if file == nil create it, get it again
		--return file (as text string!)
		return ''
	end,
	
	['generic_entity'] = function(self, filename)
		--EXAMPLE
		--in this case the file for the generic entity is the same as the file for the area
		--solution: both methods do the same
		--return the same file in both methods
		return ''
	end,
	
	['settings'] = function(self, filename)
		--return settings file (create new if not found)
		return ''
	end,
	
	--...
}

function FileHandlingSystem:writeFile(tableId, fileName)
	self.writeFileMethods[tableId](self, filename)
end

FileHandlingSystem.writeFileMethods = {
	['generic_table'] = function(self, fileName)
		
	end,
	
	['generic_entity'] = function(self, fileName)
		--EXAMPLE
		--in this case the file for the generic entity is the same as the file for the area
		--solution: both methods do the same
		--write file and overwrite if it already exists
	end,
	
	['settings'] = function(self, filename)
		--what is this?
	end,
}

----------------
--Return Module:
----------------

return FileHandlingSystem