------------------
--misc. functions:
------------------
--All the table functions only work with tables with numerical indices

function checkTable (value, t)
--check if value belongs to table t

	for i = 1, #t do
		if t[i] == value then
			return true
		end
	end
	
	return false
end

function getIndex (value, t)
--check if value belongs to table t, and returns index of value
	
	for i = 1, #t do
		if t[i] == value then
			return i
		end
	end

	return false
end

function reverseTable (t)
--returns table t reversed

	local reverse_t = {}
		
	for i = 1, #t do
		table.insert(reverse_t, t[(#t+1)-i])
	end
	
	return reverse_t
end

function setDefaultTableValue (t, d)
--t = table, d = default value to t
	local mt = {__index = function (t) return t.___ end}
	t.___ = d
	setmetatable(t, mt)
end

function collect_keys(t, sort)
	local _k = {}
	for k in pairs(t) do
		_k[#_k+1] = k
	end
	table.sort(_k, sort)
	return _k
end

function sortedPairs(t, sort)
	local keys = collect_keys(t, sort)
	local i = 0
	return function()
		i = i+1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

function resetTable(t)
	for k,v in pairs(t) do
		t[k] = nil
	end
end

function getAngle(aX, aY, bX, bY)
	local xDiff = bX - aX
	local yDiff = bY - aY
	return math.deg(math.atan2(yDiff, xDiff))
end

function getDistanceSquaredBetweenPoints(aX, aY, bX, bY)
	return math.ceil(math.abs((aX - (bX))^2 + (aY - (bY))^2))
end