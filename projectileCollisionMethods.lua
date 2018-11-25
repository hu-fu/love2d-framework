--module for the collision system

local projectileCollisionMethods = {}

projectileCollisionMethods.SHAPE_TYPES = require 'SHAPE_TYPE'

projectileCollisionMethods.collisionDetectionMethods = {
	[projectileCollisionMethods.SHAPE_TYPES.RECT] = {
		[projectileCollisionMethods.SHAPE_TYPES.POINT] = function(entityA, entityB)
		
		end,
		
		[projectileCollisionMethods.SHAPE_TYPES.LINE] = function(entityA, entityB)
		
		end,
		
		[projectileCollisionMethods.SHAPE_TYPES.CIRCLE] = function(entityA, entityB)
		
		end,
		
		[projectileCollisionMethods.SHAPE_TYPES.RECT] = function(entityA, entityB)
		
		end
	}
}

return projectileCollisionMethods