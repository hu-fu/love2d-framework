local ENTITY_TYPE = require '/entity/ENTITY_TYPE'
local ENTITY_TEMPLATE_TYPE = require '/entity/ENTITY_TEMPLATE_TYPE'
local ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'

local ENTITY_TEMPLATE = {
	[ENTITY_TEMPLATE_TYPE.GENERIC_TEST_1] = {
		entityType = ENTITY_TYPE.GENERIC_ENTITY,
		
		components = {
			[ENTITY_COMPONENT.MAIN] = {
				id = 0
			},
			
			[ENTITY_COMPONENT.SCENE] = {
				defaultRole = 2,
				role = 2
			},
			
			[ENTITY_COMPONENT.SPRITEBOX] = {
				x = 0,
				y = 0,
				w = 75,
				h = 75,
				direction = 5,
				defaultSpritesheetId = 2,
				spritesheetId = 2,
				quad = 6,
				aniRepoId = 1
			},
			
			[ENTITY_COMPONENT.HITBOX] = {
				xDeviation = 20,
				yDeviation = 40,
				w = 35,
				h = 35,
				collisionType = 1,
				mapCollisionType = 3
			},
			
			[ENTITY_COMPONENT.ACTION_STATE] = {
				state = 2,	--set to 2 to start@spawn
				defaultState = 1
			},
			
			[ENTITY_COMPONENT.PLAYER_INPUT] = {
				state = true,
				controllerId = 'generic'
			},
			
			[ENTITY_COMPONENT.IDLE] = {
				state = false,
				actionSetId = 1,
				actionId = 2,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {}
			},
			
			[ENTITY_COMPONENT.MOVEMENT] = {
				velocity = 400,
				direction = 5,
				spritesheetId = 1,
				defaultQuad = 9,
				totalTime = 30,
				currentTime = 0,
				frequency = 10,
				updatePoint = 0,
				movementRepoId = 1,
				animationSetId = 1,
				animationId = 2
			},
			
			[ENTITY_COMPONENT.TARGETING] = {
				state = false,
				defaultTargetingType = 1,
				targetingType = 1,
				areaRadius = 3000,
				targetEntityType = 0,
				targetEntityRef = nil,
			},
			
			[ENTITY_COMPONENT.ACTION] = {
				state = false,
				defaultActionSetId = 1,
				actionPlayer = nil
			},
			
			[ENTITY_COMPONENT.SPAWN] = {
				state = false,
				scriptId = 1,
				actionSetId = 1,
				actionId = 1,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {},
				areaSpawnId = 'generic_spawn_1'
			},
			
			[ENTITY_COMPONENT.DESPAWN] = {
				state = false,
				scriptId = 1,
				actionSetId = 1,
				actionId = 3,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {},
			},
			
			[ENTITY_COMPONENT.INVENTORY] = {
				inventoryId = 'generic'
			},
			
			[ENTITY_COMPONENT.SCRIPT] = {
				state = false,
				activeScript = nil,
				currentTime = 0,
				autoScriptId = nil
			},
			
			[ENTITY_COMPONENT.EVENT] = {
				state = false,
				active = true,
				activatedBy = {},
				childRoles = {},
				
				actionSetId = 1,
				actionId = 4,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {}
			},
			
			[ENTITY_COMPONENT.COMBAT] = {
				state = false,
				actionSetId = 1,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {},
				attackEquipped = {{5,5,5},{5,5,5},{6,6,6}},
				moveEquipped = 5,
				specialEquipped = 5,
				lockupEquipped = 7,
				knockbackEquipped = 7,
				maxAttackEquipped = 3,
				maxAttackCombo = 3,
				attackComboState = {},
				comboActivation = false,
				currentStamina = 10000,
				maxStamina = 10000,
				staminaRecoveryRate = 0.25,
			},
			
			[ENTITY_COMPONENT.HEALTH] = {
				state = true,
				healthPoints = 100,
				maxHealthPoints = 100,
				healthPointsResistance = 0,
				healthPointsScript = 1,
				
				effects = true,
				activeScripts = {},
				
				healthPointsRegen = false,
				healthPointsRegenMultiplier = 1,
			},
		}
	},
	
	[ENTITY_TEMPLATE_TYPE.GENERIC_TEST_2] = {
		entityType = ENTITY_TYPE.GENERIC_ENTITY,
		
		components = {
			[ENTITY_COMPONENT.MAIN] = {
				id = 0
			},
			
			[ENTITY_COMPONENT.SCENE] = {
				defaultRole = 3,
				role = 3
			},
			
			[ENTITY_COMPONENT.SPRITEBOX] = {
				x = 0,
				y = 0,
				w = 75,
				h = 75,
				direction = 5,
				defaultSpritesheetId = 2,
				spritesheetId = 2,
				quad = 1,
				aniRepoId = 1
			},
		}
	},
		
	[ENTITY_TEMPLATE_TYPE.GENERIC_TEST_3] = {
		entityType = ENTITY_TYPE.GENERIC_ENTITY,
		
		components = {
			[ENTITY_COMPONENT.MAIN] = {
				id = 0
			},
			
			[ENTITY_COMPONENT.SCENE] = {
				defaultRole = 8,
				role = 8
			},
			
			[ENTITY_COMPONENT.SPRITEBOX] = {
				x = 0,
				y = 0,
				w = 75,
				h = 75,
				direction = 5,
				defaultSpritesheetId = 2,
				spritesheetId = 2,
				quad = 1,
				aniRepoId = 1
			},
			
			[ENTITY_COMPONENT.HITBOX] = {
				xDeviation = 0,
				yDeviation = 0,
				w = 100,
				h = 100,
				collisionType = 1,
				mapCollisionType = 3
			},
			
			[ENTITY_COMPONENT.EVENT] = {
				state = false,
				active = true,
				activatedBy = {2},
				childRoles = {2,3},
				
				actionSetId = 2,
				actionId = 2,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {}
			},
		}
	},
	
	[ENTITY_TEMPLATE_TYPE.GENERIC_TEST_4] = {
		entityType = ENTITY_TYPE.GENERIC_ENTITY,
		
		components = {
			[ENTITY_COMPONENT.MAIN] = {
				id = 0
			},
			
			[ENTITY_COMPONENT.SCENE] = {
				defaultRole = 8,
				role = 8
			},
			
			[ENTITY_COMPONENT.SPRITEBOX] = {
				x = 0,
				y = 0,
				w = 15,
				h = 15,
				direction = 5,
				defaultSpritesheetId = 2,
				spritesheetId = 2,
				quad = 1,
				aniRepoId = 1
			},
			
			[ENTITY_COMPONENT.HITBOX] = {
				xDeviation = 0,
				yDeviation = 0,
				w = 15,
				h = 15,
				collisionType = 1,
				mapCollisionType = 3
			},
			
			[ENTITY_COMPONENT.ITEM] = {
				state = true,
				itemType = 'generic',
				itemId = 'generic',
				itemQuantity = 1
			},
		}
	},
	
	--...
}

return ENTITY_TEMPLATE