local SYSTEM_ID = require '/system/SYSTEM_ID'
local EVENT_METHOD = require '/event/EVENT_METHOD'
local EVENT_LISTENER = require '/event/EVENT_LISTENER'
local EVENT_DISPATCHER = require '/event/EVENT_DISPATCHER'

local EVENT_ADDRESS = {}

EVENT_ADDRESS.LISTENER_MAP = {
	[EVENT_LISTENER.ANIMATION] = {
		
	},
	[EVENT_LISTENER.IDLE] = {
		[EVENT_DISPATCHER.PLAYER_ENTITY_CONTROLLER] = {2},
		[EVENT_DISPATCHER.ENTITY_SCRIPT] = {2},
		[EVENT_DISPATCHER.ENTITY_LOADER] = {8}
	},
	[EVENT_LISTENER.PLAYER_ENTITY_CONTROLLER] = {
		[EVENT_DISPATCHER.PLAYER_INPUT] = {2},
		[EVENT_DISPATCHER.ENTITY_LOADER] = {5},
		[EVENT_DISPATCHER.ENTITY_SPAWN] = {3},
		[EVENT_DISPATCHER.INTERACTION] = {2},
		[EVENT_DISPATCHER.ENTITY_EVENT] = {5},
		[EVENT_DISPATCHER.COMBAT] = {3},
	},
	[EVENT_LISTENER.ENTITY_MOVEMENT] = {
		[EVENT_DISPATCHER.PLAYER_ENTITY_CONTROLLER] = {1},
		[EVENT_DISPATCHER.ENTITY_SCRIPT] = {1},
		[EVENT_DISPATCHER.ENTITY_LOADER] = {6}
	},
	[EVENT_LISTENER.PLAYER_INPUT] = {
	},
	[EVENT_LISTENER.SPATIAL_PARTITIONING] = {
		[EVENT_DISPATCHER.COLLISION] = {1},
		[EVENT_DISPATCHER.TARGETING] = {1},
		[EVENT_DISPATCHER.GAME_RENDERER] = {1},
		[EVENT_DISPATCHER.AREA_CREATION] = {1},
		[EVENT_DISPATCHER.INTERACTION] = {1},
		[EVENT_DISPATCHER.AREA_LOADER] = {2},
		[EVENT_DISPATCHER.ENTITY_LOADER] = {3},
		[EVENT_DISPATCHER.SPATIAL_UPDATE] = {1},
		[EVENT_DISPATCHER.ITEM] = {2},
		[EVENT_DISPATCHER.PROJECTILE] = {2},
		[EVENT_DISPATCHER.VISUAL_EFFECT] = {2},
	},
	[EVENT_LISTENER.TARGETING] = {
		[EVENT_DISPATCHER.ENTITY_LOADER] = {9},
		[EVENT_DISPATCHER.PLAYER_ENTITY_CONTROLLER] = {3},
		[EVENT_DISPATCHER.ENTITY_SCRIPT] = {3},
	},
	[EVENT_LISTENER.ANIMATION_LOADER] = {
		[EVENT_DISPATCHER.ENTITY_ANIMATION] = {1}
	},
	[EVENT_LISTENER.ENTITY_ANIMATION] = {
		[EVENT_DISPATCHER.ENTITY_LOADER] = {7},
		[EVENT_DISPATCHER.IDLE] = {2},
		[EVENT_DISPATCHER.ENTITY_MOVEMENT] = {2},
		[EVENT_DISPATCHER.ENTITY_SPAWN] = {2},
		[EVENT_DISPATCHER.ENTITY_DESPAWN] = {2},
		[EVENT_DISPATCHER.ENTITY_EVENT] = {3},
		[EVENT_DISPATCHER.COMBAT] = {2},
	},
	[EVENT_LISTENER.ACTION_LOADER] = {
		[EVENT_DISPATCHER.IDLE] = {1},
		[EVENT_DISPATCHER.ENTITY_SPAWN] = {1},
		[EVENT_DISPATCHER.ENTITY_DESPAWN] = {1},
		[EVENT_DISPATCHER.ENTITY_EVENT] = {2},
		[EVENT_DISPATCHER.COMBAT] = {1},
		[EVENT_DISPATCHER.VISUAL_EFFECT] = {1},
	},
	[EVENT_LISTENER.ENTITY_ACTION] = {
	},
	[EVENT_LISTENER.GAME_RENDERER] = {
		[EVENT_DISPATCHER.CAMERA] = {1},
		[EVENT_DISPATCHER.SPRITE_LOADER] = {1},
		[EVENT_DISPATCHER.AREA_LOADER] = {4},
		[EVENT_DISPATCHER.IMAGE_LOADER] = {1},
		[EVENT_DISPATCHER.PROJECTILE] = {1},
		[EVENT_DISPATCHER.VISUAL_EFFECT] = {3},
	},
	[EVENT_LISTENER.AREA_CREATION] = {
	},
	[EVENT_LISTENER.COLLISION] = {
	},
	[EVENT_LISTENER.INTERACTION] = {
		[EVENT_DISPATCHER.PLAYER_ENTITY_CONTROLLER] = {5},
	},
	[EVENT_LISTENER.GAME_STATE_MANAGER] = {
		[EVENT_DISPATCHER.SCENE_LOADER] = {5},
	},
	[EVENT_LISTENER.EVENT_SYSTEM] = {
		
	},
	[EVENT_LISTENER.GAME_DATABASE] = {
		[EVENT_DISPATCHER.SCENE_LOADER] = {1},
		[EVENT_DISPATCHER.AREA_LOADER] = {1},
		[EVENT_DISPATCHER.ENTITY_LOADER] = {1},
		[EVENT_DISPATCHER.FLAG_LOADER] = {1},
		[EVENT_DISPATCHER.PLAYER_INPUT] = {1},
		[EVENT_DISPATCHER.INVENTORY_LOADER] = {1}
	},
	[EVENT_LISTENER.SCENE_LOADER] = {
		[EVENT_DISPATCHER.ENTITY_EVENT] = {4},
	},
	[EVENT_LISTENER.AREA_LOADER] = {
		[EVENT_DISPATCHER.SCENE_LOADER] = {2}
	},
	[EVENT_LISTENER.ENTITY_LOADER] = {
		[EVENT_DISPATCHER.SCENE_LOADER] = {3}
	},
	[EVENT_LISTENER.FLAG_LOADER] = {
		
	},
	[EVENT_LISTENER.SCENE_SCRIPT] = {
		[EVENT_DISPATCHER.SCENE_LOADER] = {4}
	},
	[EVENT_LISTENER.CAMERA] = {
		[EVENT_DISPATCHER.ENTITY_LOADER] = {2}
	},
	[EVENT_LISTENER.SPRITE_LOADER] = {
		[EVENT_DISPATCHER.ENTITY_LOADER] = {4}
	},
	[EVENT_LISTENER.SPATIAL_UPDATE] = {
		[EVENT_DISPATCHER.CAMERA] = {2},
		[EVENT_DISPATCHER.COLLISION] = {2},
		[EVENT_DISPATCHER.ENTITY_EVENT] = {1},
		[EVENT_DISPATCHER.ITEM] = {1},
	},
	[EVENT_LISTENER.ENTITY_SPAWN] = {
		[EVENT_DISPATCHER.ENTITY_LOADER] = {10},
		[EVENT_DISPATCHER.AREA_LOADER] = {3},
	},
	[EVENT_LISTENER.ENTITY_DESPAWN] = {
		[EVENT_DISPATCHER.ENTITY_LOADER] = {11},
		[EVENT_DISPATCHER.PLAYER_ENTITY_CONTROLLER] = {4},
		[EVENT_DISPATCHER.ENTITY_SCRIPT] = {4},
		[EVENT_DISPATCHER.HEALTH] = {1},
	},
	[EVENT_LISTENER.ENTITY_SCRIPT] = {
		[EVENT_DISPATCHER.ENTITY_LOADER] = {14},
		[EVENT_DISPATCHER.FLAG_LOADER] = {3},
	},
	[EVENT_LISTENER.ENTITY_EVENT] = {
		[EVENT_DISPATCHER.FLAG_LOADER] = {2},
		[EVENT_DISPATCHER.ENTITY_LOADER] = {12},
		[EVENT_DISPATCHER.PLAYER_ENTITY_CONTROLLER] = {6},
	},
	[EVENT_LISTENER.SCENE_TRANSITION] = {
		
	},
	[EVENT_LISTENER.INVENTORY_LOADER] = {
		
	},
	[EVENT_LISTENER.ITEM] = {
		[EVENT_DISPATCHER.ENTITY_LOADER] = {13},
	},
	[EVENT_LISTENER.IMAGE_LOADER] = {
		[EVENT_DISPATCHER.AREA_LOADER] = {5},
	},
	[EVENT_LISTENER.COMBAT] = {
		[EVENT_DISPATCHER.PLAYER_ENTITY_CONTROLLER] = {7},
		[EVENT_DISPATCHER.ENTITY_LOADER] = {15}
	},
	[EVENT_LISTENER.HEALTH] = {
		[EVENT_DISPATCHER.ENTITY_LOADER] = {16},
		[EVENT_DISPATCHER.COMBAT] = {6},
	},
	[EVENT_LISTENER.PROJECTILE] = {
		[EVENT_DISPATCHER.COMBAT] = {4},
		[EVENT_DISPATCHER.COLLISION] = {3},
	},
	[EVENT_LISTENER.VISUAL_EFFECT] = {
		[EVENT_DISPATCHER.COMBAT] = {5},
	},
	[EVENT_LISTENER.SOUND] = {
		[EVENT_DISPATCHER.COMBAT] = {7},
		[EVENT_DISPATCHER.ENTITY_LOADER] = {17}
	},
	[EVENT_LISTENER.DIALOGUE_LOADER] = {
		[EVENT_DISPATCHER.COMBAT] = {8},
	},
	--...
}

EVENT_ADDRESS.SYSTEM_DISPATCHER_MAP = {
	[SYSTEM_ID.ANIMATION] = EVENT_DISPATCHER.ANIMATION,
	[SYSTEM_ID.IDLE] = EVENT_DISPATCHER.IDLE,
	[SYSTEM_ID.PLAYER_ENTITY_CONTROLLER] = EVENT_DISPATCHER.PLAYER_ENTITY_CONTROLLER,
	[SYSTEM_ID.ENTITY_MOVEMENT] = EVENT_DISPATCHER.ENTITY_MOVEMENT,
	[SYSTEM_ID.PLAYER_INPUT] = EVENT_DISPATCHER.PLAYER_INPUT,
	[SYSTEM_ID.SPATIAL_PARTITIONING] = EVENT_DISPATCHER.SPATIAL_PARTITIONING,
	[SYSTEM_ID.TARGETING] = EVENT_DISPATCHER.TARGETING,
	[SYSTEM_ID.ANIMATION_LOADER] = EVENT_DISPATCHER.ANIMATION_LOADER,
	[SYSTEM_ID.ENTITY_ANIMATION] = EVENT_DISPATCHER.ENTITY_ANIMATION,
	[SYSTEM_ID.ACTION_LOADER] = EVENT_DISPATCHER.ACTION_LOADER,
	[SYSTEM_ID.ENTITY_ACTION] = EVENT_DISPATCHER.ENTITY_ACTION,
	[SYSTEM_ID.COLLISION] = EVENT_DISPATCHER.COLLISION,
	[SYSTEM_ID.GAME_RENDERER] = EVENT_DISPATCHER.GAME_RENDERER,
	[SYSTEM_ID.AREA_CREATION] = EVENT_DISPATCHER.AREA_CREATION,
	[SYSTEM_ID.INTERACTION] = EVENT_DISPATCHER.INTERACTION,
	[SYSTEM_ID.GAME_STATE_MANAGER] = EVENT_DISPATCHER.GAME_STATE_MANAGER,
	[SYSTEM_ID.EVENT_SYSTEM] = EVENT_DISPATCHER.EVENT_SYSTEM,
	[SYSTEM_ID.GAME_DATABASE] = EVENT_DISPATCHER.GAME_DATABASE,
	[SYSTEM_ID.SCENE_LOADER] = EVENT_DISPATCHER.SCENE_LOADER,
	[SYSTEM_ID.AREA_LOADER] = EVENT_DISPATCHER.AREA_LOADER,
	[SYSTEM_ID.ENTITY_LOADER] = EVENT_DISPATCHER.ENTITY_LOADER,
	[SYSTEM_ID.FLAG_LOADER] = EVENT_DISPATCHER.FLAG_LOADER,
	[SYSTEM_ID.SCENE_SCRIPT] = EVENT_DISPATCHER.SCENE_SCRIPT,
	[SYSTEM_ID.CAMERA] = EVENT_DISPATCHER.CAMERA,
	[SYSTEM_ID.SPRITE_LOADER] = EVENT_DISPATCHER.SPRITE_LOADER,
	[SYSTEM_ID.SPATIAL_UPDATE] = EVENT_DISPATCHER.SPATIAL_UPDATE,
	[SYSTEM_ID.ENTITY_SPAWN] = EVENT_DISPATCHER.ENTITY_SPAWN,
	[SYSTEM_ID.ENTITY_DESPAWN] = EVENT_DISPATCHER.ENTITY_DESPAWN,
	[SYSTEM_ID.ENTITY_SCRIPT] = EVENT_DISPATCHER.ENTITY_SCRIPT,
	[SYSTEM_ID.ENTITY_EVENT] = EVENT_DISPATCHER.ENTITY_EVENT,
	[SYSTEM_ID.SCENE_TRANSITION] = EVENT_DISPATCHER.SCENE_TRANSITION,
	[SYSTEM_ID.INVENTORY_LOADER] = EVENT_DISPATCHER.INVENTORY_LOADER,
	[SYSTEM_ID.ITEM] = EVENT_DISPATCHER.ITEM,
	[SYSTEM_ID.IMAGE_LOADER] = EVENT_DISPATCHER.IMAGE_LOADER,
	[SYSTEM_ID.COMBAT] = EVENT_DISPATCHER.COMBAT,
	[SYSTEM_ID.HEALTH] = EVENT_DISPATCHER.HEALTH,
	[SYSTEM_ID.PROJECTILE] = EVENT_DISPATCHER.PROJECTILE,
	[SYSTEM_ID.VISUAL_EFFECT] = EVENT_DISPATCHER.VISUAL_EFFECT,
	[SYSTEM_ID.SOUND] = EVENT_DISPATCHER.SOUND,
	[SYSTEM_ID.DIALOGUE_LOADER] = EVENT_DISPATCHER.DIALOGUE_LOADER,
}

EVENT_ADDRESS.SYSTEM_LISTENER_INDEX = {
	[SYSTEM_ID.ANIMATION] = {
		MAIN = 1
	},
	[SYSTEM_ID.IDLE] = {
		MAIN = 1
	},
	[SYSTEM_ID.PLAYER_ENTITY_CONTROLLER] = {
		MAIN = 1
	},
	[SYSTEM_ID.ENTITY_MOVEMENT] = {
		MAIN = 1
	},
	[SYSTEM_ID.PLAYER_INPUT] = {
		MAIN = 1
	},
	[SYSTEM_ID.SPATIAL_PARTITIONING] = {
		MAIN = 1
	},
	[SYSTEM_ID.TARGETING] = {
		MAIN = 1
	},
	[SYSTEM_ID.ANIMATION_LOADER] = {
		MAIN = 1
	},
	[SYSTEM_ID.ENTITY_ANIMATION] = {
		MAIN = 1
	},
	[SYSTEM_ID.ACTION_LOADER] = {
		MAIN = 1
	},
	[SYSTEM_ID.ENTITY_ACTION] = {
		MAIN = 1
	},
	[SYSTEM_ID.COLLISION] = {
		MAIN = 1
	},
	[SYSTEM_ID.GAME_RENDERER] = {
		MAIN = 1
	},
	[SYSTEM_ID.AREA_CREATION] = {
		MAIN = 1
	},
	[SYSTEM_ID.INTERACTION] = {
		MAIN = 1
	},
	[SYSTEM_ID.GAME_STATE_MANAGER] = {
		MAIN = 1
	},
	[SYSTEM_ID.EVENT_SYSTEM] = {
		MAIN = 1
	},
	[SYSTEM_ID.GAME_DATABASE] = {
		MAIN = 1
	},
	[SYSTEM_ID.SCENE_LOADER] = {
		MAIN = 1
	},
	[SYSTEM_ID.AREA_LOADER] = {
		MAIN = 1
	},
	[SYSTEM_ID.ENTITY_LOADER] = {
		MAIN = 1
	},
	[SYSTEM_ID.FLAG_LOADER] = {
		MAIN = 1
	},
	[SYSTEM_ID.SCENE_SCRIPT] = {
		MAIN = 1
	},
	[SYSTEM_ID.CAMERA] = {
		MAIN = 1
	},
	[SYSTEM_ID.SPRITE_LOADER] = {
		MAIN = 1
	},
	[SYSTEM_ID.SPATIAL_UPDATE] = {
		MAIN = 1
	},
	[SYSTEM_ID.ENTITY_SPAWN] = {
		MAIN = 1
	},
	[SYSTEM_ID.ENTITY_DESPAWN] = {
		MAIN = 1
	},
	[SYSTEM_ID.ENTITY_SCRIPT] = {
		MAIN = 1
	},
	[SYSTEM_ID.ENTITY_EVENT] = {
		MAIN = 1
	},
	[SYSTEM_ID.SCENE_TRANSITION] = {
		MAIN = 1
	},
	[SYSTEM_ID.INVENTORY_LOADER] = {
		MAIN = 1
	},
	[SYSTEM_ID.ITEM] = {
		MAIN = 1
	},
	[SYSTEM_ID.IMAGE_LOADER] = {
		MAIN = 1
	},
	[SYSTEM_ID.COMBAT] = {
		MAIN = 1
	},
	[SYSTEM_ID.HEALTH] = {
		MAIN = 1
	},
	[SYSTEM_ID.PROJECTILE] = {
		MAIN = 1
	},
	[SYSTEM_ID.VISUAL_EFFECT] = {
		MAIN = 1
	},
	[SYSTEM_ID.SOUND] = {
		MAIN = 1
	},
	[SYSTEM_ID.DIALOGUE_LOADER] = {
		MAIN = 1
	},
}

EVENT_ADDRESS.SYSTEM_LISTENER_INDEX_MAP = {
	[SYSTEM_ID.ANIMATION] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ANIMATION].MAIN] = EVENT_LISTENER.ANIMATION
	},
	[SYSTEM_ID.IDLE] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.IDLE].MAIN] = EVENT_LISTENER.IDLE
	},
	[SYSTEM_ID.PLAYER_ENTITY_CONTROLLER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.PLAYER_ENTITY_CONTROLLER].MAIN] = EVENT_LISTENER.PLAYER_ENTITY_CONTROLLER
	},
	[SYSTEM_ID.ENTITY_MOVEMENT] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ENTITY_MOVEMENT].MAIN] = EVENT_LISTENER.ENTITY_MOVEMENT
	},
	[SYSTEM_ID.PLAYER_INPUT] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.PLAYER_INPUT].MAIN] = EVENT_LISTENER.PLAYER_INPUT
	},
	[SYSTEM_ID.SPATIAL_PARTITIONING] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.SPATIAL_PARTITIONING].MAIN] = EVENT_LISTENER.SPATIAL_PARTITIONING
	},
	[SYSTEM_ID.TARGETING] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.TARGETING].MAIN] = EVENT_LISTENER.TARGETING
	},
	[SYSTEM_ID.ANIMATION_LOADER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ANIMATION_LOADER].MAIN] = EVENT_LISTENER.ANIMATION_LOADER
	},
	[SYSTEM_ID.ENTITY_ANIMATION] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ENTITY_ANIMATION].MAIN] = EVENT_LISTENER.ENTITY_ANIMATION
	},
	[SYSTEM_ID.ACTION_LOADER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ACTION_LOADER].MAIN] = EVENT_LISTENER.ACTION_LOADER
	},
	[SYSTEM_ID.ENTITY_ACTION] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ENTITY_ACTION].MAIN] = EVENT_LISTENER.ENTITY_ACTION
	},
	[SYSTEM_ID.COLLISION] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.COLLISION].MAIN] = EVENT_LISTENER.COLLISION
	},
	[SYSTEM_ID.GAME_RENDERER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.GAME_RENDERER].MAIN] = EVENT_LISTENER.GAME_RENDERER
	},
	[SYSTEM_ID.AREA_CREATION] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.AREA_CREATION].MAIN] = EVENT_LISTENER.AREA_CREATION
	},
	[SYSTEM_ID.INTERACTION] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.INTERACTION].MAIN] = EVENT_LISTENER.INTERACTION
	},
	[SYSTEM_ID.GAME_STATE_MANAGER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.GAME_STATE_MANAGER].MAIN] = EVENT_LISTENER.GAME_STATE_MANAGER
	},
	[SYSTEM_ID.EVENT_SYSTEM] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.EVENT_SYSTEM].MAIN] = EVENT_LISTENER.EVENT_SYSTEM
	},
	[SYSTEM_ID.GAME_DATABASE] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.GAME_DATABASE].MAIN] = EVENT_LISTENER.GAME_DATABASE
	},
	[SYSTEM_ID.SCENE_LOADER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.SCENE_LOADER].MAIN] = EVENT_LISTENER.SCENE_LOADER
	},
	[SYSTEM_ID.AREA_LOADER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.AREA_LOADER].MAIN] = EVENT_LISTENER.AREA_LOADER
	},
	[SYSTEM_ID.ENTITY_LOADER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ENTITY_LOADER].MAIN] = EVENT_LISTENER.ENTITY_LOADER
	},
	[SYSTEM_ID.FLAG_LOADER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.FLAG_LOADER].MAIN] = EVENT_LISTENER.FLAG_LOADER
	},
	[SYSTEM_ID.SCENE_SCRIPT] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.SCENE_SCRIPT].MAIN] = EVENT_LISTENER.SCENE_SCRIPT
	},
	[SYSTEM_ID.CAMERA] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.CAMERA].MAIN] = EVENT_LISTENER.CAMERA
	},
	[SYSTEM_ID.SPRITE_LOADER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.SPRITE_LOADER].MAIN] = EVENT_LISTENER.SPRITE_LOADER
	},
	[SYSTEM_ID.SPATIAL_UPDATE] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.SPATIAL_UPDATE].MAIN] = EVENT_LISTENER.SPATIAL_UPDATE
	},
	[SYSTEM_ID.ENTITY_SPAWN] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ENTITY_SPAWN].MAIN] = EVENT_LISTENER.ENTITY_SPAWN
	},
	[SYSTEM_ID.ENTITY_DESPAWN] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ENTITY_DESPAWN].MAIN] = EVENT_LISTENER.ENTITY_DESPAWN
	},
	[SYSTEM_ID.ENTITY_SCRIPT] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ENTITY_SCRIPT].MAIN] = EVENT_LISTENER.ENTITY_SCRIPT
	},
	[SYSTEM_ID.ENTITY_EVENT] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ENTITY_EVENT].MAIN] = EVENT_LISTENER.ENTITY_EVENT
	},
	[SYSTEM_ID.SCENE_TRANSITION] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.SCENE_TRANSITION].MAIN] = EVENT_LISTENER.SCENE_TRANSITION
	},
	[SYSTEM_ID.INVENTORY_LOADER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.INVENTORY_LOADER].MAIN] = EVENT_LISTENER.INVENTORY_LOADER
	},
	[SYSTEM_ID.ITEM] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.ITEM].MAIN] = EVENT_LISTENER.ITEM
	},
	[SYSTEM_ID.IMAGE_LOADER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.IMAGE_LOADER].MAIN] = EVENT_LISTENER.IMAGE_LOADER
	},
	[SYSTEM_ID.COMBAT] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.COMBAT].MAIN] = EVENT_LISTENER.COMBAT
	},
	[SYSTEM_ID.HEALTH] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.HEALTH].MAIN] = EVENT_LISTENER.HEALTH
	},
	[SYSTEM_ID.PROJECTILE] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.PROJECTILE].MAIN] = EVENT_LISTENER.PROJECTILE
	},
	[SYSTEM_ID.VISUAL_EFFECT] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.VISUAL_EFFECT].MAIN] = EVENT_LISTENER.VISUAL_EFFECT
	},
	[SYSTEM_ID.SOUND] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.SOUND].MAIN] = EVENT_LISTENER.SOUND
	},
	[SYSTEM_ID.DIALOGUE_LOADER] = {
		[EVENT_ADDRESS.SYSTEM_LISTENER_INDEX[SYSTEM_ID.DIALOGUE_LOADER].MAIN] = EVENT_LISTENER.DIALOGUE_LOADER
	},
}

return EVENT_ADDRESS