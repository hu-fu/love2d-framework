--expand on this
--https://love2d.org/wiki/love.timer.sleep

local FpsConfig = {}

FpsConfig.capFrames = false
FpsConfig.maxFrames = 60

function FpsConfig:setMaxFrames(maxFrames)
	self.maxFrames = maxFrames
end

function FpsConfig:capFramerate(dt)
	if self.capFrames and dt < 1/self.maxFrames then
		love.timer.sleep(1/self.maxFrames - dt)
	end
end

function FpsConfig:setCapFrames(capFrames)
	self.capFrames = capFrames
end

return FpsConfig