--needs mouse support!!!

PlayerInputChannel = {}
PlayerInputChannel.__index = PlayerInputChannel

setmetatable(PlayerInputChannel, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function PlayerInputChannel.new (id)
	local self = setmetatable ({}, PlayerInputChannel)
		self.id = id
		
		self.inputType = {
			KEY_PRESS = 1,
			KEY_RELEASE = 2,
			KEY_HOLD = 3,
			--add mouse here
		}
		
		self.inputAction = {}	--this has to be an external require!!!!!!!!!
		self.defaultKeyMapping = {}
		self.currentKeyMapping = {}
	return self
end

function PlayerInputChannel:getKeyMapping(key, action)
	return self.currentKeyMapping[key][action]
end

function PlayerInputChannel:handleKeyPress(inputSystem, key)
	
end

function PlayerInputChannel:handleKeyRelease(inputSystem, key)
	
end

function PlayerInputChannel:handleKeyHold(inputSystem, key)
	
end

function PlayerInputChannel:setDefaultKeyMapping(key, pressAction, releaseAction, holdAction)
	self.defaultKeyMapping[key] = {}
	self.defaultKeyMapping[key][self.inputType.KEY_PRESS] = pressAction
	self.defaultKeyMapping[key][self.inputType.KEY_RELEASE] = releaseAction
	self.defaultKeyMapping[key][self.inputType.KEY_HOLD] = holdAction
end

function PlayerInputChannel:setCurrentKeyMapping(key, pressAction, releaseAction, holdAction)
	self.currentKeyMapping[key] = {}
	self.currentKeyMapping[key][self.inputType.KEY_PRESS] = pressAction
	self.currentKeyMapping[key][self.inputType.KEY_RELEASE] = releaseAction
	self.currentKeyMapping[key][self.inputType.KEY_HOLD] = holdAction
end

function PlayerInputChannel:setDefaultMappingValue(pressAction, releaseAction, holdAction)
	local actionList = {
		[self.inputType.KEY_PRESS] = pressAction,
		[self.inputType.KEY_RELEASE] = releaseAction,
		[self.inputType.KEY_HOLD] = holdAction
	}
	
	local defaultKeyMapping = self.defaultKeyMapping
	local defaultMt = {__index = function (defaultKeyMapping) return defaultKeyMapping['0'] end}
	defaultKeyMapping['0'] = actionList
	setmetatable(defaultKeyMapping, defaultMt)
	
	local currentKeyMapping = self.currentKeyMapping
	local currentMt = {__index = function (currentKeyMapping) return currentKeyMapping['0'] end}
	currentKeyMapping['0'] = actionList
	setmetatable(currentKeyMapping, currentMt)
end

function PlayerInputChannel:resetCurrentKeyMapping()
	for key, actionList in pairs(self.currentKeyMapping) do
		self.currentKeyMapping[key] = nil
	end
end

function PlayerInputChannel:revertToDefaultKeyMapping()
	for key, actionList in pairs(self.defaultKeyMapping) do
		self:setCurrentKeyMapping(key, actionList[self.inputType.KEY_PRESS],
			actionList[self.inputType.KEY_RELEASE], actionList[self.inputType.KEY_HOLD])
	end
end