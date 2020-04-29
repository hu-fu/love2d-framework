--Just an example on how to move templates into separate files

local ENTITY_TYPE = require '/entity/ENTITY_TYPE'
local ENTITY_TEMPLATE_TYPE = require '/entity/ENTITY_TEMPLATE_TYPE'
local ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'

local TEMPLATE = {
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
				w = 50,
				h = 50,
				direction = 5,
				defaultSpritesheetId = 23,
				spritesheetId = 23,
				quad = 5,
				aniRepoId = 1
			},
			
			[ENTITY_COMPONENT.HITBOX] = {
				xDeviation = 13,
				yDeviation = 34,
				w = 23,
				h = 23,
				collisionType = 1,
				mapCollisionType = 3
			},
			
			[ENTITY_COMPONENT.ACTION_STATE] = {
				state = 2,	--set to 2 to start@spawn
				defaultState = 1
			},
			
			[ENTITY_COMPONENT.INPUT] = {
				state = true,
				defaultControllerId = 'player_generic',
				controllerId = 'player_generic',
				playerInputState = false,
			},
			
			[ENTITY_COMPONENT.IDLE] = {
				state = false,
				defaultActionSetId = 4,
				defaultActionId = 2,
				actionSetId = 4,
				actionId = 2,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {}
			},
			
			[ENTITY_COMPONENT.MOVEMENT] = {
				velocity = 300,
				direction = 5,
				spritesheetId = 23,
				defaultQuad = 9,
				totalTime = 30,
				currentTime = 0,
				frequency = 10,
				updatePoint = 0,
				movementRepoId = 1,
				defaultAnimationSetId = 2,
				defaultAnimationId = 2,
				animationSetId = 2,
				animationId = 2
			},
			
			[ENTITY_COMPONENT.TARGETING] = {
				state = false,
				auto = true,
				defaultTargetingType = 1,
				targetingType = 1,
				areaRadius = 3000,
				targetEntityType = 0,
				targetEntityRef = nil,
				directionLock = true,
				direction = false,
				animationChange = true,
			},
			
			[ENTITY_COMPONENT.ACTION] = {
				state = false,
				defaultActionSetId = 1,
				actionPlayer = nil
			},
			
			[ENTITY_COMPONENT.SPAWN] = {
				state = false,
				scriptId = 1,
				actionSetId = 4,
				actionId = 1,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {},
				areaSpawnId = nil,	--this overwrites loaded entity position if not nil
			},
			
			[ENTITY_COMPONENT.DESPAWN] = {
				state = false,
				scriptId = 1,
				actionSetId = 4,
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
				
				actionSetId = 4,
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
				actionSetId = 4,
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
				currentStamina = 100,
				maxStamina = 100,
				staminaRecoveryRate = 0.15,
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
				
				immunity = false,
				immunityActive = false,
				immunityTime = 0,
			},
			
			[ENTITY_COMPONENT.DIALOGUE] = {
				state = true,
				dialogueId = 1,
			},
		}
	}
	
return TEMPLATE