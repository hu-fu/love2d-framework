--[[
]]

local areaLoader = {}

-------
--Path:
-------

local AREA_FOLDER = '/data/area/'

local areaFilePath = {
	[1] = 'test_area',
	[2] = 'test_area_B'
}

----------
--Methods:
----------

function areaLoader:getAreaFile(id)
	local filePath = AREA_FOLDER .. areaFilePath[id]
	local areaFile = require (filePath)
	return areaFile
end

----------------
--Return module:
----------------

return areaLoader