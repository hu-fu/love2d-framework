----------------
--Action Loader:
----------------

local ActionLoader = {}

---------------
--Dependencies:
---------------

require '/action/EntityAction'
ActionLoader.ACTIONS = require '/action/ACTION'
ActionLoader.ACTION_ASSETS = require '/action/ACTION_ASSET'
ActionLoader.ENTITY_DIRECTION = require '/entity state/ENTITY_DIRECTION'
local SYSTEM_ID = require '/system/SYSTEM_ID'

-------------------
--System Variables:
-------------------

ActionLoader.id = SYSTEM_ID.ACTION_LOADER

ActionLoader.eventDispatcher = nil
ActionLoader.eventListenerList = {}

ActionLoader.assetsFolderPath = '/action/assets/'

ActionLoader.actionList = {}		--[set_id][action_id] = action object
ActionLoader.defaultAction = nil

ActionLoader.entityActionBuilder = EntityActionBuilder.new()

ActionLoader.sortActionMethod = function(a, b) return a.callTime < b.callTime end

----------------
--Event Methods:
----------------

ActionLoader.eventMethods = {
	[1] = {
		[1] = function(request)
			--get action object (do not delay this, very important)
			local actionObj = ActionLoader:getAction(request.actionSetId, request.actionId)
			
			if actionObj ~= nil then
				request.callback(request.component, actionObj)
			end
		end,
		
		[2] = function(request)
			--load action set
			ActionLoader:loadActionSet(request.actionSetId)
		end
	}
}

---------------
--Init Methods:
---------------

function ActionLoader:setEventListener(index, eventListener)
	self.eventListenerList[index] = eventListener
	
	for i=0, #self.eventMethods[index] do
		self.eventListenerList[index]:registerFunction(i, self.eventMethods[index][i])
	end
end

function ActionLoader:setEventDispatcher(eventDispatcher)
	self.eventDispatcher = eventDispatcher
end

function ActionLoader:init()
	
end

---------------
--Exec Methods:
---------------

function ActionLoader:resetActionList()
	for setName, actionSetId in pairs(self.ACTIONS) do
		self.actionList[actionSetId] = {}
		for actionName, actionId in pairs(self.ACTIONS[actionId]) do
			self.actionList[actionSetId][actionId] = nil
		end
	end
end

function ActionLoader:getActionAssetFile(actionSetId)
	local actionAsset = self.ACTION_ASSETS[actionSetId]
	if actionAsset ~= nil then
		local path = self.assetsFolderPath .. actionAsset.filepath
		local assetFile = require(path)
		return assetFile
	end
	return nil
end

function ActionLoader:loadActionSet(actionSetId)
	if self.actionList[actionSetId] == nil then
		local assetFile = self:getActionAssetFile(actionSetId)
		if assetFile ~= nil then
			self:createActionSet(actionSetId, assetFile)
		end
	end
end

function ActionLoader:getActionSet(actionSetId)
	self:loadActionSet(actionSetId)
	if self.actionList[actionSetId] == nil then
		return nil		--consider returning an empty action object ("do nothing" action)
	end
	return self.actionList[actionSetId]
end

function ActionLoader:removeActionSet(actionSetId)
	self.actionList[actionSetId] = nil
end

function ActionLoader:loadAction(actionSetId, actionId)
	self:loadActionSet(actionSetId)
	if self.actionList[actionSetId] == nil then return nil end
	if self.actionList[actionSetId][actionId] == nil then
		local assetFile = self:getActionAssetFile(actionSetId)
		if assetFile ~= nil then
			self:setAction(actionSetId, actionId, self:createAction(assetFile[actionId]))
		end
	end
	return self.actionList[actionSetId][actionId]
end

function ActionLoader:getAction(actionSetId, actionId)
	local actionSet = self:getActionSet(actionSetId)
	if actionSet == nil then return nil end
	if actionSet[actionId] == nil then self:loadAction(actionSetId, actionId) end
	return actionSet[actionId]
end

function ActionLoader:removeAction(actionSetId, actionId)
	self.actionList[actionSetId][actionId] = nil
end

function ActionLoader:createActionSet(actionSetId, assetFile)
	for actionId, assetObject in pairs(assetFile) do
		self:setAction(actionSetId, actionId, self:createAction(assetObject))
	end
end

function ActionLoader:createAction(assetObject)
	--parse object here:
	local actionObj = self.entityActionBuilder:createEntityAction(assetObject)
	return actionObj
end

function ActionLoader:setAction(actionSetId, actionId, actionObj)
	if self.actionList[actionSetId] == nil then
		self.actionList[actionSetId] = {}
	end
	
	self.actionList[actionSetId][actionId] = actionObj	
end

---------------
--Init Methods:
---------------

return ActionLoader