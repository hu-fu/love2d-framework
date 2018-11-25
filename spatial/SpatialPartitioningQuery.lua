------------------------
--Spatial query factory:
------------------------

SpatialQueryBuilder = {}
SpatialQueryBuilder.__index = SpatialQueryBuilder

setmetatable(SpatialQueryBuilder, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialQueryBuilder.new ()
	local self = setmetatable ({}, SpatialQueryBuilder)
		
		self.spatialQueryMethods = {}
		self.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
		
		self:setCreateSpatialQueryMethods()
		self:setSetSpatialQueryParametersMethods()
	return self
end

function SpatialQueryBuilder:createSpatialQuery(queryType)
	local queryObj = SpatialQuery.new(queryType)
	self.createSpatialQueryMethods[queryType](queryObj)
	return queryObj
end

function SpatialQueryBuilder:modifySpatialQuery(queryType, queryObj)
	self:resetSpatialQueryParameters(queryObj)
	queryObj.responseCallback = function() end
	self.createSpatialQueryMethods[queryType](queryObj)
end

function SpatialQueryBuilder:setCreateSpatialQueryMethods()

	self.createSpatialQueryMethods = {
		[self.QUERY_TYPES.UPDATE_ENTITY] = function(spatialQuery)
			spatialQuery.responseCallback = nil
			spatialQuery.entityType = 0
			spatialQuery.entityIndex = 0
		end,
		
		[self.QUERY_TYPES.GET_NEAREST_ENTITY_BY_AREA_AND_ROLE] = function(spatialQuery)
			spatialQuery.responseCallback = nil
			spatialQuery.originEntityType = nil
			spatialQuery.originEntity = nil
			
			spatialQuery.x = 0
			spatialQuery.y = 0
			
			spatialQuery.areaX = 0
			spatialQuery.areaY = 0
			spatialQuery.areaW = 0
			spatialQuery.areaH = 0
			spatialQuery.searchRadius = 0
			
			spatialQuery.targetRoles = nil
			spatialQuery.numberOfResults = 1
		end,
		
		[self.QUERY_TYPES.GET_COLLISION_PAIRS_IN_AREA] = function(spatialQuery)
			spatialQuery.querySubType = 1
			spatialQuery.x = 0
			spatialQuery.y = 0
			spatialQuery.w = 0
			spatialQuery.h = 0
			
			spatialQuery.entityRoleA = 0
			spatialQuery.entityRoleB = 0
			spatialQuery.pairsManager = 0
		end,
		
		[self.QUERY_TYPES.GET_ENTITIES_IN_AREA_FOR_RENDERING] = function(spatialQuery)
			spatialQuery.querySubType = 1	--TODO
			spatialQuery.responseCallback = nil
			spatialQuery.spatialEntityHashtable = nil
			spatialQuery.spatialEntityList = nil
			
			spatialQuery.areaX = 0
			spatialQuery.areaY = 0
			spatialQuery.areaW = 0
			spatialQuery.areaH = 0
			
			spatialQuery.roles = nil
		end,
		
		[self.QUERY_TYPES.REGISTER_ENTITY] = function(spatialQuery)
			spatialQuery.responseCallback = nil
			spatialQuery.areaId = 0
			spatialQuery.entityType = 0
			spatialQuery.entityRole = 0
			spatialQuery.entity = 0
		end,
		
		[self.QUERY_TYPES.GET_ENTITIES_IN_AREA_BY_ROLE_LEGACY] = function(spatialQuery)
			spatialQuery.querySubType = 1	--TODO
			spatialQuery.responseCallback = nil
			spatialQuery.roles = nil
			
			spatialQuery.areaX = 0
			spatialQuery.areaY = 0
			spatialQuery.areaW = 0
			spatialQuery.areaH = 0
		end,
		
		[self.QUERY_TYPES.GET_ENTITIES_IN_AREA_BY_ROLE] = function(spatialQuery)
			spatialQuery.querySubType = 1	--TODO
			spatialQuery.responseCallback = nil
			spatialQuery.hashtable = nil
			spatialQuery.roles = nil
			
			spatialQuery.areaX = 0
			spatialQuery.areaY = 0
			spatialQuery.areaW = 0
			spatialQuery.areaH = 0
		end,
		
		[self.QUERY_TYPES.UNREGISTER_ENTITY] = function(spatialQuery)
			--do not use, just reindex them to an unused role if possible
			spatialQuery.responseCallback = nil
			spatialQuery.entityType = 0
			spatialQuery.entityRole = 0
			spatialQuery.entity = 0
		end,
		
		[self.QUERY_TYPES.REINDEX_ENTITY] = function(spatialQuery)
			spatialQuery.responseCallback = nil
			spatialQuery.entityType = 0
			spatialQuery.entityRole = 0
			spatialQuery.newRole = 0
			spatialQuery.entity = 0
		end
	}
	
end

function SpatialQueryBuilder:setSpatialQueryParameters(spatialQuery, ...)
	self.setSpatialQueryParametersMethods[spatialQuery.queryType](spatialQuery, unpack({...}))
end

function SpatialQueryBuilder:setSetSpatialQueryParametersMethods()
	--shouldn't it set the parameters as spatialQuery.queryParameters.var = var ?
		--lol no kidding. Too late to change that now - the parameters are the new spatial query
		--you can try to fix this if you want - good luck
	
	self.setSpatialQueryParametersMethods = {
		[self.QUERY_TYPES.UPDATE_ENTITY] = function(spatialQuery, ...)
			
		end,
		
		[self.QUERY_TYPES.GET_NEAREST_ENTITY_BY_AREA_AND_ROLE] = function(spatialQuery, originEntityType, 
			originEntityRef, x, y, areaX, areaY, areaW, areaH, searchRadius, targetRoles, 
			numberOfResults)
			
			spatialQuery.originEntityType = originEntityType
			spatialQuery.originEntityRef = originEntityRef
			
			spatialQuery.x = x
			spatialQuery.y = y
			
			spatialQuery.areaX = areaX
			spatialQuery.areaY = areaY
			spatialQuery.areaW = areaW
			spatialQuery.areaH = areaH
			spatialQuery.searchRadius = searchRadius
			
			spatialQuery.targetRoles = targetRoles
			spatialQuery.numberOfResults = numberOfResults
		end,
		
		[self.QUERY_TYPES.GET_ENTITIES_IN_AREA_FOR_RENDERING] = function(spatialQuery, 
			spatialEntityHashtable, spatialEntityList, areaX, areaY, areaW, areaH)
			
			spatialQuery.querySubType = 1	--TODO
			spatialQuery.spatialEntityHashtable = spatialEntityHashtable
			spatialQuery.spatialEntityList = spatialEntityList
			
			spatialQuery.areaX = areaX
			spatialQuery.areaY = areaY
			spatialQuery.areaW = areaW
			spatialQuery.areaH = areaH
		end,
		
		[self.QUERY_TYPES.REGISTER_ENTITY] = function(spatialQuery, areaId, entityType, entityRole, entity)
			spatialQuery.areaId = areaId
			spatialQuery.entityType = entityType
			spatialQuery.entityRole = entityRole
			spatialQuery.entity = entity
		end,
		
		[self.QUERY_TYPES.GET_ENTITIES_IN_AREA_BY_ROLE_LEGACY] = function(spatialQuery, roles, areaX, areaY,
			areaW, areaH)
			spatialQuery.querySubType = 1	--TODO
			spatialQuery.roles = roles
			
			spatialQuery.areaX = areaX
			spatialQuery.areaY = areaY
			spatialQuery.areaW = areaW
			spatialQuery.areaH = areaH
		end,
		
		[self.QUERY_TYPES.GET_ENTITIES_IN_AREA_BY_ROLE] = function(spatialQuery, hashtable, roles, areaX, areaY,
			areaW, areaH)
			spatialQuery.querySubType = 1	--TODO
			spatialQuery.hashtable = hashtable
			spatialQuery.roles = roles
			
			spatialQuery.areaX = areaX
			spatialQuery.areaY = areaY
			spatialQuery.areaW = areaW
			spatialQuery.areaH = areaH
		end,
		
		[self.QUERY_TYPES.UNREGISTER_ENTITY] = function(spatialQuery, areaId, entityType, entityRole, 
			entity)
			spatialQuery.entityType = 0
			spatialQuery.entity = 0
		end
	}
end

function SpatialQueryBuilder:resetSpatialQueryParameters(spatialQuery)
	spatialQuery.queryParameters = {}
end

function SpatialQueryBuilder:setResponseCallback(spatialQuery, method)
	spatialQuery.responseCallback = method
end

---------------------
--Spatial query pool:
---------------------

SpatialQueryPool = {}
SpatialQueryPool.__index = SpatialQueryPool

setmetatable(SpatialQueryPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialQueryPool.new (maxObjects, defaultQueryType, queryBuilderObj, defaultResponseCallback)
	local self = setmetatable ({}, SpatialQueryPool)
		
		self.queryList = {}
		self.currentIndex = 1
		self.defaultMaxObjects = maxObjects
		self.defaultQueryType = defaultQueryType
		self.defaultResponseCallback = defaultResponseCallback
		
		self.queryBuilder = queryBuilderObj
		
		self:buildObjectPool()
	return self
end

function SpatialQueryPool:buildObjectPool()
	for i=1, self.defaultMaxObjects do
		self:createQueryObject(self.defaultQueryType)
	end
end

function SpatialQueryPool:createQueryObject(queryType)
	table.insert(self.queryList, self.queryBuilder:createSpatialQuery(queryType))
	self.queryList[#self.queryList].responseCallback = self.defaultResponseCallback
end

function SpatialQueryPool:getCurrentAvailableObject(queryType)
	--query type is optional, it's set to default if you don't pass it
	local currentQuery = self.queryList[self.currentIndex]
	
	if queryType ~= nil and currentQuery.queryType ~= queryType then
		self.queryBuilder:modifySpatialQuery(queryType, queryObj)
	elseif currentQuery.queryType ~= self.defaultQueryType then
		self.queryBuilder:modifySpatialQuery(self.defaultQueryType, queryObj)
	end
	
	return self.queryList[self.currentIndex]
end

function SpatialQueryPool:getCurrentAvailableObjectDefault()
	--use this ONLY if you just use one type of query in the pool!
	return self.queryList[self.currentIndex]
end

function SpatialQueryPool:resetCurrentIndex()
	self.currentIndex = 1
end

function SpatialQueryPool:incrementCurrentIndex()
	if self.currentIndex == #self.queryList then
		self:createQueryObject(self.defaultQueryType)
	end
	self.currentIndex = self.currentIndex + 1
end

function SpatialQueryPool:resetQueryListSize()
	for i=#self.queryList, self.defaultNumberOfObjects, -1 do
		table.remove(self.queryList)
	end
end

function SpatialQueryPool:setDefaultResponseCallback(responseMethod)
	self.defaultResponseCallback = responseMethod
end

-----------------------
--Spatial query object:
-----------------------

SpatialQuery = {}
SpatialQuery.__index = SpatialQuery

setmetatable(SpatialQuery, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function SpatialQuery.new (queryType)
	local self = setmetatable ({}, SpatialQuery)
		self.queryType = queryType
		self.queryParameters = {}
	return self
end