-------------------------
--Event Data Object Pool:
-------------------------
--new version

EventObjectPool = {}
EventObjectPool.__index = EventObjectPool

setmetatable(EventObjectPool, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EventObjectPool.new (defaultObjectType, maxObjects)
	local self = setmetatable ({}, EventObjectPool)
		
		self.objectPool = {}
		self.currentIndex = 1
		
		self.EVENT_TYPES = require '/event/EVENT_TYPE'
		self.defaultObjectType = defaultObjectType
		self.maxObjects = maxObjects
		
		self.createEventObjectMethods = {}
		self:setCreateEventObjectMethods()
		
		self:buildObjectPool()
	return self
end

function EventObjectPool:getCurrentObject()
	return self.objectPool[self.currentIndex]
end

function EventObjectPool:createNewEventObject(eventType)
	return self.createEventObjectMethods[eventType]()
end

function EventObjectPool:setCreateEventObjectMethods()
	self.createEventObjectMethods = {
		[self.EVENT_TYPES.GENERIC] = function()
			return {
				data = nil
			}
		end,
		
		[self.EVENT_TYPES.SPATIAL_REQUEST] = function()
			require '/spatial/SpatialPartitioningQuery'		--wtf
			
			return {
				spatialQuery = nil,
				area = nil,
				entityDb = nil
			}
		end,
		
		[self.EVENT_TYPES.ANIMATION] = function()
			return {
				animationSetId = nil,
				animationId = nil,
				spritebox = nil,
				spriteList = nil,
				animationObject = nil,
				callback = nil
			}
		end,
		
		[self.EVENT_TYPES.ACTION] = function()
			return {
				actionSetId = nil,
				actionId = nil,
				component = nil,
				componentList = nil,
				actionObject = nil,
				callback = nil
			}
		end,
		
		[self.EVENT_TYPES.INTERACTION] = function()
			return {
				interactionType = 0,
				interactionId = 0,
				x = 0,
				y = 0,
				w = 0,
				h = 0,
				originEntity = 0,
				targetRole = nil
			}
		end,
		
		[self.EVENT_TYPES.VISUAL_EFFECT] = function()
			return {
				requestType = nil,
				--creationType = nil,	--standard emitter, new emitter
				emitterType = nil,
				effectType = nil,
				
				focusEntity = nil,
				x = nil,
				y = nil,
				direction = nil,
				
				emitterObject = nil,
				effectObject = nil
			}
		end,
		
		[self.EVENT_TYPES.START_STATE] = function()
			return {
				stateId = 0,
				stateInit = nil
			}
		end,
		
		[self.EVENT_TYPES.CHANGE_SCENE] = function()
			return {
				sceneId = 0,
				sceneInit = nil
			}
		end,
		
		[self.EVENT_TYPES.DATABASE_REQUEST] = function()
			return {
				databaseQuery = nil
			}
		end,
		
		[self.EVENT_TYPES.INIT_SCENE] = function()
			return {
				sceneObj = nil
			}
		end,
		
		[self.EVENT_TYPES.INIT_ENTITY] = function()
			return {
				entityDb = nil,
				projectileList = nil,
				effectList = nil,
			}
		end,
		
		[self.EVENT_TYPES.INIT_CAMERA] = function()
			return {
				behaviourId = nil
			}
		end,
		
		[self.EVENT_TYPES.SET_LENS] = function()
			return {
				lens = nil
			}
		end,
		
		[self.EVENT_TYPES.INIT_AREA] = function()
			return {
				area = nil
			}
		end,
		
		[self.EVENT_TYPES.SET_GRAPHIC] = function()
			return {
				spritesheetTable = nil,
				quadTable = nil,
				imageTable = nil,
				characterPortraits = nil,
				
			}
		end,
		
		[self.EVENT_TYPES.PLAYER_INPUT] = function()
			return {
				inputId = nil
			}
		end,
		
		[self.EVENT_TYPES.MOVEMENT] = function()
			return {
				requestType = nil,
				movementComponent = nil
			}
		end,
		
		[self.EVENT_TYPES.IDLE] = function()
			return {
				requestType = nil,
				idleComponent = nil
			}
		end,
		
		[self.EVENT_TYPES.SPATIAL_UPDATER] = function()
			return {
				updaterObj = nil
			}
		end,
		
		[self.EVENT_TYPES.TARGETING] = function()
			return {
				requestType = nil,
				targetingComponent = nil,
				targetHitbox = nil
			}
		end,
		
		[self.EVENT_TYPES.ENTITY_SPAWN] = function()
			return {
				requestType = nil,
				spawnComponent = nil
			}
		end,
		
		[self.EVENT_TYPES.ENTITY_DESPAWN] = function()
			return {
				requestType = nil,
				despawnComponent = nil,
				actionSetId = nil,
				actionId = nil
			}
		end,
		
		[self.EVENT_TYPES.ENTITY_SCRIPT] = function()
			return {
				
			}
		end,
		
		[self.EVENT_TYPES.ENTITY_INPUT] = function()
			return {
				--input sent to entity controllers via external systems
				actionId = nil,
				stateComponent = nil,
				inputComponent = nil,
				variables = nil
				--more variables, maybe a request system like the spatial requests
			}
		end,
		
		[self.EVENT_TYPES.ENTITY_EVENT] = function()
			return {
				requestType = nil,
				eventComponent = nil
			}
		end,
		
		[self.EVENT_TYPES.SCENE_CHANGE] = function()
			return {
				requestType = nil,
				sceneId = nil,
				quickTransition = nil,
			}
		end,
		
		[self.EVENT_TYPES.SET_FLAG] = function()
			return {
				flagDb = nil
			}
		end,
		
		[self.EVENT_TYPES.SET_INVENTORY] = function()
			return {
				inventoryTable = nil
			}
		end,
		
		[self.EVENT_TYPES.ITEM] = function()
			return {
				itemType = nil,
				itemId = nil,
				itemRequest = nil,
				inventoryComponent = nil,
				x = 0,
				y = 0,
				quantity = 0
			}
		end,
		
		[self.EVENT_TYPES.SET_GAME_STATE] = function()
			return {
				stateInitializer = nil
			}
		end,
		
		[self.EVENT_TYPES.ENTITY_COMBAT] = function()
			return {
				requestType = nil,
				combatComponent = nil
			}
		end,
		
		[self.EVENT_TYPES.ENTITY_HEALTH] = function()
			return {
				requestType = nil,
				healthComponent = nil,
				value = nil,
				effectState = nil,
				effectId = nil,
			}
		end,
		
		[self.EVENT_TYPES.PROJECTILE] = function()
			return {
				requestType = nil,
				
				spawnType = nil,
				senderType = nil,
				senderEntity = nil,
				senderRole = nil,
				x = nil,
				y = nil,
				direction = nil,
				targetEntity = nil,
				
				projectileObject = nil,
				entityObject = nil,
				destructionType = nil,
			}
		end,
		
		[self.EVENT_TYPES.SOUND] = function()
			return {
				requestType = nil,
				
				config = nil,
				listenerEntity = nil,
				
				audioId = nil,
				soundType = nil,
				playerId = nil,
				playerName = nil,
				volumePercentage = nil,
				loop = nil,
				effectId = nil,
				parentEntity = nil,
				distance = nil,
				x = nil,
				y = nil,
			}
		end,
		
		[self.EVENT_TYPES.DIALOGUE] = function()
			return {
				requestType = nil,
				activePlayers = nil,
				
				player = nil,
				dialogueId = nil,
				playerType = nil,
				parentEntity = nil,
				lineNumber = nil,
				choiceId = nil,
				
				responseCallback = nil,
			}
		end,
		
	}
end

function EventObjectPool:buildObjectPool()
	self.currentIndex = 1
	self.objectPool = {}
	
	for i=1, self.maxObjects do
		table.insert(self.objectPool, self:createNewEventObject(self.defaultObjectType))
	end
end

function EventObjectPool:getCurrentAvailableObject()
	return self.objectPool[self.currentIndex]
end

function EventObjectPool:resetCurrentIndex()
	self.currentIndex = 1
end

function EventObjectPool:incrementCurrentIndex()
	--modify this so it resets the index instead of creating a new object
	if self.currentIndex == #self.objectPool then
		table.insert(self.objectPool, self:createNewEventObject(self.defaultObjectType))
	end
	self.currentIndex = self.currentIndex + 1
end

function EventObjectPool:resetObjectPoolSize()
	
	if #self.objectPool < self.maxObjects then
		for i=#self.objectPool, self.maxObjects do
			table.insert(self.objectPool, self:createNewEventObject(self.defaultObjectType))
		end
	elseif #self.objectPool > self.maxObjects then
		for i=#self.objectPool, self.maxObjects, -1 do
			table.remove(self.objectPool)
		end
	end
end

function EventObjectPool:setMaxObjects(maxObjects)
	self.maxObjects = maxObjects
	self:resetObjectPoolSize()
end