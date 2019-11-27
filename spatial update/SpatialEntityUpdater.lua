require '/spatial update/SpatialUpdater'
require '/spatial/SpatialEntityHashtable'
local UPDATE_AREA = require '/spatial update/UPDATE_AREA'
local ENTITY_ROLE = require '/entity/ENTITY_ROLE'

local SpatialEntityUpdater = SpatialUpdater.new('entity')

SpatialEntityUpdater.spatialEntityHashtable = SpatialEntityHashtableSimple.new()

SpatialEntityUpdater.updateAreaQueue = {
	UPDATE_AREA.NORMAL, UPDATE_AREA.NORMAL, UPDATE_AREA.NORMAL, UPDATE_AREA.NORMAL, UPDATE_AREA.MEDIUM,
	UPDATE_AREA.NORMAL, UPDATE_AREA.NORMAL, UPDATE_AREA.NORMAL, UPDATE_AREA.NORMAL, UPDATE_AREA.LARGE
}

SpatialEntityUpdater.updateEntityRoleQueue = {
	--TODO: lower projectile update rates
	{ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.FRIEND_PROJECTILE},
	{ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.HOSTILE_PROJECTILE},
	{ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.FRIEND_PROJECTILE},
	{ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.HOSTILE_PROJECTILE},
	{ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.VISUAL_EFFECT},
	{ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.FRIEND_PROJECTILE},
	{ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.HOSTILE_PROJECTILE},
	{ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.FRIEND_PROJECTILE},
	{ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.HOSTILE_PROJECTILE},
	{ENTITY_ROLE.PLAYER, ENTITY_ROLE.HOSTILE_NPC, ENTITY_ROLE.VISUAL_EFFECT},
}

function SpatialEntityUpdater:update(updateSystem)
	self.spatialEntityHashtable:reset()
	local area = updateSystem.updateAreaTable[self:getCurrentUpdateArea()]
	local roles = self:getCurrentUpdateRoles()
	local spatialQuery = self:createSpatialQuery(updateSystem, area, roles)
	self:sendSpatialQuery(updateSystem, spatialQuery)
end

function SpatialEntityUpdater:createSpatialQuery(updateSystem, area, roles)
	local spatialQuery = updateSystem.getEntitiesQueryPool:getCurrentAvailableObjectDefault()
	updateSystem.getEntitiesQueryPool:incrementCurrentIndex()
	
	spatialQuery.hashtable = self.spatialEntityHashtable
	spatialQuery.roles = roles
	spatialQuery.areaX = area.x
	spatialQuery.areaY = area.y
	spatialQuery.areaW = area.w
	spatialQuery.areaH = area.h
	spatialQuery.responseCallback = self:getSpatialQueryCallbackMethod()
	return spatialQuery
end

function SpatialEntityUpdater:sendSpatialQuery(updateSystem, spatialQuery)
	local spatialSystemRequest = updateSystem.spatialSystemRequestPool:getCurrentAvailableObject()
	spatialSystemRequest.spatialQuery = spatialQuery
	updateSystem.eventDispatcher:postEvent(1, 1, spatialSystemRequest)
	updateSystem.spatialSystemRequestPool:incrementCurrentIndex()
end

function SpatialEntityUpdater:getQueryResults(spatialSystem, spatialQuery, results)
	for i=1, #spatialQuery.hashtable.indexTable do
		local spatialEntity = spatialQuery.hashtable.entityTable[spatialQuery.hashtable.indexTable[i]]
		spatialSystem:updateEntityPosition(spatialEntity.entityType, spatialEntity, 
			spatialSystem.area.grid)
	end
end

function SpatialEntityUpdater:getSpatialQueryCallbackMethod()
	return function (spatialSystem, spatialQuery, results)
		self:getQueryResults(spatialSystem, spatialQuery, results) 
	end
end

function SpatialEntityUpdater:getCurrentUpdateRoles()
	return self.updateEntityRoleQueue[self.currentFrame]
end

function SpatialEntityUpdater:updateAll(updateSystem)
	--run this on frame 0
	self.spatialEntityHashtable:reset()
	local area = updateSystem.updateAreaTable[UPDATE_AREA.ALL]
	local roles = self:getCurrentUpdateRoles()
	local spatialQuery = self:createSpatialQuery(updateSystem, area, roles)
	self:sendSpatialQuery(updateSystem, spatialQuery)
end

--debug:
function SpatialEntityUpdater:writeCurrentAreaInfo(area)
	INFO_STR = area.name
end

return SpatialEntityUpdater