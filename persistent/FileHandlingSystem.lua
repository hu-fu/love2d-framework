local FileHandlingSystem = {}

---------------
--Dependencies:
---------------

local SYSTEM_ID = require '/system/SYSTEM_ID'
FileHandlingSystem.TABLES = require '/persistent/DATABASE_TABLE'
FileHandlingSystem.JSON_ENCODE = require '/json/json'

-------------------
--System Variables:
-------------------

FileHandlingSystem.id = SYSTEM_ID.FILE_HANDLING

FileHandlingSystem.saveFolderName = 'love_save_data'
FileHandlingSystem.settingsFileName = 'settings.txt'

---------------
--Init Methods:
---------------

function FileHandlingSystem:init()
	--build paths
	love.filesystem.setIdentity(self.saveFolderName, false)
end

----------------
--Event Methods:
----------------

FileHandlingSystem.eventMethods = {
	
	[1] = {
		[1] = function(request)
			--save file
		end,
		
		[2] = function(request)
			--load file
		end
	}
}

---------------
--Exec Methods:
---------------

function FileHandlingSystem:getFile(tableId, fileName)
	return self.getFileMethods[tableId](self, fileName)
end

FileHandlingSystem.getFileMethods = {
	['generic_table'] = function(self, fileName)
		local contents, size = love.filesystem.read(fileName, all)
		return contents
	end,
	
	['generic_entity'] = function(self, filename)
		--EXAMPLE
		--in this case the file for the generic entity is the same as the file for the area
		--solution: both methods do the same
		--return the same file in both methods
		return nil
	end,
	
	['settings'] = function(self, filename)
		--return settings file contents as string
		local contents, size = love.filesystem.read(self.settingsFileName, all)
		return contents
	end,
	
	--...
}

function FileHandlingSystem:writeFile(tableId, fileName, fileBody)
	self.writeFileMethods[tableId](self, fileName, fileBody)
end

FileHandlingSystem.writeFileMethods = {
	['generic_table'] = function(self, fileName, fileBody)
		love.filesystem.newFile(fileName)
		love.filesystem.write(fileName, fileBody, all)
		return nil
	end,
	
	['generic_entity'] = function(self, fileName, fileBody)
		--EXAMPLE
		--in this case the file for the generic entity is the same as the file for the area
		--solution: both methods do the same
		--write file and overwrite if it already exists
		return nil
	end,
	
	['settings'] = function(self, filename, fileBody)
		love.filesystem.newFile(self.settingsFileName)
		love.filesystem.write(self.settingsFileName, fileBody, all)
		return nil
	end,
}

----------------
--Return Module:
----------------

return FileHandlingSystem