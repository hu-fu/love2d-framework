------------------------
--Spatial query factory:
------------------------

spatialQueryBuilder = {}
spatialQueryBuilder.__index = spatialQueryBuilder

setmetatable(spatialQueryBuilder, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function spatialQueryBuilder.new ()
	local self = setmetatable ({}, spatialQueryBuilder)
		
		self.spatialQueryMethods = {}
		self.QUERY_TYPES = require 'SPATIAL_QUERY'
		
		self:setCreateSpatialQueryMethods()
		self:setSetSpatialQueryParametersMethods()
	return self
end

function spatialQueryBuilder:createSpatialQuery(queryType)
	local queryObj = spatialQuery.new(queryType)
	self.createSpatialQueryMethods[queryType](queryObj)
	return queryObj
end

function spatialQueryBuilder:modifySpatialQuery(queryType, queryObj)
	queryObj.queryParameters = {}
	queryObj.responseCallback = function() end
	self.createSpatialQueryMethods[queryType](queryObj)
end

function spatialQueryBuilder:setCreateSpatialQueryMethods()

	self.createSpatialQueryMethods = {
		[self.QUERY_TYPES.UPDATE_ENTITY] = function(spatialQuery)
			spatialQueryBuilder:resetSpatialQueryParameters(spatialQuery)
			
			spatialQuery.entityType = 0
			spatialQuery.entityIndex = 0
		end,
		
		[self.QUERY_TYPES.GET_NEAREST_ENTITY_BY_AREA_AND_ROLE] = function(spatialQuery)
			spatialQueryBuilder:resetSpatialQueryParameters(spatialQuery)
			
			spatialQuery.originEntityType = 0
			spatialQuery.originEntityIndex = 0
			
			spatialQuery.x = 0
			spatialQuery.y = 0
			
			spatialQuery.areaX = 0
			spatialQuery.areaY = 0
			spatialQuery.areaW = 0
			spatialQuery.areaH = 0
			spatialQuery.searchRadius = 0
			
			spatialQuery.targetRoles = {}
			spatialQuery.numberOfResults = 1
		end
	}
	
end

function spatialQueryBuilder:setSpatialQueryParameters(spatialQuery, ...)
	self.setSpatialQueryParametersMethods[spatialQuery.queryType](spatialQuery, unpack({...}))
end

function spatialQueryBuilder:setSetSpatialQueryParametersMethods()
	
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
		end
	}
end

function spatialQueryBuilder:resetSpatialQueryParameters(spatialQuery)
	spatialQuery.queryParameters = {}
end

function spatialQueryBuilder:setResponseCallback(spatialQuery, method)
	spatialQuery.responseCallback = method
end

---------------------
--Spatial query pool:
---------------------

spatialQueryPool = {}
spatialQueryPool.__index = spatialQueryPool

setmetatable(spatialQueryPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function spatialQueryPool.new (maxObjects, defaultQueryType, queryBuilderObj, defaultResponseCallback)
	local self = setmetatable ({}, spatialQueryPool)
		
		self.queryList = {}
		self.currentIndex = 1
		self.defaultMaxObjects = maxObjects
		self.defaultQueryType = defaultQueryType
		self.defaultResponseCallback = defaultResponseCallback
		
		self.queryBuilder = queryBuilderObj
		
		self:buildObjectPool()
	return self
end

function spatialQueryPool:buildObjectPool()
	for i=1, self.defaultMaxObjects do
		self:createQueryObject(self.defaultQueryType)
	end
end

function spatialQueryPool:createQueryObject(queryType)
	table.insert(self.queryList, self.queryBuilder:createSpatialQuery(queryType))
	self.queryList[#self.queryList].responseCallback = self.defaultResponseCallback
end

function spatialQueryPool:getCurrentAvailableObject(queryType)
	--query type is optional, it's set to default if you don't pass it
	local currentQuery = self.queryList[self.currentIndex]
	
	if queryType ~= nil and currentQuery.queryType ~= queryType then
		self.queryBuilder:modifySpatialQuery(queryType, queryObj)
	elseif currentQuery.queryType ~= self.defaultQueryType then
		self.queryBuilder:modifySpatialQuery(self.defaultQueryType, queryObj)
	end
	
	return self.queryList[self.currentIndex]
end

function spatialQueryPool:getCurrentAvailableObjectDefault()
	--use this ONLY if you just use one type of query in the pool!
	return self.queryList[self.currentIndex]
end

function spatialQueryPool:resetCurrentIndex()
	self.currentIndex = 1
end

function spatialQueryPool:incrementCurrentIndex()
	if self.currentIndex == #self.queryList then
		self:createQueryObject(self.defaultQueryType)
	end
	self.currentIndex = self.currentIndex + 1
end

function spatialQueryPool:resetQueryListSize()
	for i=#self.queryList, self.defaultNumberOfObjects, -1 do
		table.remove(self.queryList)
	end
end

function spatialQueryPool:setDefaultResponseCallback(responseMethod)
	self.defaultResponseCallback = responseMethod
end

-----------------------
--Spatial query object:
-----------------------

spatialQuery = {}
spatialQuery.__index = spatialQuery

setmetatable(spatialQuery, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function spatialQuery.new (queryType)
	local self = setmetatable ({}, spatialQuery)
		
		self.queryType = queryType
		self.responseCallback = nil
		
		self.queryParameters = {}
	return self
end