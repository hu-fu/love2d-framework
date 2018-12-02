--------------------------
--Area Load System Module:
--------------------------
--This is just a rough sketch
--This system uses services such as 'areaLoader' to fetch assets, injecting them into the simulation
--A class + singleton is fine too
--There has to be a state 'manager' system telling which area to load
--IMPORTANT: new object instances created here must be 'returned'; you can't set them to external vars
--THIS IS JUST FOR TESTING, EVERYTHING ABOUT THIS MUST BE CHANGED!!!

local areaLoader = require 'areaLoader'
local spritesheetLoader = require 'spritesheetLoader'

local areaLoadSystem = {}

----------
--Methods:
----------

--[[
1.save map state
2.remove previous entities/map from memory
]]

function areaLoadSystem:setAreaId(id)
	self.areaId = id
end

function areaLoadSystem:setAreaFile()
	if self.areaId then
		self.areaFile = areaLoader:getAreaFile(self.areaId)
	end
end

function areaLoadSystem:updateAreaMap(currentAreaMap)
	if self.areaFile then
		currentAreaMap.maxX = self.areaFile.maxX
		currentAreaMap.maxY = self.areaFile.maxY
		currentAreaMap.tileW = self.areaFile.tileW
		currentAreaMap.tileH = self.areaFile.tileH
		currentAreaMap:createTileLayer1(self.areaFile.layer1Quad, self.areaFile.layer1Collision)
		currentAreaMap:createTileLayer2(self.areaFile.layer2Quad, self.areaFile.layer2Collision)
	end
end

function areaLoadSystem:registerAreaSpatialInfo(spatialPartitioningSystem)
	if self.areaFile then
		--should be via message system but whatever
		spatialPartitioningSystem:addArea(areaFile, true)
	end
end

function areaLoadSystem:updatePlayerCamera(playerCamera)
	--I really dont know. Get the 'player entity' values and tie them to the camera
	--Or just get the starting camera position/state from the area file.
	playerCamera.x = 0
	playerCamera.y = 0
end

function areaLoadSystem:updateAreaRenderer(areaRenderer, currentAreaMap, playerCamera)
	--more like 'setNewAreaInfoOnRenderer'
	--do it in a way that doesn't require a full reset of the renderer object
	--this suxx
	if self.areaFile then
		local tileSpritesheet = spritesheetLoader:loadTileSpritesheet(self.areaId)
		local quads = spritesheetLoader:loadTileSpritesheetQuads(self.areaId)
		local layer1Length = #currentAreaMap.tileLayer1
		local layer2Length = #currentAreaMap.tileLayer2
		local indexX = math.floor(playerCamera.x/currentAreaMap.tileW)+1
		local indexY = math.floor(playerCamera.y/currentAreaMap.tileH)+1
		local nTilesX = math.ceil(playerCamera.w/currentAreaMap.tileW)+1
		local nTilesY = math.ceil(playerCamera.h/currentAreaMap.tileH)+1
		local tileW = currentAreaMap.tileW
		local tileH = currentAreaMap.tileH
		areaRenderer:fullReset()
		areaRenderer:setTileSpritesheet(tileSpritesheet)
		areaRenderer:setTileSpritesheetQuads(quads)
		areaRenderer:setTileLayer1(currentAreaMap.tileLayer1)
		areaRenderer:setTileLayer2(currentAreaMap.tileLayer2)
		areaRenderer:createSpriteBatch1(layer1Length, indexX, indexY, nTilesX, nTilesY, tileW, tileH)
		areaRenderer:createSpriteBatch2(layer2Length, indexX, indexY, nTilesX, nTilesY, tileW, tileH)
		--(...)
	end
end

function areaLoadSystem:createEntities(entityTables)
	if self.areaFile then
		for i, rows in ipairs(self.areaFile.entities) do
			self:updateEntityTable(entityTables[i])
		end
	end
end

function areaLoadSystem:updateEntityTable(entityTable)
	local incrementValue = #entityTable.rows
	for i, link in pairs(entityTable.childLinks) do
		self:incrementParentColumns(link.childTableReference.id, link.childTableColumnNumber, incrementValue)
	end
	for i, row in ipairs(self.areaFile.entities[entityTable.id]) do
		entityTable:createRow(row)
	end
end

function areaLoadSystem:incrementParentColumns(tableId, columnNumber, incrementValue)
	if self.areaFile.entities[tableId] then
		for i, row in ipairs(self.areaFile.entities[tableId]) do
			row[columnNumber] = row[columnNumber] + incrementValue
		end
	end
end

function areaLoadSystem:setEntitySpritesheet(id, areaRenderer)
	--[[
		--doesn't work because of the default table values
		--but we need some kind of control, or else we'll be loading the same spritesheets every scene
		--add to the "to do" list
	]]
	--if areaRenderer:getEntitySpritesheet(id) == false then
		areaRenderer.entitySpritesheet[id] = spritesheetLoader:loadEntitySpritesheet(id)
	--end
end

function areaLoadSystem:setEntitySpritesheetQuads(id, areaRenderer)
	--if areaRenderer:getEntitySpritesheetQuads(id) == false then
		areaRenderer.entitySpritesheetQuads[id] = spritesheetLoader:loadEntitySpritesheetQuads(id)
	--end
end

function areaLoadSystem:setEntitySprites(areaRenderer)
	if self.areaFile then
		for i=1, #self.areaFile.entitySpritesheetIdList do
			self:setEntitySpritesheet(self.areaFile.entitySpritesheetIdList[i], areaRenderer)
			self:setEntitySpritesheetQuads(self.areaFile.entitySpritesheetIdList[i], areaRenderer)
		end
	end
end

function areaLoadSystem:setProjectileSprites(areaRenderer)
	--for testing (i == id). This loads everything.
	for i=1, 1 do
		areaRenderer.projectileSpritesheet[i] = spritesheetLoader:loadProjectileSpritesheet(i)
		areaRenderer.projectileSpritesheetQuads[i] = spritesheetLoader:loadProjectileSpritesheetQuads(i)
	end
end

function areaLoadSystem:setEffectSprites(areaRenderer)
	--for testing (i == id). This loads everything.
	for i=1, 1 do
		areaRenderer.effectSpritesheet[i] = spritesheetLoader:loadEffectSpritesheet(i)
		areaRenderer.effectSpritesheetQuads[i] = spritesheetLoader:loadEffectSpritesheetQuads(i)
	end
end

----------------
--Return Module:
----------------

return areaLoadSystem