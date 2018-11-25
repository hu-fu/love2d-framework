local systemTestModule = {}

--initialize DB (generic_entity):
--entitySpatialTable is deprecated - remove as soon as possible!
--NEW RULE (very important!): only use INT/FLOAT/BOOL as table row values
--RIP database system 2017-05-??, it was such a good idea
--delete this
--[[
systemTestModule.globalEntityTable = componentTable.new(1, 'globalEntityTable', 9, {'globalEntityId', 'entitySceneTable', 'entitySpriteboxTable','entityAnimatedIdleTable','entityHitboxTable','entityActionStateTable','entityInputTable','entityMovementTable', 'entityTargetingTableIndex'})
systemTestModule.entitySceneTable = componentTable.new(8, 'entitySceneTable', 4, {'globalEntityTableIndex', 'defaultRole', 'role', 'entitySpriteboxTable'})
systemTestModule.entitySpriteboxTable = componentTable.new(2, 'entitySpriteboxTable', 12, {'globalEntityTableIndex', 'entitySceneTableIndex', 'x', 'y', 'w', 'h', 'defaultSpritesheetId', 'spritesheetId', 'quad', 'aniRepoId', 'hitboxTableIndex', 'animatedIdleTableIndex'})
systemTestModule.entityAnimatedIdleTable = componentTable.new(3, 'entityAnimatedIdleTable', 9, {'globalEntityIdTableIndex', 'entitySpriteboxTableIndex', 'state', 'spriteAnimationId', 'defaultQuad', 'T', 't', 'f', 'UP'})
systemTestModule.entityHitboxTable = componentTable.new(4, 'entityHitboxTable', 9, {'globalEntityIdTableIndex', 'entitySpriteboxTableIndex', 'x', 'y', 'w', 'h', 'map collision type', 'entity collision type', 'entityActionStateTableIndex'})
systemTestModule.entityActionStateTable = componentTable.new(5, 'entityActionStateTable', 7, {'globalEntityIdTableIndex', 'entityHitboxTableIndex', 'state', 'defaultState','entityInputTableIndex','entityMovementTableIndex', 'entityTargetingTableIndex'})
systemTestModule.entityInputTable = componentTable.new(6, 'entityInputTable', 3, {'globalEntityIdTableIndex', 'entityActionStateTableIndex', 'state'})
systemTestModule.entityMovementTable = componentTable.new(7, 'entityMovementTable', 11 , {'globalEntityIdTableIndex','entityActionStateTableIndex','velocity','direction','spritesheetId', 'defaultQuad','T','t','f','UP','movementRepoId'} )
systemTestModule.entityTargetingTable = componentTable.new(9, 'entityTargetingTable', 8, {'globalEntityIdTableIndex', 'entityActionStateTableIndex', 'state', 'defaultTargetingType', 'targetingType', 'areaRadius', 'targetEntityType', 'targetEntityReference'})
componentTableLink.new(systemTestModule.globalEntityTable, 2, systemTestModule.entitySceneTable, 1)
componentTableLink.new(systemTestModule.globalEntityTable, 3, systemTestModule.entitySpriteboxTable, 1)
componentTableLink.new(systemTestModule.globalEntityTable, 4, systemTestModule.entityAnimatedIdleTable, 1)
componentTableLink.new(systemTestModule.globalEntityTable, 5, systemTestModule.entityHitboxTable, 1)
componentTableLink.new(systemTestModule.globalEntityTable, 6, systemTestModule.entityActionStateTable, 1)
componentTableLink.new(systemTestModule.globalEntityTable, 7, systemTestModule.entityInputTable, 1)
componentTableLink.new(systemTestModule.globalEntityTable, 8, systemTestModule.entityMovementTable, 1)
componentTableLink.new(systemTestModule.globalEntityTable, 9, systemTestModule.entityTargetingTable, 1)
componentTableLink.new(systemTestModule.entitySceneTable, 4, systemTestModule.entitySpriteboxTable, 2)
componentTableLink.new(systemTestModule.entitySpriteboxTable, 11, systemTestModule.entityHitboxTable, 2)
componentTableLink.new(systemTestModule.entitySpriteboxTable, 12, systemTestModule.entityAnimatedIdleTable, 2)
componentTableLink.new(systemTestModule.entityHitboxTable, 9, systemTestModule.entityActionStateTable, 2)
componentTableLink.new(systemTestModule.entityActionStateTable, 5, systemTestModule.entityInputTable, 2)
componentTableLink.new(systemTestModule.entityActionStateTable, 6, systemTestModule.entityMovementTable, 2)
componentTableLink.new(systemTestModule.entityActionStateTable, 7, systemTestModule.entityTargetingTable, 2)

local genericEntityDatabase = entityDatabase.new(1, 'genericEntityDatabase')
genericEntityDatabase:indexTable('globalEntityTable', systemTestModule.globalEntityTable)
genericEntityDatabase:indexTable('entitySceneTable', systemTestModule.entitySceneTable)
genericEntityDatabase:indexTable('entitySpriteboxTable', systemTestModule.entitySpriteboxTable)
genericEntityDatabase:indexTable('entityAnimatedIdleTable', systemTestModule.entityAnimatedIdleTable)
genericEntityDatabase:indexTable('entityHitboxTable', systemTestModule.entityHitboxTable)
genericEntityDatabase:indexTable('entityActionStateTable', systemTestModule.entityActionStateTable)
genericEntityDatabase:indexTable('entityInputTable', systemTestModule.entityInputTable)
genericEntityDatabase:indexTable('entityMovementTable', systemTestModule.entityMovementTable)
genericEntityDatabase:indexTable('entityTargetingTable', systemTestModule.entityTargetingTable)

local genericObstacleDatabase = entityDatabase.new(2, 'genericObstacleDatabase')
genericObstacleDatabase:createComponentTable('quad', 1, 'quad', 5, {'globalObstacleId', 'x', 'y', 'w', 'h'})

--set entity types:
systemTestModule.entityTypes = {}
systemTestModule.entityTypes[1] = entityType.new(1, 'genericEntity')
systemTestModule.entityTypes[1]:setEntityDatabase(genericEntityDatabase)
systemTestModule.entityTypes[2] = entityType.new(2, 'genericObstacle')
systemTestModule.entityTypes[2]:setEntityDatabase(genericObstacleDatabase)
]]

--initialize db (new):
local ENTITY_TYPES = require '/entity/ENTITY_TYPE'

systemTestModule.entityDatabase = entityDatabase.new(1, 'genericEntityDatabase', ENTITY_TYPES.GENERIC_ENTITY)
systemTestModule.entityDatabase:indexTable('globalEntityTable', {})
systemTestModule.entityDatabase:indexTable('entityMainTable', {})
systemTestModule.entityDatabase:indexTable('entitySceneTable', {})
systemTestModule.entityDatabase:indexTable('entitySpriteboxTable', {})
systemTestModule.entityDatabase:indexTable('entityAnimatedIdleTable', {})
systemTestModule.entityDatabase:indexTable('entityHitboxTable', {})
systemTestModule.entityDatabase:indexTable('entityActionStateTable', {})
systemTestModule.entityDatabase:indexTable('entityInputTable', {})
systemTestModule.entityDatabase:indexTable('entityMovementTable', {})
systemTestModule.entityDatabase:indexTable('entityTargetingTable', {})
systemTestModule.entityDatabase:indexTable('entityActionTable', {})

systemTestModule.obstacleDatabase = entityDatabase.new(2, 'genericObstacleDatabase', ENTITY_TYPES.GENERIC_WALL)
systemTestModule.obstacleDatabase:indexTable('globalEntityTable', {})
systemTestModule.obstacleDatabase:indexTable('entityMainTable', {})
systemTestModule.obstacleDatabase:indexTable('entitySceneTable', {})
systemTestModule.obstacleDatabase:indexTable('entitySpriteboxTable', {})
systemTestModule.obstacleDatabase:indexTable('entityAnimatedIdleTable', {})
systemTestModule.obstacleDatabase:indexTable('entityHitboxTable', {})

systemTestModule.entityDatabases = {}
systemTestModule.entityDatabases[ENTITY_TYPES.GENERIC_ENTITY] = systemTestModule.entityDatabase
systemTestModule.entityDatabases[ENTITY_TYPES.GENERIC_WALL] = systemTestModule.obstacleDatabase

--initialize systems:
systemTestModule.animationSystem = require 'animationSystem'
systemTestModule.animatedIdleSystem = require 'animatedIdleSystem'
systemTestModule.playerEntityControllerSystem = require 'playerEntityControllerSystem'
systemTestModule.entityMovementSystem = require 'entityMovementSystem'
systemTestModule.playerEntityInputSystem = require 'testInputSystem'
systemTestModule.spatialPartitioningSystem = require '/spatial/SpatialPartitioningSystem'
systemTestModule.collisionSystem = require 'collisionSystem'
systemTestModule.targetingSystem = require 'entityTargetingSystem'
systemTestModule.projectileSystem = require 'projectileSystem'

systemTestModule.animationSystem.spriteBoxComponentTable = systemTestModule.entityDatabase:getTableRows('entitySpriteboxTable')
systemTestModule.animatedIdleSystem.animatedIdleComponentTable = systemTestModule.entityDatabase:getTableRows('entityAnimatedIdleTable')
systemTestModule.playerEntityControllerSystem.entityStateComponentTable = systemTestModule.entityDatabase:getTableRows('entityActionStateTable')
systemTestModule.playerEntityControllerSystem.playerInputTable = systemTestModule.entityDatabase:getTableRows('entityInputTable')
systemTestModule.playerEntityControllerSystem.entityTargetingComponentTable = systemTestModule.entityDatabase:getTableRows('entityTargetingTable')
systemTestModule.entityMovementSystem.spriteBoxComponentTable = systemTestModule.entityDatabase:getTableRows('entitySpriteboxTable')
systemTestModule.entityMovementSystem.hitBoxComponentTable = systemTestModule.entityDatabase:getTableRows('entityHitboxTable')
systemTestModule.entityMovementSystem.entityMovementComponentTable = systemTestModule.entityDatabase:getTableRows('entityMovementTable')
systemTestModule.collisionSystem.genericEntitySpriteboxTable = systemTestModule.entityDatabase:getTableRows('entitySpriteboxTable')
systemTestModule.targetingSystem.genericEntityTargetingTable = systemTestModule.entityDatabase:getTableRows('entityTargetingTable')

--initialize event system (who knows how this works):
--systemTestModule.animationSystem.eventDispatcher = eventDispatcher.new(1, 0, {})
--systemTestModule.animatedIdleSystem.eventDispatcher = eventDispatcher.new(2, 1, {'update_animation'})
--systemTestModule.playerEntityControllerSystem.eventDispatcher = eventDispatcher.new(3, 2, {'move', 'targeting'})
--systemTestModule.entityMovementSystem.eventDispatcher = eventDispatcher.new(4, 2, {'idle', 'animation'})
--systemTestModule.playerEntityInputSystem.eventDispatcher = eventDispatcher.new(5, 1, {'movement_input'})
--systemTestModule.collisionSystem.eventDispatcher = eventDispatcher.new(6, 1, {'spatial_query'})
--systemTestModule.targetingSystem.eventDispatcher = eventDispatcher.new(7, 1, {'spatial_query'})

--local animationSystemEventListener = eventListener.new(1, {[2] = {1}})
--local animatedIdleSystemEventListener = eventListener.new(2, {[4] = {1}})
--local playerEntityControllerSystemEventListener = eventListener.new(3, {[5] = {1}})
--local entityMovementSystemEventListener = eventListener.new(4, {[3] = {1}})
--local playerEntityInputSystemEventListener = eventListener.new(5, {})
--local spatialPartitioningSystemEventListener = eventListener.new(6, {[6] = {1}, [7] = {1}, [8] = {1}, [9] = {1}})
--local targetingSystemEventListener = eventListener.new(7, {[3] = {2}})

--systemTestModule.animatedIdleSystem.eventDispatcher:registerEventListener(animationSystemEventListener)
--systemTestModule.playerEntityControllerSystem.eventDispatcher:registerEventListener(entityMovementSystemEventListener)
--systemTestModule.playerEntityControllerSystem.eventDispatcher:registerEventListener(targetingSystemEventListener)
--systemTestModule.entityMovementSystem.eventDispatcher:registerEventListener(animatedIdleSystemEventListener)
--systemTestModule.playerEntityInputSystem.eventDispatcher:registerEventListener(playerEntityControllerSystemEventListener)
--systemTestModule.collisionSystem.eventDispatcher:registerEventListener(spatialPartitioningSystemEventListener)
--systemTestModule.targetingSystem.eventDispatcher:registerEventListener(spatialPartitioningSystemEventListener)

--systemTestModule.animationSystem:setEventListener(1, animationSystemEventListener)
--systemTestModule.animatedIdleSystem:setEventListener(1, animatedIdleSystemEventListener)
--systemTestModule.playerEntityControllerSystem:setEventListener(1, playerEntityControllerSystemEventListener)
--systemTestModule.entityMovementSystem:setEventListener(1, entityMovementSystemEventListener)
--systemTestModule.playerEntityInputSystem:setEventListener(1, playerEntityInputSystemEventListener) --no need for a listener
--systemTestModule.spatialPartitioningSystem:setEventListener(1, spatialPartitioningSystemEventListener)
--systemTestModule.targetingSystem:setEventListener(1, targetingSystemEventListener)

--Entity init (new) - create a dedicated system for this:
systemTestModule.gameEntityBuilder = GameEntityBuilder.new()
local ENTITY_COMPONENTS = require '/entity/ENTITY_COMPONENT'
local maxEntities = 50
math.randomseed( os.time() )

for i=1, maxEntities do
	table.insert(systemTestModule.entityDatabase.tables['globalEntityTable'], 
		systemTestModule.gameEntityBuilder:createEntity())
end

for i=1, maxEntities do
	table.insert(systemTestModule.entityDatabase.tables['entityMainTable'], 
		systemTestModule.gameEntityBuilder:createComponent(ENTITY_COMPONENTS.MAIN))
end

for i=1, maxEntities do
	table.insert(systemTestModule.entityDatabase.tables['entitySceneTable'], 
		systemTestModule.gameEntityBuilder:createComponent(ENTITY_COMPONENTS.SCENE))
end

for i=1, maxEntities do
	table.insert(systemTestModule.entityDatabase.tables['entitySpriteboxTable'], 
		systemTestModule.gameEntityBuilder:createComponent(ENTITY_COMPONENTS.SPRITEBOX))
end

for i=1, maxEntities do
	table.insert(systemTestModule.entityDatabase.tables['entityAnimatedIdleTable'], 
		systemTestModule.gameEntityBuilder:createComponent(ENTITY_COMPONENTS.IDLE))
end

for i=1, maxEntities do
	table.insert(systemTestModule.entityDatabase.tables['entityHitboxTable'], 
		systemTestModule.gameEntityBuilder:createComponent(ENTITY_COMPONENTS.HITBOX))
end

for i=1, 1 do
	table.insert(systemTestModule.entityDatabase.tables['entityActionStateTable'], 
		systemTestModule.gameEntityBuilder:createComponent(ENTITY_COMPONENTS.ACTION_STATE))
end

for i=1, 1 do
	table.insert(systemTestModule.entityDatabase.tables['entityInputTable'], 
		systemTestModule.gameEntityBuilder:createComponent(ENTITY_COMPONENTS.INPUT))
end

for i=1, 1 do
	table.insert(systemTestModule.entityDatabase.tables['entityMovementTable'], 
		systemTestModule.gameEntityBuilder:createComponent(ENTITY_COMPONENTS.MOVEMENT))
end

for i=1, 1 do
	table.insert(systemTestModule.entityDatabase.tables['entityTargetingTable'], 
		systemTestModule.gameEntityBuilder:createComponent(ENTITY_COMPONENTS.TARGETING))
end

for i=1, 1 do
	table.insert(systemTestModule.entityDatabase.tables['entityActionTable'], 
		systemTestModule.gameEntityBuilder:createComponent(ENTITY_COMPONENTS.ACTION))
end

systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][1], 
	ENTITY_COMPONENTS.MAIN, systemTestModule.entityDatabase.tables['entityMainTable'][1])
systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][1], 
	ENTITY_COMPONENTS.SCENE, systemTestModule.entityDatabase.tables['entitySceneTable'][1])
systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][1], 
	ENTITY_COMPONENTS.SPRITEBOX, systemTestModule.entityDatabase.tables['entitySpriteboxTable'][1])
systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][1], 
	ENTITY_COMPONENTS.IDLE, systemTestModule.entityDatabase.tables['entityAnimatedIdleTable'][1])
systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][1], 
	ENTITY_COMPONENTS.HITBOX, systemTestModule.entityDatabase.tables['entityHitboxTable'][1])
systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][1], 
	ENTITY_COMPONENTS.ACTION_STATE, systemTestModule.entityDatabase.tables['entityActionStateTable'][1])
systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][1], 
	ENTITY_COMPONENTS.INPUT, systemTestModule.entityDatabase.tables['entityInputTable'][1])
systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][1], 
	ENTITY_COMPONENTS.MOVEMENT, systemTestModule.entityDatabase.tables['entityMovementTable'][1])
systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][1], 
	ENTITY_COMPONENTS.TARGETING, systemTestModule.entityDatabase.tables['entityTargetingTable'][1])
systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][1], 
	ENTITY_COMPONENTS.ACTION, systemTestModule.entityDatabase.tables['entityActionTable'][1])

for i=2, maxEntities do
	systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][i], 
		ENTITY_COMPONENTS.MAIN, systemTestModule.entityDatabase.tables['entityMainTable'][i])
	systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][i], 
		ENTITY_COMPONENTS.SCENE, systemTestModule.entityDatabase.tables['entitySceneTable'][i])
	systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][i], 
		ENTITY_COMPONENTS.SPRITEBOX, systemTestModule.entityDatabase.tables['entitySpriteboxTable'][i])
	systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][i], 
		ENTITY_COMPONENTS.IDLE, systemTestModule.entityDatabase.tables['entityAnimatedIdleTable'][i])
	systemTestModule.gameEntityBuilder:addComponentToEntity(systemTestModule.entityDatabase.tables['globalEntityTable'][i], 
		ENTITY_COMPONENTS.HITBOX, systemTestModule.entityDatabase.tables['entityHitboxTable'][i])
end

local playerEntity = systemTestModule.entityDatabase.tables['globalEntityTable'][1]
playerEntity.components.main.id = 1
playerEntity.components.scene.defaultRole = 2
playerEntity.components.scene.role = 2
playerEntity.components.spritebox.x = 100
playerEntity.components.spritebox.y = 100
playerEntity.components.spritebox.w = 75
playerEntity.components.spritebox.h = 75
playerEntity.components.spritebox.defaultSpritesheetId = 1
playerEntity.components.spritebox.spritesheetId = 1
playerEntity.components.spritebox.quad = 6
playerEntity.components.spritebox.aniRepoId = 1
playerEntity.components.idle.state = false
playerEntity.components.idle.spriteAnimationId = 1
playerEntity.components.idle.defaultQuad = 33
playerEntity.components.idle.totalTime = 0.6
playerEntity.components.idle.currentTime = 0
playerEntity.components.idle.frequency = 0.3
playerEntity.components.idle.updatePoint = 0
playerEntity.components.idle.animationSetId = 1
playerEntity.components.idle.animationId = 1
playerEntity.components.hitbox.x = 120
playerEntity.components.hitbox.y = 140
playerEntity.components.hitbox.w = 35
playerEntity.components.hitbox.h = 35
playerEntity.components.hitbox.collisionType = 1
playerEntity.components.hitbox.mapCollisionType = 3
playerEntity.components.actionState.state = 1
playerEntity.components.actionState.defaultState = 1
playerEntity.components.input.state = true
playerEntity.components.movement.velocity = 400
playerEntity.components.movement.direction = 5
playerEntity.components.movement.spritesheetId = 1
playerEntity.components.movement.defaultQuad = 9
playerEntity.components.movement.totalTime = 30
playerEntity.components.movement.currentTime = 0
playerEntity.components.movement.frequency = 10
playerEntity.components.movement.updatePoint = 0
playerEntity.components.movement.movementRepoId = 1
playerEntity.components.movement.animationSetId = 1
playerEntity.components.movement.animationId = 2
playerEntity.components.targeting.state = false
playerEntity.components.targeting.defaultTargetingType = 1
playerEntity.components.targeting.targetingType = 1
playerEntity.components.targeting.areaRadius = 300
playerEntity.components.targeting.targetEntityType = 0
playerEntity.components.targeting.targetEntityRef = nil
playerEntity.components.action.state = false
playerEntity.components.action.defaultActionSetId = 1
playerEntity.components.action.actionPlayer = nil

for i=2, maxEntities do
	local x = math.random(0, 2000)
	local y = math.random(0, 1200)
	local npcEntity = systemTestModule.entityDatabase.tables['globalEntityTable'][i]
	npcEntity.components.main.id = 1
	npcEntity.components.scene.defaultRole = 3
	npcEntity.components.scene.role = 3
	npcEntity.components.spritebox.x = x
	npcEntity.components.spritebox.y = y
	npcEntity.components.spritebox.w = 75
	npcEntity.components.spritebox.h = 75
	npcEntity.components.spritebox.defaultSpritesheetId = 1
	npcEntity.components.spritebox.spritesheetId = 1
	npcEntity.components.spritebox.quad = 6
	npcEntity.components.spritebox.aniRepoId = 1
	npcEntity.components.idle.state = false
	npcEntity.components.idle.spriteAnimationId = 1
	npcEntity.components.idle.defaultQuad = 33
	npcEntity.components.idle.totalTime = 0.6
	npcEntity.components.idle.currentTime = 0
	npcEntity.components.idle.frequency = 0.3
	npcEntity.components.idle.updatePoint = 0
	npcEntity.components.idle.animationSetId = 1
	npcEntity.components.idle.animationId = 1
	npcEntity.components.hitbox.x = (x + 20)
	npcEntity.components.hitbox.y = (y + 40)
	npcEntity.components.hitbox.w = 35
	npcEntity.components.hitbox.h = 35
	npcEntity.components.hitbox.collisionType = 1
	npcEntity.components.hitbox.mapCollisionType = 3
end

--Repo init (test):
local frameUpdateValues = {
	[3] = 1
}
local soundEffectValues = {}
local specialEffectValues = {}

systemTestModule.animationSystem.animationRepositoryList[1] = spriteAnimationRepository.new(1)
systemTestModule.animationSystem.animationRepositoryList[1]:createSpriteAnimation(1, frameUpdateValues, soundEffectValues, specialEffectValues)

--other stuff:

return systemTestModule