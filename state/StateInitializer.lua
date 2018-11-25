StateInitializer = {}
StateInitializer.__index = StateInitializer

setmetatable(StateInitializer, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function StateInitializer.new (stateId)
	local self = setmetatable ({}, StateInitializer)
		self.STATE_IDS = require '/state/GAME_STATE'
		
		self.stateId = stateId
		
		self.initParameters = {
			[self.STATE_IDS.VOID] = {
				
			},
			
			[self.STATE_IDS.SCENE_LOAD] = {
				sceneInitializer = nil
			},
			
			[self.STATE_IDS.TEST_STATE_C] = {
				
			},
			
			--...
		}
	return self
end

function StateInitializer:setStateId(stateId)
	self.stateId = stateId
end

function StateInitializer:getInitParameters()
	return self.initParameters[self.stateId]
end