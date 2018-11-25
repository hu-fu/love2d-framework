local FORMAT_HEADER_LINE       = "| %-50s: %-40s: %-20s: %-12s: %-12s: %-12s|\n"
local FORMAT_OUTPUT_LINE       = "| %s: %-12s: %-12s: %-12s|\n"
local FORMAT_TIME              = "%04.3f"
local FORMAT_RELATIVE          = "%03.2f%%"
local FORMAT_COUNT             = "%7i"

Debugger = {}
Debugger.__index = Debugger

setmetatable(Debugger, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function Debugger.new ()
	local self = setmetatable ({}, Debugger)
	
	self.profiler = require '/debug/profi'
	
	self.draw = true
	
	self.debugStrings = {}
	
	return self
end

function Debugger:keyPress(key)
	if key == '1' then
		self.draw = not self.draw
	end
end

function Debugger:showProfilerData (x, y)
	if self.draw then
		local totalTime = self.profiler.stopTime - self.profiler.startTime
		local header = string.format( FORMAT_HEADER_LINE, "FILE", "FUNCTION", "LINE", "TIME", "RELATIVE", "CALLED" )
	
		love.graphics.print(header, x, y - 10)
	
		for i, funcReport in ipairs( self.profiler.reports ) do
			local timer         = string.format(FORMAT_TIME, funcReport.timer)
			local count         = string.format(FORMAT_COUNT, funcReport.count)
			local relTime 		= string.format(FORMAT_RELATIVE, (funcReport.timer / totalTime) * 100 )
			local outputLine    = string.format(FORMAT_OUTPUT_LINE, funcReport.title, timer, relTime, count )

			love.graphics.print(outputLine, x, y+(i*10))
		end
	end
end

function Debugger:printDebugStrings(x, y)
	for i=1, #self.debugStrings do
		love.graphics.print(self.debugStrings[i], x, y+(i*10))
	end
end

function Debugger:resetDebugStrings()
	for i=1, #self.debugStrings do
		self.debugStrings[i] = ''
	end
end