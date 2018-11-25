-------------------
--targeting mapper:
-------------------

EventActionMapper = {}
EventActionMapper.__index = EventActionMapper

setmetatable(EventActionMapper, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EventActionMapper.new ()
	local self = setmetatable ({}, EventActionMapper)
		
		self.interactionRequest = false
		self.startEvent = false
		self.endEvent = false
	return self
end

function EventActionMapper:setInteractionRequest()
	if not self.endEvent and not self.startEvent then
		self.interactionRequest = true
	end
end

function EventActionMapper:setStartEvent()
	self.interactionRequest = false
	self.startEvent = true
	self.endEvent = false
end

function EventActionMapper:setEndEvent()
	self.interactionRequest = false
	self.startEvent = false
	self.endEvent = true
end

function EventActionMapper:resetMapping()
	self.interactionRequest = false
	self.startEvent = false
	self.endEvent = false
end