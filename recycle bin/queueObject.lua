--[[
Queue implementation
http://www.lua.org/pil/11.4.html
]]--

queueObject = {}
queueObject.__index = queueObject

setmetatable(queueObject, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function queueObject.new ()
	local self = setmetatable ({}, queueObject)
		self.list = {}
		self.first = 0
		self.last = -1
	return self
end

function queueObject:pushLeft(value)
	local first = self.first - 1
	self.first = first
	self.list[first] = value
end

queueObject = {}
function queueObject.new ()
	return {first = 0, last = -1}
end

function queueObject.pushleft (list, value)
      local first = list.first - 1
      list.first = first
      list[first] = value
    end
    
    function queueObject.pushright (list, value)
      local last = list.last + 1
      list.last = last
      list[last] = value
    end
    
    function queueObject.popleft (list)
      local first = list.first
      if first > list.last then error("list is empty") end
      local value = list[first]
      list[first] = nil        -- to allow garbage collection
      list.first = first + 1
      return value
    end
    
    function queueObject.popright (list)
      local last = list.last
      if list.first > last then error("list is empty") end
      local value = list[last]
      list[last] = nil         -- to allow garbage collection
      list.last = last - 1
      return value
    end