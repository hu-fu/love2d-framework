----------------------
--Map Collider Module:
----------------------
--Absolutely deprecated (good riddance).

local mapCollisionSystem = {}

-------------------
--Static Variables:
-------------------

local BASIC_COLLISION = 1			--checks one vertex, use if HB is very small
local INTERMEDIATE_COLLISION = 2	--checks all vertexes, cancels movement if any tile is collidable
local ADVANCED_COLLISION = 3		--checks all vertexes, aligns HB with tile sides, allows sliding

local HITBOX_TABLE_PARENT_1 = 1
local HITBOX_TABLE_SPRITEBOX_INDEX = 2
local HITBOX_TABLE_X = 3
local HITBOX_TABLE_Y = 4
local HITBOX_TABLE_W = 5
local HITBOX_TABLE_H = 6
local HITBOX_TABLE_MAP_COLLISION_TYPE = 7
local HITBOX_TABLE_ENTITY_COLLISION_TYPE = 8

-------------------
--System Variables:
-------------------

mapCollisionSystem.tileW = 0
mapCollisionSystem.tileH = 0
mapCollisionSystem.tileLayer1 = {}
mapCollisionSystem.tileLayer2 = {}

---------------
--Init Methods:
---------------

function mapCollisionSystem:setAreaMapVariables(areaMap)
	self.tileW = areaMap.tileW
	self.tileH = areaMap.tileH
	self.tileLayer1 = areaMap.tileLayer1
	self.tileLayer2 = areaMap.tileLayer2	--ignore for now
end

---------------
--Exec Methods:
---------------

function mapCollisionSystem:entityCollisionCheck(hitBoxRow, direction, incrementX, incrementY)
	if hitBoxRow[HITBOX_TABLE_MAP_COLLISION_TYPE] then
		return mapCollisionSystem.entityCollisionMethods[hitBoxRow[HITBOX_TABLE_MAP_COLLISION_TYPE]][direction](hitBoxRow, incrementX, incrementY)
	else
		return incrementX, incrementY
	end
end

function mapCollisionSystem:getTileMapIndex(x, y)
	local indexX = math.ceil(x/self.tileW)
	local indexY = math.ceil(y/self.tileH)
	return indexX, indexY
end

mapCollisionSystem.entityCollisionMethods = {
	[BASIC_COLLISION] = {
		[1] = function (hitBoxRow, incrementX, incrementY)
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(hitBoxRow[HITBOX_TABLE_X] + 
				incrementX, hitBoxRow[HITBOX_TABLE_Y] + incrementY)
			
			if mapCollisionSystem.tileLayer1[topLeftIndexY][topLeftIndexX].collision == 2 then
				return incrementX, 0
			end
			
			return incrementX, incrementY
		end,
		
		[2] = function (hitBoxRow, incrementX, incrementY)
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(hitBoxRow[HITBOX_TABLE_X] + 
				incrementX, hitBoxRow[HITBOX_TABLE_Y] + incrementY)
			
			if mapCollisionSystem.tileLayer1[topLeftIndexY][topLeftIndexX].collision == 2 then
				return 0, 0
			end
			
			return incrementX, incrementY
		end,
		
		[3] = function (hitBoxRow, incrementX, incrementY)
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(hitBoxRow[HITBOX_TABLE_X] + 
				incrementX, hitBoxRow[HITBOX_TABLE_Y] + incrementY)
			
			if mapCollisionSystem.tileLayer1[topLeftIndexY][topLeftIndexX].collision == 2 then
				return 0, incrementY
			end
			
			return incrementX, incrementY
		end,
		
		[4] = function (hitBoxRow, incrementX, incrementY)
			local bottomLeftIndexX, bottomLeftIndexY = mapCollisionSystem:getTileMapIndex(hitBoxRow[HITBOX_TABLE_X] + 
				incrementX, hitBoxRow[HITBOX_TABLE_Y] + hitBoxRow[HITBOX_TABLE_H] + incrementY)
			
			if mapCollisionSystem.tileLayer1[bottomLeftIndexY][bottomLeftIndexX].collision == 2 then
				return 0, 0
			end
			
			return incrementX, incrementY
		end,
		
		[5] = function (hitBoxRow, incrementX, incrementY)
			local bottomLeftIndexX, bottomLeftIndexY = mapCollisionSystem:getTileMapIndex(hitBoxRow[HITBOX_TABLE_X] + 
				incrementX, hitBoxRow[HITBOX_TABLE_Y] + hitBoxRow[HITBOX_TABLE_H] + incrementY)
			
			if mapCollisionSystem.tileLayer1[bottomLeftIndexY][bottomLeftIndexX].collision == 2 then
				return incrementX, 0
			end
			
			return incrementX, incrementY
		end,
		
		[6] = function (hitBoxRow, incrementX, incrementY)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(hitBoxRow[HITBOX_TABLE_X] + 
				hitBoxRow[HITBOX_TABLE_W] + incrementX, hitBoxRow[HITBOX_TABLE_Y] + hitBoxRow[HITBOX_TABLE_H] + incrementY)
			
			if mapCollisionSystem.tileLayer1[bottomRightIndexY][bottomRightIndexX].collision == 2 then
				return 0, 0
			end
			
			return incrementX, incrementY
		end,
		
		[7] = function (hitBoxRow, incrementX, incrementY)
			local topRightIndexX, topRightIndexY = mapCollisionSystem:getTileMapIndex(hitBoxRow[HITBOX_TABLE_X] + 
				hitBoxRow[HITBOX_TABLE_W] + incrementX, hitBoxRow[HITBOX_TABLE_Y] + incrementY)
			
			if mapCollisionSystem.tileLayer1[topRightIndexY][topRightIndexX].collision == 2 then
				return 0, incrementY
			end
			
			return incrementX, incrementY
		end,
		
		[8] = function (hitBoxRow, incrementX, incrementY)
			local topRightIndexX, topRightIndexY = mapCollisionSystem:getTileMapIndex(hitBoxRow[HITBOX_TABLE_X] + 
				hitBoxRow[HITBOX_TABLE_W] + incrementX, hitBoxRow[HITBOX_TABLE_Y] + incrementY)
			
			if mapCollisionSystem.tileLayer1[topRightIndexY][topRightIndexX].collision == 2 then
				return 0, 0
			end
			
			return incrementX, incrementY
		end
	},
	
	[INTERMEDIATE_COLLISION] = {
		[1] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX, 
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexX, bottomRightIndexX do
				if mapCollisionSystem.tileLayer1[topLeftIndexY][i].collision == 2 then
					return incrementX, 0
				end
			end
			
			return incrementX, incrementY
		end,
		
		[2] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX, 
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexX, bottomRightIndexX do
				if mapCollisionSystem.tileLayer1[topLeftIndexY][i].collision == 2 then
					return 0, 0
				end
			end
			
			for i = topLeftIndexY, bottomRightIndexY do
				if mapCollisionSystem.tileLayer1[i][topLeftIndexX].collision == 2 then
					return 0, 0
				end
			end
			
			return incrementX, incrementY
		end,
		
		[3] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX,
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexY, bottomRightIndexY do
				if mapCollisionSystem.tileLayer1[i][topLeftIndexX].collision == 2 then
					return 0, incrementY
				end
			end
			
			return incrementX, incrementY
		end,
		
		[4] = function (hitBoxRow, incrementX, incrementY)
			
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX,
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexX, bottomRightIndexX do
				if mapCollisionSystem.tileLayer1[bottomRightIndexY][i].collision == 2 then
					return 0, 0
				end
			end
			
			for i = topLeftIndexY, bottomRightIndexY do
				if mapCollisionSystem.tileLayer1[i][topLeftIndexX].collision == 2 then
					return 0, 0
				end
			end
			
			return incrementX, incrementY
		end,
		
		[5] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX,
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexX, bottomRightIndexX do
				if mapCollisionSystem.tileLayer1[bottomRightIndexY][i].collision == 2 then
					return incrementX, 0
				end
			end
			
			return incrementX, incrementY
		end,
		
		[6] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX,
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexX, bottomRightIndexX do
				if mapCollisionSystem.tileLayer1[bottomRightIndexY][i].collision == 2 then
					return 0, 0
				end
			end
			
			for i = topLeftIndexY, bottomRightIndexY do
				if mapCollisionSystem.tileLayer1[i][bottomRightIndexX].collision == 2 then
					return 0, 0
				end
			end
			
			return incrementX, incrementY
		end,
		
		[7] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX,
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexY, bottomRightIndexY do
				if mapCollisionSystem.tileLayer1[i][bottomRightIndexX].collision == 2 then
					return 0, incrementY
				end
			end
			
			return incrementX, incrementY
		end,
		
		[8] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX,
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexX, bottomRightIndexX do
				if mapCollisionSystem.tileLayer1[topLeftIndexY][i].collision == 2 then
					return 0, 0
				end
			end
			
			for i = topLeftIndexY, bottomRightIndexY do
				if mapCollisionSystem.tileLayer1[i][bottomRightIndexX].collision == 2 then
					return 0, 0
				end
			end
			
			return incrementX, incrementY
		end
	},
	
	[ADVANCED_COLLISION] = {
		[1] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX, 
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexX, bottomRightIndexX do
				if mapCollisionSystem.tileLayer1[topLeftIndexY][i].collision == 2 then
					incrementY = math.ceil((mapCollisionSystem.tileLayer1[topLeftIndexY][i].y + mapCollisionSystem.tileH) - 
						hitBoxRow[HITBOX_TABLE_Y] + 1)
					break
				end
			end
			
			return incrementX, incrementY
		end,
		
		[2] = function (hitBoxRow, incrementX, incrementY)
		
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX, 
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			local pathY, pathX = bottomRightIndexX - topLeftIndexX + 1, bottomRightIndexY - topLeftIndexY + 1
			
			for i = bottomRightIndexX, topLeftIndexX, -1 do
				if mapCollisionSystem.tileLayer1[topLeftIndexY][i].collision == 2 then
					incrementY = math.ceil((mapCollisionSystem.tileLayer1[topLeftIndexY][i].y + mapCollisionSystem.tileH) - 
						hitBoxRow[HITBOX_TABLE_Y] + 1)
					break
				end
				pathY = pathY - 1
			end
			
			for i = bottomRightIndexY, topLeftIndexY, -1 do
				if mapCollisionSystem.tileLayer1[i][topLeftIndexX].collision == 2 then
					incrementX = math.ceil((mapCollisionSystem.tileLayer1[i][topLeftIndexX].x + mapCollisionSystem.tileW) - 
						hitBoxRow[HITBOX_TABLE_X] + 1)
					break
				end
				pathX = pathX - 1
			end
			
			if pathY == 0 then
				--no collision on top
			elseif pathY == 1 then
				if pathX == 1 then
					--corner collision
					if incrementY >= incrementX then
						incrementY = y - hitBoxRow[HITBOX_TABLE_Y]
					else
						incrementX = x - hitBoxRow[HITBOX_TABLE_X]
					end
				else
					--collision on the left side
					incrementY = y - hitBoxRow[HITBOX_TABLE_Y]
				end
			else
				if pathX > 1 then
					--both paths blocked
				else
					--collision on top
					incrementX = x - hitBoxRow[HITBOX_TABLE_X]
				end
			end
			
			return incrementX, incrementY
		end,
		
		[3] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX, 
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexY, bottomRightIndexY do
				if mapCollisionSystem.tileLayer1[i][topLeftIndexX].collision == 2 then
					incrementX = math.ceil((mapCollisionSystem.tileLayer1[i][topLeftIndexX].x + mapCollisionSystem.tileW) - 
						hitBoxRow[HITBOX_TABLE_X] + 1)
					break
				end
			end
			
			return incrementX, incrementY
		end,
		
		[4] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX, 
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			local pathY, pathX = bottomRightIndexX - topLeftIndexX + 1, bottomRightIndexY - topLeftIndexY + 1
			
			for i = bottomRightIndexX, topLeftIndexX, -1 do
				if mapCollisionSystem.tileLayer1[bottomRightIndexY][i].collision == 2 then
					incrementY = math.ceil((hitBoxRow[HITBOX_TABLE_Y] + hitBoxRow[HITBOX_TABLE_H]) - 
						mapCollisionSystem.tileLayer1[bottomRightIndexY][i].y)*-1
					break
				end
				pathY = pathY - 1
			end
			
			for i = topLeftIndexY, bottomRightIndexY do
				if mapCollisionSystem.tileLayer1[i][topLeftIndexX].collision == 2 then
					incrementX = math.ceil((mapCollisionSystem.tileLayer1[i][topLeftIndexX].x + mapCollisionSystem.tileW) - 
						hitBoxRow[HITBOX_TABLE_X] + 1)
					break
				end
				pathX = pathX - 1
			end
			
			if pathY == 0 then
			
			elseif pathY == 1 then
				if pathX == 1 then
					if math.abs(incrementY) >= incrementX then
						incrementY = y - hitBoxRow[HITBOX_TABLE_Y]
					else
						incrementX = x - hitBoxRow[HITBOX_TABLE_X]
					end
				else
					incrementY = y - hitBoxRow[HITBOX_TABLE_Y]
				end
			else
				if pathX > 1 then
				else
					incrementX = x - hitBoxRow[HITBOX_TABLE_X]
				end
			end
			
			return incrementX, incrementY
		end,
		
		[5] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX, 
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexX, bottomRightIndexX do
				if mapCollisionSystem.tileLayer1[bottomRightIndexY][i].collision == 2 then
					incrementY = math.ceil((hitBoxRow[HITBOX_TABLE_Y] + hitBoxRow[HITBOX_TABLE_H]) - 
						mapCollisionSystem.tileLayer1[bottomRightIndexY][i].y)*-1
					break
				end
			end
			
			return incrementX, incrementY
		end,
		
		[6] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX, 
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			local pathY, pathX = bottomRightIndexX - topLeftIndexX + 1, bottomRightIndexY - topLeftIndexY + 1
			
			for i = topLeftIndexX, bottomRightIndexX do
				if mapCollisionSystem.tileLayer1[bottomRightIndexY][i].collision == 2 then
					incrementY = math.ceil((hitBoxRow[HITBOX_TABLE_Y] + hitBoxRow[HITBOX_TABLE_H]) - 
						mapCollisionSystem.tileLayer1[bottomRightIndexY][i].y)*-1
					break
				end
				pathY = pathY - 1
			end
			
			for i = topLeftIndexY, bottomRightIndexY do
				if mapCollisionSystem.tileLayer1[i][bottomRightIndexX].collision == 2 then
					incrementX = math.ceil((hitBoxRow[HITBOX_TABLE_X] + hitBoxRow[HITBOX_TABLE_W]) - 
						mapCollisionSystem.tileLayer1[i][bottomRightIndexX].x)*-1
					break
				end
				pathX = pathX - 1
			end
			
			if pathY == 0 then
			
			elseif pathY == 1 then
				if pathX == 1 then
					if incrementY <= incrementX then
						incrementY = y - hitBoxRow[HITBOX_TABLE_Y]
					else
						incrementX = x - hitBoxRow[HITBOX_TABLE_X]
					end
				else
					incrementY = y - hitBoxRow[HITBOX_TABLE_Y]
				end
			else
				if pathX > 1 then
				else
					incrementX = x - hitBoxRow[HITBOX_TABLE_X]
				end
			end
			
			return incrementX, incrementY
		end,
		
		[7] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX, 
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			for i = topLeftIndexY, bottomRightIndexY do
				if mapCollisionSystem.tileLayer1[i][bottomRightIndexX].collision == 2 then
					incrementX = math.ceil((hitBoxRow[HITBOX_TABLE_X] + hitBoxRow[HITBOX_TABLE_W]) - 
						mapCollisionSystem.tileLayer1[i][bottomRightIndexX].x)*-1
					break
				end
			end
			
			return incrementX, incrementY
		end,
		
		[8] = function (hitBoxRow, incrementX, incrementY)
			local x, y = hitBoxRow[HITBOX_TABLE_X] + incrementX, 
				hitBoxRow[HITBOX_TABLE_Y] + incrementY
			local topLeftIndexX, topLeftIndexY = mapCollisionSystem:getTileMapIndex(x, y)
			local bottomRightIndexX, bottomRightIndexY = mapCollisionSystem:getTileMapIndex(x + hitBoxRow[HITBOX_TABLE_W],
				y + hitBoxRow[HITBOX_TABLE_H])
			
			local pathY, pathX = bottomRightIndexX - topLeftIndexX + 1, bottomRightIndexY - topLeftIndexY + 1
			
			for i = topLeftIndexX, bottomRightIndexX do
				if mapCollisionSystem.tileLayer1[topLeftIndexY][i].collision == 2 then
					incrementY = math.ceil((mapCollisionSystem.tileLayer1[topLeftIndexY][i].y + mapCollisionSystem.tileH) - 
						hitBoxRow[HITBOX_TABLE_Y] + 1)
					break
				end
				pathY = pathY - 1
			end
			
			for i = bottomRightIndexY, topLeftIndexY, -1 do
				if mapCollisionSystem.tileLayer1[i][bottomRightIndexX].collision == 2 then
					incrementX = math.ceil((hitBoxRow[HITBOX_TABLE_X] + hitBoxRow[HITBOX_TABLE_W]) - 
						mapCollisionSystem.tileLayer1[i][bottomRightIndexX].x)*-1
					break
				end
				pathX = pathX - 1
			end
			
			if pathY == 0 then
			
			elseif pathY == 1 then
				if pathX == 1 then
					if incrementY >= math.abs(incrementX) then
						incrementY = y - hitBoxRow[HITBOX_TABLE_Y]
					else
						incrementX = x - hitBoxRow[HITBOX_TABLE_X]
					end
				else
					incrementY = y - hitBoxRow[HITBOX_TABLE_Y]
				end
			else
				if pathX > 1 then
				else
					incrementX = x - hitBoxRow[HITBOX_TABLE_X]
				end
			end
			
			return incrementX, incrementY
		end
	}
}

mapCollisionSystem.projectileCollisionMethods = {
	--just an idea...
}

----------------
--Return Module:
----------------

return mapCollisionSystem