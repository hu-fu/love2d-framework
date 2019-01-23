-------------------
--targeting mapper:
-------------------
--small state machine for targeting input mapping (prototype)

TargetingActionMapper = {}
TargetingActionMapper.__index = TargetingActionMapper

setmetatable(TargetingActionMapper, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function TargetingActionMapper.new ()
	local self = setmetatable ({}, TargetingActionMapper)
		
		self.setState = false
		self.getTarget = false
	return self
end

function TargetingActionMapper:setSetState()
	self.setState = true
end

function TargetingActionMapper:setGetTarget(state)
	self.getTarget = state
end

function TargetingActionMapper:resetMapping()
	self.setState = false
	self.getTarget = false
end