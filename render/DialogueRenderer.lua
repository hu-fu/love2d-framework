require 'misc'
require '/render/EntityRenderer'

local EffectRenderer = EntityRenderer.new()

function EffectRenderer:drawRealTimeText(canvas, text, x, y)
	love.graphics.printf(text, math.floor((x - 10) - canvas.x), math.floor((y - 35) - canvas.y),
		100, 'center')
end

function EffectRenderer:drawRealTimePortrait()
	
end

function EffectRenderer:drawDialogueGui()
	
end

return EffectRenderer