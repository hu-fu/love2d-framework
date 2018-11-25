------------------------
--Database query factory:
------------------------

DatabaseQueryBuilder = {}
DatabaseQueryBuilder.__index = DatabaseQueryBuilder

setmetatable(DatabaseQueryBuilder, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function DatabaseQueryBuilder.new ()
	local self = setmetatable ({}, DatabaseQueryBuilder)
		
		self.DatabaseQueryMethods = {}
		self.QUERY_TYPES = require '/persistent/DATABASE_QUERY'
		
		self:setCreateDatabaseQueryMethods()
		self:setSetDatabaseQueryParametersMethods()
	return self
end

function DatabaseQueryBuilder:createDatabaseQuery(queryType)
	local queryObj = DatabaseQuery.new(queryType)
	self.createDatabaseQueryMethods[queryType](queryObj)
	return queryObj
end

function DatabaseQueryBuilder:modifyDatabaseQuery(queryType, queryObj)
	self:resetDatabaseQueryParameters(queryObj)
	queryObj.responseCallback = function() end
	self.createDatabaseQueryMethods[queryType](queryObj)
end

function DatabaseQueryBuilder:setCreateDatabaseQueryMethods()

	self.createDatabaseQueryMethods = {
		[self.QUERY_TYPES.GENERIC] = function(databaseQuery)
			databaseQuery.queryParameters.tableId = 0
		end,
		
		--...
	}
end

function DatabaseQueryBuilder:setDatabaseQueryParameters(databaseQuery, ...)
	self.setDatabaseQueryParametersMethods[databaseQuery.queryType](databaseQuery, unpack({...}))
end

function DatabaseQueryBuilder:setSetDatabaseQueryParametersMethods()
	
	self.setDatabaseQueryParametersMethods = {
		[self.QUERY_TYPES.GENERIC] = function(databaseQuery, tableId)
			databaseQuery.queryParameters.tableId = tableId
		end,
		
		--...
	}
end

function DatabaseQueryBuilder:resetDatabaseQueryParameters(databaseQuery)
	databaseQuery.queryParameters = {}
end

function DatabaseQueryBuilder:setResponseCallback(databaseQuery, method)
	databaseQuery.responseCallback = method
end

---------------------
--Database query pool:
---------------------

DatabaseQueryPool = {}
DatabaseQueryPool.__index = DatabaseQueryPool

setmetatable(DatabaseQueryPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function DatabaseQueryPool.new (maxObjects, defaultQueryType, queryBuilderObj, defaultResponseCallback)
	local self = setmetatable ({}, DatabaseQueryPool)
		
		self.queryList = {}
		self.currentIndex = 1
		self.defaultMaxObjects = maxObjects
		self.defaultQueryType = defaultQueryType
		self.defaultResponseCallback = defaultResponseCallback
		
		self.queryBuilder = queryBuilderObj
		
		self:buildObjectPool()
	return self
end

function DatabaseQueryPool:buildObjectPool()
	for i=1, self.defaultMaxObjects do
		self:createQueryObject(self.defaultQueryType)
	end
end

function DatabaseQueryPool:createQueryObject(queryType)
	table.insert(self.queryList, self.queryBuilder:createDatabaseQuery(queryType))
	self.queryList[#self.queryList].responseCallback = self.defaultResponseCallback
end

function DatabaseQueryPool:getCurrentAvailableObject(queryType)
	--query type is optional, it's set to default if you don't pass it
	local currentQuery = self.queryList[self.currentIndex]
	
	if queryType ~= nil and currentQuery.queryType ~= queryType then
		self.queryBuilder:modifyDatabaseQuery(queryType, currentQuery)
	elseif currentQuery.queryType ~= self.defaultQueryType then
		self.queryBuilder:modifyDatabaseQuery(self.defaultQueryType, currentQuery)
	end
	
	return self.queryList[self.currentIndex]
end

function DatabaseQueryPool:getCurrentAvailableObjectDefault()
	--use this ONLY if you just use one type of query in the pool!
	return self.queryList[self.currentIndex]
end

function DatabaseQueryPool:resetCurrentIndex()
	self.currentIndex = 1
end

function DatabaseQueryPool:incrementCurrentIndex()
	if self.currentIndex == #self.queryList then
		self:createQueryObject(self.defaultQueryType)
	end
	self.currentIndex = self.currentIndex + 1
end

function DatabaseQueryPool:resetQueryListSize()
	for i=#self.queryList, self.defaultNumberOfObjects, -1 do
		table.remove(self.queryList)
	end
end

function DatabaseQueryPool:setDefaultResponseCallback(responseMethod)
	self.defaultResponseCallback = responseMethod
end

------------------------
--Database query object:
------------------------

DatabaseQuery = {}
DatabaseQuery.__index = DatabaseQuery

setmetatable(DatabaseQuery, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function DatabaseQuery.new (queryType)
	local self = setmetatable ({}, DatabaseQuery)
		
		self.queryType = queryType
		self.responseCallback = nil
		
		self.queryParameters = {}
	return self
end