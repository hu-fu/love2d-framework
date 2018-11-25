local projectileTargetingMethods = {}

function projectileTargetingMethods:getDirectionToTarget(x, y, targetEntity)
	--TODO: needs to account for target direction and speed
	local targetX, targetY = (targetEntity.x + targetEntity.w/2), (targetEntity.y + targetEntity.h/2)
	return math.atan2((targetY - y),(targetX - x))*-1
end

function projectileTargetingMethods:getDistanceToTarget(x, y, targetEntity)
	
end

function projectileTargetingMethods:getAngleToTarget(x, y, targetEntity)
	
end

return projectileTargetingMethods