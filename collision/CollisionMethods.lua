--contains polygon collision calc methods
--function arguments are not bundled into objects - this is intentional

local CollisionMethods = {}

function CollisionMethods:pointToRectDetection(pointX, pointY, rectX, rectY, rectRight, rectBottom)
	if pointX < rectX then
		return false
	elseif pointX > rectRight then
		return false
	elseif pointY < rectY then
		return false
	elseif pointY > rectBottom then
		return false
	else
		return true
	end
end

function CollisionMethods:lineToRectDetection(lineStartX, lineStartY, lineEndX, lineEndY, rectX, 
	rectY, rectRight, rectBottom)
	
	local dotProductStart = (lineStartX - rectX)*(rectRight - rectX)
	local dotProductEnd = (lineEndX - rectX)*(rectRight - rectX)
	local distanceSquared = (rectRight - rectX)^2
	
	if dotProductStart < 0 and dotProductEnd < 0 then
		return false
	elseif dotProductStart > distanceSquared and dotProductEnd > distanceSquared then
		return false
	end
	
	dotProductStart = (lineStartY - rectY)*(rectBottom - rectY)
	dotProductEnd = (lineEndY - rectY)*(rectBottom - rectY)
	distanceSquared = (rectBottom - rectY)^2
	
	if dotProductStart < 0 and dotProductEnd <0 then
		return false
	elseif dotProductStart > distanceSquared and dotProductEnd > distanceSquared then
		return false
	end
	
	return true
end

function CollisionMethods:circleToCircleDetection(centerAX, centerAY, radiusA, centerBX, centerBY, radiusB)
	return (radiusA + radiusB)^2 > ((centerBX - centerAX)^2 + (centerBY - centerAY)^2)
end

function CollisionMethods:rectToRectDetection(aX, aY, aRight, aBottom, bX, bY, bRight, bBottom)
	if aBottom <= bY then
		return false
	elseif aY >= bBottom then
		return false
	elseif aRight <= bX then
		return false
	elseif aX >= bRight then
		return false
	else
		return true
	end
end

function CollisionMethods:rectToRectResolution(aX, aY, aRight, aBottom, bX, bY, bRight, bBottom)
	local mtvX, mtvY = 0, 0
	
	if aX <= bX then
		mtvX = aRight - bX
	else
		mtvX = aX - bRight
	end
	
	if aY <= bY then
		mtvY = aBottom - bY
	else
		mtvY = aY - bBottom
	end
	
	if math.abs(mtvX) <= math.abs(mtvY) then
		mtvY = 0
	else
		mtvX = 0
	end
	
	return mtvX, mtvY
end

return CollisionMethods