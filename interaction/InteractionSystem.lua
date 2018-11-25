---------------------
--Interaction System:
---------------------

local InteractionSystem = {}

---------------
--Dependencies:
---------------

require '/interaction/InteractionObjects'
local SYSTEM_ID = require '/system/SYSTEM_ID'
InteractionSystem.EVENT_TYPES = require '/event/EVENT_TYPE'
InteractionSystem.QUERY_TYPES = require '/spatial/SPATIAL_QUERY'
InteractionSystem.ENTITY_ACTION = require '/entity state/ENTITY_ACTION'
InteractionSystem.INTERACTION_ID = require '/interaction/INTERACTION'
InteractionSystem.INTERACTION_TYPE = require '/interaction/INTERACTION_TYPE'
InteractionSystem.interactionTable = require '/interaction/INTERACTION_TABLE'

-------------------
--System Variables:
-------------------

InteractionSystem.id = SYSTEM_ID.INTERACTION

InteractionSystem.interactionObjectPool = InteractionObjectPool.new(25, false)
InteractionSystem.requestStack = {}

function InteractionSystem:spatialQueryDefaultCallbackMethod() return function () end end
InteractionSystem.spatialSystemRequestPool = EventObjectPool.new(InteractionSystem.EVENT_TYPES.SPATIAL_REQUEST, 50)
InteractionSystem.spatialQueryPool = SpatialQueryPool.new(50, InteractionSystem.QUERY_TYPES.GET_ENTITIES_IN_AREA_BY_ROLE_LEGACY, 
	SpatialQueryBuilder.new(), InteractionSystem:spatialQueryDefaultCallbackMethod())
InteractionSystem.entityInputRequestPool = EventObjectPool.new(InteractionSystem.EVENT_TYPES.ENTITY_INPUT, 100)

InteractionSystem.eventListenerList = {}
InteractionSystem.eventDispatcher = nil

----------------
--Event Methods:
----------------

InteractionSystem.eventMethods = {

	[1] = {
		[1] = function(request)
			InteractionSystem:addRequestToStack(request)
		end
	}
}

---------------
--Init Methods:
---------------

function InteractionSystem:init()
	
end

---------------
--Exec Methods:
---------------

function InteractionSystem:update()
	self:resolveRequestStack()
	
	self.spatialQueryPool:resetCurrentIndex()
	self.spatialSystemRequestPool:resetCurrentIndex()
	self.entityInputRequestPool:resetCurrentIndex()
end

function InteractionSystem:addRequestToStack(request)
	table.insert(self.requestStack, request)
end

function InteractionSystem:removeRequestFromStack()
	table.remove(self.requestStack)
end

function InteractionSystem:resolveRequestStack()
	for i=#self.requestStack, 1, -1 do
		self:resolveRequest(self.requestStack[i])
		self:removeRequestFromStack()
	end
end

function InteractionSystem:resolveRequest(request)
	local interaction = self:buildInteractionFromEventRequest(request)
	self:queryInteractionTargets(interaction)
end

function InteractionSystem:buildInteractionFromEventRequest(request)
	local interaction = self.interactionObjectPool:getCurrentAvailableInteractionObject()
	interaction.interactionType = request.interactionType
	interaction.interactionId = request.interactionId
	interaction.area.x, interaction.area.y, interaction.area.w, interaction.area.h = request.x, 
		request.y, request.w, request.h
	interaction.origin = request.originEntity
	interaction.targetRole = request.targetRole
	interaction.targets = nil
	
	self.interactionObjectPool:incrementCurrentIndex()
	return interaction
end

function InteractionSystem:queryInteractionTargets(interaction)
	local queryObj = self.spatialQueryPool:getCurrentAvailableObjectDefault()
	queryObj.roles = interaction.targetRole
	queryObj.areaX = interaction.area.x
	queryObj.areaY = interaction.area.y
	queryObj.areaW = interaction.area.w
	queryObj.areaH = interaction.area.h
	queryObj.responseCallback = self:getSpatialQueryCallbackMethod(interaction)
	self.spatialQueryPool:incrementCurrentIndex()
	
	local spatialSystemRequest = self.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = queryObj
	self.eventDispatcher:postEvent(1, 1, spatialSystemRequest)
	self.spatialSystemRequestPool:incrementCurrentIndex()
end

function InteractionSystem:getQueryResults(interaction, spatialSystem, spatialQuery, targets)
	--callback for spatial query
	interaction.targets = targets
	self:runInteraction(interaction)
end

function InteractionSystem:runInteraction(interaction)
	self:runInteractionScript(interaction)
end

function InteractionSystem:runInteractionScript(interaction)
	self.interactionTable[interaction.interactionType][interaction.interactionId](self, interaction)
end

function InteractionSystem:getSpatialQueryCallbackMethod(interaction)
	return function (spatialSystem, spatialQuery, results)
		self:getQueryResults(interaction, spatialSystem, spatialQuery, results)
	end
end

function InteractionSystem:requestEventState(eventComponent)
	local eventObj = self.entityInputRequestPool:getCurrentAvailableObject()
	
	eventObj.actionId = self.ENTITY_ACTION.START_EVENT
	eventObj.stateComponent = eventComponent.componentTable.state
	
	if eventComponent.componentTable.playerInput and 
		eventComponent.componentTable.playerInput.state then
		self.eventDispatcher:postEvent(2, 4, eventObj)
	else
		--send to ai controller
	end
	
	self.entityInputRequestPool:incrementCurrentIndex()
end

--debug:

InteractionSystem.debugInteraction = {x=0, y=0, w=0, h=0, entities={}}

function InteractionSystem:setDebugInteraction(x, y, w, h, entities)
	self.debugInteraction.x = x
	self.debugInteraction.y = y
	self.debugInteraction.w = w
	self.debugInteraction.h = h
	self.debugInteraction.entities = entities
end

function InteractionSystem:drawDebugInteraction(camera)
	love.graphics.rectangle('line', self.debugInteraction.x - camera.x, self.debugInteraction.y - camera.y, 
		self.debugInteraction.w, self.debugInteraction.h)
	
	for i=1, #self.debugInteraction.entities do
		local entity = self.debugInteraction.entities[i]
		love.graphics.rectangle('fill', entity.x - camera.x, entity.y - camera.y, entity.w, entity.h)
	end
end

----------------
--return module:
----------------

return InteractionSystem