-----------------
--Map into quads:
-----------------
--it works, but there are plenty of magic numbers in the code. Check it out.
--deprecated but really cool

local mapToQuadsConverter = {}

function mapToQuadsConverter:getMapQuads(areaMap, tileLayer)
	local quadList = {}
	local convertedAreaMap = {}
	
	for i=1, #tileLayer do
		table.insert(convertedAreaMap, {})
		for j=1, #tileLayer[i] do
			table.insert(convertedAreaMap[i], false)
		end
	end
	
	for i=1, #convertedAreaMap do
		for j=1, #convertedAreaMap[i] do
			if tileLayer[i][j].collision == 2 and convertedAreaMap[i][j] == false then
				--get quad
				local mapQuad = self:buildQuad(convertedAreaMap, tileLayer, j, i, areaMap.tileW, areaMap.tileH)
				table.insert(quadList, mapQuad)
			else
				convertedAreaMap[i][j] = true
			end
		end
	end
	
	return quadList
end

function mapToQuadsConverter:buildQuad(convertedAreaMap, tileLayer, xMapIndex, yMapIndex, tileW, tileH)

	local mapQuad = quad.new(xMapIndex, yMapIndex, #tileLayer[yMapIndex] + 1, 0)
	
	mapQuad.h = self:getNumberOfCollideableTilesInColumn(convertedAreaMap, tileLayer, yMapIndex, xMapIndex)
	
	for i=1, mapQuad.h do
		local currentYIndex = yMapIndex + (i-1)
		local rowWidth = self:getNumberOfCollideableTilesInRow(convertedAreaMap[currentYIndex], tileLayer[currentYIndex], xMapIndex)
		if rowWidth < mapQuad.w then
			mapQuad.w = rowWidth
		end
	end
	
	for i=mapQuad.y, mapQuad.y + mapQuad.h - 1 do
		for j=mapQuad.x, mapQuad.x + mapQuad.w - 1 do
			convertedAreaMap[i][j] = true
		end
	end
	
	mapQuad.y = (mapQuad.y*tileH) - tileH
	mapQuad.x = (mapQuad.x*tileW) - tileW
	mapQuad.h = mapQuad.h*64
	mapQuad.w = mapQuad.w*64
	
	return mapQuad
end

function mapToQuadsConverter:getNumberOfCollideableTilesInRow(convertedRow, tileRow, startingIndex)
	local nTiles = 0
	
	for i=startingIndex, #tileRow do
		if tileRow[i].collision == 2 and convertedRow[i] == false then
			nTiles = nTiles + 1
		else
			break
		end
	end
	
	return nTiles
end

function mapToQuadsConverter:getNumberOfCollideableTilesInColumn(convertedAreaMap, tileLayer, startingYIndex, xIndex)
	local nTiles = 0
	
	for i=startingYIndex, #tileLayer do
		if tileLayer[i][xIndex].collision == 2 and convertedAreaMap[i][xIndex] == false then
			nTiles = nTiles + 1
		else
			break
		end
	end
	
	return nTiles
end

return mapToQuadsConverter