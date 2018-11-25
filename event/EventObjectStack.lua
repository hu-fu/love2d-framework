EventObjectStack = {}
EventObjectStack.__index = EventObjectStack

setmetatable(EventObjectStack, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function EventObjectStack.new ()
	local self = setmetatable ({}, EventObjectStack)
		self.events = {}
	return self
end

function EventObjectStack:addEventObject(event)
	table.insert(self.events, event)
end

function EventObjectStack:removeEventObject()
	table.remove(self.events)
end

function EventObjectStack:getEventObject()
	if #self.events > 0 then
		local event = self.events[#self.events]
		self:removeEventObject()
		return event
	end
	return nil
end