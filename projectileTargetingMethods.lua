local projectileTargetingMethods = {}

projectileTargetingMethods.ENTITY_TYPES = require '/entity/ENTITY_TYPE'

function projectileTargetingMethods:getDistanceToTarget(x, y, targetEntity, targetEntityType)
	return self.getDistanceToTargetMethods[targetEntityType](x, y, targetEntity)
end

projectileTargetingMethods.getDistanceToTargetMethods = {
	[projectileTargetingMethods.ENTITY_TYPES.GENERIC_ENTITY] = function(x, y, targetEntity)
		
	end,
	
	--...
}

function projectileTargetingMethods:getAngleToTarget(x, y, targetEntity, targetEntityType)
	return self.getAngleToTargetMethods[targetEntityType](x, y, targetEntity)
end

projectileTargetingMethods.getAngleToTargetMethods = {
	[projectileTargetingMethods.ENTITY_TYPES.GENERIC_ENTITY] = function(x, y, targetEntity)
		
	end,
	
	--...
}

return projectileTargetingMethods