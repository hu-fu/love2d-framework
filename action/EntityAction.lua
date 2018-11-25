----------------
--Entity Action:
----------------

EntityAction = {}
EntityAction.__index = EntityAction

setmetatable(EntityAction, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EntityAction.new (id, animationSetId, animationId, totalTime, replay)
	local self = setmetatable ({}, EntityAction)
		self.id = id
		self.animationSetId = animationSetId
		self.animationId = animationId
		self.totalTime = totalTime
		self.replay = replay
		
		self.variables = {}
		self.methods = {}
	return self
end

------------------------
--Entity Action Factory:
------------------------

EntityActionBuilder = {}
EntityActionBuilder.__index = EntityActionBuilder

setmetatable(EntityActionBuilder, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EntityActionBuilder.new ()
	local self = setmetatable ({}, EntityActionBuilder)
		self.sortActionMethod = function(a, b) return a.callTime < b.callTime end
	return self
end

function EntityActionBuilder:createEntityAction(actionAsset)
	local actionObj = EntityAction.new(actionAsset.id, actionAsset.animationSetId, 
		actionAsset.animationId, actionAsset.totalTime, actionAsset.replay)
	self:setActionVariables(actionObj, actionAsset.variables)
	self:setActionMethods(actionObj, actionAsset.methods)
	return actionObj
end

function EntityActionBuilder:setActionVariables(actionObj, variables)
	actionObj.variables = variables
end

function EntityActionBuilder:setActionMethods(actionObj, methods)
	for i=1, #methods do
		table.insert(actionObj.methods, methods[i])
	end
	
	table.sort(actionObj.methods, self.sortActionMethod)
end