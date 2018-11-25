--module for the spatial partitioning system

local projectileSpatialIndexing = {}

projectileSpatialIndexing.SHAPE_TYPES = require 'SHAPE_TYPE'

function projectileSpatialIndexing:indexProjectile(spatialEntity, grid, entityRole)
	self.indexingMethods[spatialEntity.parentEntity.hitboxShape](spatialEntity, grid, entityRole)
end

projectileSpatialIndexing.indexingMethods = {
	[projectileSpatialIndexing.SHAPE_TYPES.POINT] = function(spatialEntity, grid, entityRole)
	
	end,
	
	[projectileSpatialIndexing.SHAPE_TYPES.LINE] = function(spatialEntity, grid, entityRole)
	
	end,
	
	[projectileSpatialIndexing.SHAPE_TYPES.CIRCLE] = function(spatialEntity, grid, entityRole)
	
	end,
	
	[projectileSpatialIndexing.SHAPE_TYPES.RECT] = function(spatialEntity, grid, entityRole)
	
	end
}

function projectileSpatialIndexing:updateProjectile(spatialEntity, grid)
	self.updateMethods[spatialEntity.parentEntity.hitboxShape](spatialEntity, grid)
end

projectileSpatialIndexing.updateMethods = {
	[projectileSpatialIndexing.SHAPE_TYPES.POINT] = function(spatialEntity, grid)
	
	end,
	
	[projectileSpatialIndexing.SHAPE_TYPES.LINE] = function(spatialEntity, grid)
	
	end,
	
	[projectileSpatialIndexing.SHAPE_TYPES.CIRCLE] = function(spatialEntity, grid)
	
	end,
	
	[projectileSpatialIndexing.SHAPE_TYPES.RECT] = function(spatialEntity, grid)
	
	end
}

function projectileSpatialIndexing:unregisterProjectile(spatialEntity, grid)
	self.unregisterMethods[spatialEntity.parentEntity.hitboxShape](spatialEntity, grid)
end

projectileSpatialIndexing.unregisterMethods = {
	[projectileSpatialIndexing.SHAPE_TYPES.POINT] = function(spatialEntity, grid)
	
	end,
	
	[projectileSpatialIndexing.SHAPE_TYPES.LINE] = function(spatialEntity, grid)
	
	end,
	
	[projectileSpatialIndexing.SHAPE_TYPES.CIRCLE] = function(spatialEntity, grid)
	
	end,
	
	[projectileSpatialIndexing.SHAPE_TYPES.RECT] = function(spatialEntity, grid)
	
	end
}

return projectileSpatialIndexing