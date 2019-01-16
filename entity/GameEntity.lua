-----------------
--Entity factory:
-----------------

GameEntityBuilder = {}
GameEntityBuilder.__index = GameEntityBuilder

setmetatable(GameEntityBuilder, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function GameEntityBuilder.new ()
	local self = setmetatable ({}, GameEntityBuilder)
		self.ENTITY_COMPONENTS = require '/entity/ENTITY_COMPONENT'
		
		self.createComponentMethods = nil
		self:setCreateComponentMethods()
		
		self.addComponentToEntityMethods = nil
		self:setAddComponentToEntityMethods()
	return self
end

function GameEntityBuilder:createEntity()
	return GameEntity.new()
end

function GameEntityBuilder:createComponent(componentType)
	return self.createComponentMethods[componentType]()
end

function GameEntityBuilder:setCreateComponentMethods()
	self.createComponentMethods = {
		
		[self.ENTITY_COMPONENTS.MAIN] = function()	
			return {
				componentTable = nil,
				id = 0,
				entityType = 0,
				templateType = 0
			}
		end,
		
		[self.ENTITY_COMPONENTS.SCENE] = function()	
			return {
				componentTable = nil,
				defaultRole = 0,
				role = 0,
				flat = true
			}
		end,
		
		[self.ENTITY_COMPONENTS.SPRITEBOX] = function()	
			return {
				componentTable = nil,
				x = 0,
				y = 0,
				w = 0,
				h = 0,
				direction = 5,
				defaultSpritesheetId = 0,
				spritesheetId = 0,
				quad = 0,
				aniRepoId = 0,				--remove
				
				--new additions:
				defaultAnimationSetId = 0,
				animationPlayer = nil,
				
				--even newer:
				effectEmitter = nil,
				
				spatialEntity = nil
			}
		end,
		
		[self.ENTITY_COMPONENTS.HITBOX] = function()	
			return {
				componentTable = nil,
				xDeviation = 0,
				yDeviation = 0,
				x = 0,
				y = 0,
				w = 0,
				h = 0,
				collisionType = 0,
				mapCollisionType = 0,
				m = nil,	--slope
				b = nil,	--y intercept
				spatialEntity = nil
			}
		end,
		
		[self.ENTITY_COMPONENTS.TRANSPORT] = function()
			return {
				componentTable = nil,
				active = false,
				controlType = 1,
				collisionType = 1,
				x = 0,				--deviation from hitbox
				y = 0,				--deviation from hitbox
				w = 0,
				h = 0,
				waypoints = {}		--make a target list object
			}
		end,
		
		[self.ENTITY_COMPONENTS.ACTION_STATE] = function()	
			return {
				componentTable = nil,
				state = 0,
				defaultState = 0
			}
		end,
		
		[self.ENTITY_COMPONENTS.INPUT] = function()	
			return {
				componentTable = nil,
				state = false,
				defaultControllerId = nil,
				controllerId = nil,
				controller = nil,
				playerInputState = false,
			}
		end,
		
		[self.ENTITY_COMPONENTS.IDLE] = function()	
			return {
				componentTable = nil,
				state = false,
				
				--action variables:
				defaultActionSetId = 0,
				defaultActionId = 0,
				actionSetId = 0,
				actionId = 0,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {},
				
				--new additions:
				animationSetId = 0,
				animationId = 0
			}
		end,
		
		[self.ENTITY_COMPONENTS.MOVEMENT] = function()	
			return {
				componentTable = nil,
				state = false,
				defaultVelocity = 0,
				velocity = 0,
				rotation = 0,
				direction = 0,
				defaultAnimationSetId = 0,
				defaultAnimationId = 0,
				animationSetId = 0,
				animationId = 0
			}
		end,
		
		[self.ENTITY_COMPONENTS.TARGETING] = function()	
			return {
				componentTable = nil,
				state = false,
				auto = false,
				defaultTargetingType = 0,	--deprecated:useless
				targetingType = 0,			--deprecated:useless
				areaRadius = 0,
				distanceToTarget = 0,
				targetEntityType = 0,		--deprecated: all are generic type
				targetHitbox = nil,
				directionLock = true,
				direction = 0,
				animationChange = false,	--animation changes relative to current target/direction lock
			}
		end,
		
		[self.ENTITY_COMPONENTS.ACTION] = function()	
			return {
				--deprecated
				state = false,
				defaultActionSetId = 0,		--not even needed
				actionPlayer = nil
			}
		end,
		
		[self.ENTITY_COMPONENTS.SPAWN] = function()	
			return {
				componentTable = nil,
				state = false,
				scriptId = 0,
				
				actionSetId = 0,
				actionId = 0,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {},
				
				areaSpawnId = nil
			}
		end,
		
		[self.ENTITY_COMPONENTS.DESPAWN] = function()	
			return {
				componentTable = nil,
				state = false,
				scriptId = 0,
				
				actionSetId = 0,
				actionId = 0,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {},
				
				animationSetId = 0,
				animationId = 0
			}
		end,
		
		[self.ENTITY_COMPONENTS.SCRIPT] = function()	
			return {
				componentTable = nil,
				state = false,
				activeScript = nil,
				currentTime = 0,
				autoScriptId = nil
			}
		end,
		
		[self.ENTITY_COMPONENTS.EVENT] = function()	
			return {
				componentTable = nil,
				state = false,
				active = true,
				activatedBy = {},
				childRoles = {},
				childEntities = {},
				
				actionSetId = 0,
				actionId = 0,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {},
				
				animationSetId = 0,
				animationId = 0
			}
		end,
		
		[self.ENTITY_COMPONENTS.ITEM] = function()	
			return {
				componentTable = nil,
				state = false,
				itemType = 0,
				itemId = 0,
				itemQuantity = 0
			}
		end,
		
		[self.ENTITY_COMPONENTS.INVENTORY] = function()	
			return {
				componentTable = nil,
				inventoryId = 0
			}
		end,
		
		[self.ENTITY_COMPONENTS.COMBAT] = function()	
			return {
				componentTable = nil,
				state = 0,
				
				actionSetId = nil,
				action = nil,
				currentTime = 0,
				updatePoint = 0,
				frameCounter = 0,
				currentMethodIndex = 1,
				methodThreads = {},
				
				attackEquipped = {},
				moveEquipped = 0,
				specialEquipped = 0,
				lockupEquipped = 0,
				knockbackEquipped = 0,
				maxAttackEquipped = nil,	--wut
				maxAttackCombo = nil,
				attackComboState = {},
				comboActivation = false,
				currentStamina = 0,
				maxStamina = 0,
				staminaRecoveryRate = 0,
			}
		end,
		
		[self.ENTITY_COMPONENTS.HEALTH] = function()	
			return {
				componentTable = nil,
				state = true,
				
				--*pools are arbitrary and their behavior is defined in the health scripts*--
				
				healthPoints = 0,
				maxHealthPoints = 0,
				healthPointsResistance = 0,
				healthPointsScript = nil,
				
				healthPointsRegen = false,
				healthPointsRegenMultiplier = 0,
				healthPointsRegenTime = 0,
				
				immunity = false,
				immunityActive = false,
				immunityTime = 0,
				
				effects = false,
				activeScripts = {},
			}
		end,
		
		[self.ENTITY_COMPONENTS.DIALOGUE] = function()	
			return {
				componentTable = nil,
				state = false,
				
				dialogueId = nil,
				dialoguePlayer = nil
			}
		end,
		
		--...
	}
end

function GameEntityBuilder:addComponentToEntity(entity, componentType, component)
	self.addComponentToEntityMethods[componentType](entity, component)
end

function GameEntityBuilder:setAddComponentToEntityMethods()
	--component dependency mapping, should go into the ENTITY_COMPONENT file
	--looks horrible, but the idea is good
	
	self.addComponentToEntityMethods = {
		[self.ENTITY_COMPONENTS.MAIN] = function(entity, component)
			component.componentTable = entity.components
			entity.components.main = component
		end,
		
		[self.ENTITY_COMPONENTS.SCENE] = function(entity, component)	
			if 
				entity.components.main ~= nil 
			then
				component.componentTable = entity.components
				entity.components.scene = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.SPRITEBOX] = function(entity, component)	
			if 
				entity.components.main ~= nil
			then
				component.componentTable = entity.components
				entity.components.spritebox = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.HITBOX] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.spritebox ~= nil
			then
				component.componentTable = entity.components
				entity.components.hitbox = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.TRANSPORT] = function(entity, component)
			if
				entity.components.main ~= nil and
				entity.components.hitnox ~= nil
			then
				component.componentTable = entity.components
				entity.components.transport = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.ACTION_STATE] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.hitbox ~= nil
			then
				component.componentTable = entity.components
				entity.components.actionState = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.INPUT] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.actionState ~= nil
			then
				component.componentTable = entity.components
				entity.components.input = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.IDLE] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.actionState ~= nil
			then
				component.componentTable = entity.components
				entity.components.idle = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.MOVEMENT] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.actionState ~= nil
			then
				component.componentTable = entity.components
				entity.components.movement = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.TARGETING] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.actionState ~= nil
			then
				component.componentTable = entity.components
				entity.components.targeting = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.ACTION] = function(entity, component)	
			if
				entity.components.main ~= nil and
				entity.components.actionState ~= nil
			then
				component.componentTable = entity.components
				entity.components.action = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.SPAWN] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.actionState ~= nil
			then
				component.componentTable = entity.components
				entity.components.spawn = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.DESPAWN] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.actionState ~= nil
			then
				component.componentTable = entity.components
				entity.components.despawn = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.SCRIPT] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.scene ~= nil
			then
				component.componentTable = entity.components
				entity.components.script = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.EVENT] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.hitbox ~= nil
			then
				component.componentTable = entity.components
				entity.components.event = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.ITEM] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.hitbox ~= nil
			then
				component.componentTable = entity.components
				entity.components.item = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.INVENTORY] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.scene ~= nil
			then
				component.componentTable = entity.components
				entity.components.inventory = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.COMBAT] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.actionState ~= nil
			then
				component.componentTable = entity.components
				entity.components.combat = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.HEALTH] = function(entity, component)	
			if 
				entity.components.main ~= nil and
				entity.components.hitbox ~= nil
			then
				component.componentTable = entity.components
				entity.components.health = component
			end
		end,
		
		[self.ENTITY_COMPONENTS.DIALOGUE] = function(entity, component)	
			if 
				entity.components.main ~= nil
			then
				component.componentTable = entity.components
				entity.components.dialogue = component
			end
		end,
		
		--...
	}
end

--------------
--Game entity:
--------------

GameEntity = {}
GameEntity.__index = GameEntity

setmetatable(GameEntity, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function GameEntity.new ()
	local self = setmetatable ({}, GameEntity)
		
		self.components = {
			main = nil,
			scene = nil,
			spritebox = nil,
			idle = nil,
			hitbox = nil,
			transport = nil,
			actionState = nil,
			input = nil,
			movement = nil,
			targeting = nil,
			action = nil,
			spawn = nil,
			despawn = nil,
			script = nil,
			event = nil,
			item = nil,
			inventory = nil,
			combat = nil,
			health = nil,
			dialogue = nil,
		}
		
	return self
end