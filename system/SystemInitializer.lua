local SystemInitializer = {}

SystemInitializer.SYSTEM_ID = require '/system/SYSTEM_ID'

SystemInitializer.systemTable = {}

function SystemInitializer:init()
	--all hard dependencies are initialized here and only here (very important)!
	self:initializeSystemTable()
	self:initializeSystems()
	self:initializeEventsOnSystems()
	self:initializeSystemsOnSceneScript()
	self:initializeCameraOnSystems()
	self:initializeGraphicsOnSystems()
	self:initializeSpatialUpdaters()
end

function SystemInitializer:getSystems()
	return self.systemTable
end

function SystemInitializer:getSystemById(systemId)
	return self.systemTable[systemId]
end

function SystemInitializer:initializeSystemTable()
	for systemName, systemId in pairs(self.SYSTEM_ID) do
		self.systemTable[systemId] = false
	end
end

function SystemInitializer:initializeSystems()
	for systemName, systemId in pairs(self.SYSTEM_ID) do
		self.initializeSystemMethods[systemId](self)
	end
end

SystemInitializer.initializeSystemMethods = {
	[SystemInitializer.SYSTEM_ID.ANIMATION] = function(self)
		--deprecated
	end,
	
	[SystemInitializer.SYSTEM_ID.IDLE] = function(self)
		local system = require '/entity idle/EntityIdleSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.IDLE] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ENTITY_CONTROLLER] = function(self)
		local system = require '/controller/EntityControllerSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.ENTITY_CONTROLLER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ENTITY_MOVEMENT] = function(self)
		local system = require '/entity movement/EntityMovementSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.ENTITY_MOVEMENT] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.PLAYER_INPUT] = function(self)
		local system = require '/input/PlayerInputSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.PLAYER_INPUT] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.SPATIAL_PARTITIONING] = function(self)
		local system = require '/spatial/SpatialPartitioningSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.SPATIAL_PARTITIONING] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.TARGETING] = function(self)
		local system = require '/target/EntityTargetingSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.TARGETING] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ANIMATION_LOADER] = function(self)
		local system = require '/animation/AnimationLoader'
		system:init()
		self.systemTable[self.SYSTEM_ID.ANIMATION_LOADER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ENTITY_ANIMATION] = function(self)
		local system = require '/animation/EntityAnimationSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.ENTITY_ANIMATION] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ACTION_LOADER] = function(self)
		local system = require '/action/ActionLoader'
		system:init()
		self.systemTable[self.SYSTEM_ID.ACTION_LOADER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ENTITY_ACTION] = function(self)
		--deprecated
	end,
	
	[SystemInitializer.SYSTEM_ID.COLLISION] = function(self)
		local system = require '/collision/CollisionSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.COLLISION] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.GAME_RENDERER] = function(self)
		local system = require '/render/GameRenderer'
		system:init()
		self.systemTable[self.SYSTEM_ID.GAME_RENDERER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.AREA_CREATION] = function(self)
		--deprecated
	end,
	
	[SystemInitializer.SYSTEM_ID.INTERACTION] = function(self)
		local system = require '/interaction/InteractionSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.INTERACTION] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.GAME_STATE_MANAGER] = function(self)
		local system = require '/state/GameStateManager'
		system:init()
		self.systemTable[self.SYSTEM_ID.GAME_STATE_MANAGER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.EVENT_SYSTEM] = function(self)
		local system = require '/event/EventSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.EVENT_SYSTEM] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.GAME_DATABASE] = function(self)
		local system = require '/persistent/GameDatabaseSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.GAME_DATABASE] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.SCENE_LOADER] = function(self)
		local system = require '/scene/SceneLoader'
		self.systemTable[self.SYSTEM_ID.SCENE_LOADER] = system
	end,

	[SystemInitializer.SYSTEM_ID.AREA_LOADER] = function(self)
		local system = require '/area/AreaLoader'
		self.systemTable[self.SYSTEM_ID.AREA_LOADER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ENTITY_LOADER] = function(self)
		local system = require '/entity/EntityLoader'
		system:init()
		self.systemTable[self.SYSTEM_ID.ENTITY_LOADER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.FLAG_LOADER] = function(self)
		local system = require '/flag/FlagLoader'
		system:init()
		self.systemTable[self.SYSTEM_ID.FLAG_LOADER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.SCENE_SCRIPT] = function(self)
		local system = require '/script/SceneScriptingSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.SCENE_SCRIPT] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.CAMERA] = function(self)
		local system = require '/camera/CameraSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.CAMERA] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.SPRITE_LOADER] = function(self)
		local system = require '/render/SpriteLoader'
		system:init()
		self.systemTable[self.SYSTEM_ID.SPRITE_LOADER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.SPATIAL_UPDATE] = function(self)
		local system = require '/spatial update/SpatialUpdateSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.SPATIAL_UPDATE] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ENTITY_SPAWN] = function(self)
		local system = require '/spawn/EntitySpawnSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.ENTITY_SPAWN] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ENTITY_DESPAWN] = function(self)
		local system = require '/despawn/EntityDespawnSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.ENTITY_DESPAWN] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ENTITY_SCRIPT] = function(self)
		local system = require '/entity script/EntityScriptSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.ENTITY_SCRIPT] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ENTITY_EVENT] = function(self)
		local system = require '/entity event/EntityEventSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.ENTITY_EVENT] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.SCENE_TRANSITION] = function(self)
		
	end,
	
	[SystemInitializer.SYSTEM_ID.INVENTORY_LOADER] = function(self)
		local system = require '/item/InventoryLoader'
		system:init()
		self.systemTable[self.SYSTEM_ID.INVENTORY_LOADER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.ITEM] = function(self)
		local system = require '/item/ItemSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.ITEM] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.IMAGE_LOADER] = function(self)
		local system = require '/render/ImageLoader'
		system:init()
		self.systemTable[self.SYSTEM_ID.IMAGE_LOADER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.COMBAT] = function(self)
		local system = require '/combat/EntityCombatSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.COMBAT] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.HEALTH] = function(self)
		local system = require '/health/EntityHealthSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.HEALTH] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.PROJECTILE] = function(self)
		local system = require '/projectile/ProjectileSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.PROJECTILE] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.VISUAL_EFFECT] = function(self)
		local system = require '/effect/VisualEffectSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.VISUAL_EFFECT] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.SOUND] = function(self)
		local system = require '/sound/SoundSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.SOUND] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.DIALOGUE_LOADER] = function(self)
		local system = require '/dialogue/DialogueLoader'
		system:init()
		self.systemTable[self.SYSTEM_ID.DIALOGUE_LOADER] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.DIALOGUE] = function(self)
		local system = require '/dialogue/DialogueSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.DIALOGUE] = system
	end,
	
	[SystemInitializer.SYSTEM_ID.FILE_HANDLING] = function(self)
		local system = require '/persistent/FileHandlingSystem'
		system:init()
		self.systemTable[self.SYSTEM_ID.FILE_HANDLING] = system
	end,
	
	--...
}

function SystemInitializer:initializeEventsOnSystems()
	for systemName, systemId in pairs(self.SYSTEM_ID) do
		self:initializeEventsOnSystem(systemId)
	end
end

function SystemInitializer:initializeEventsOnSystem(systemId)
	local eventSystem = self.systemTable[self.SYSTEM_ID.EVENT_SYSTEM]
	local system = self.systemTable[systemId]
	
	if eventSystem and system then
		eventSystem:setEventVariablesOnSystem(system)
	end
end

function SystemInitializer:initializeSystemsOnSceneScript()
	local system = self.systemTable[self.SYSTEM_ID.SCENE_SCRIPT]
	system:setDependencies(self.systemTable[self.SYSTEM_ID.FLAG_LOADER], 
		self.systemTable[self.SYSTEM_ID.ENTITY_LOADER], 
		self.systemTable[self.SYSTEM_ID.AREA_LOADER],
		self.systemTable[self.SYSTEM_ID.SPATIAL_PARTITIONING],
		self.systemTable[self.SYSTEM_ID.COLLISION]
		)
end

function SystemInitializer:initializeCameraOnSystems()
	local system = self.systemTable[self.SYSTEM_ID.CAMERA]
	system:setLensOnSystems()
end

function SystemInitializer:initializeGraphicsOnSystems()
	local spriteLoader = self.systemTable[self.SYSTEM_ID.SPRITE_LOADER]
	spriteLoader:setSpriteTablesOnAllSystems()
	--initialize other graphics related dependencies here
end

function SystemInitializer:initializeSpatialUpdaters()
	local collisionSystem = self.systemTable[self.SYSTEM_ID.COLLISION]
	collisionSystem:setUpdaterOnSpatialUpdaterSystem()
	local entityEventSystem = self.systemTable[self.SYSTEM_ID.ENTITY_EVENT]
	entityEventSystem:setUpdaterOnSpatialUpdaterSystem()
	local itemSystem = self.systemTable[self.SYSTEM_ID.ITEM]
	itemSystem:setUpdaterOnSpatialUpdaterSystem()
end

return SystemInitializer