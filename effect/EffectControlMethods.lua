--[[
http://www.somethinghitme.com/2013/11/13/snippets-i-always-forget-movement/
http://weeklycoder.com/2015/07/22/the-incredibly-useful-sine-waves-part-1-trigonometry-game-dev-primer/
https://www.raywenderlich.com/35866/trigonometry-for-game-programming-part-1
https://gamedevelopment.tutsplus.com/tutorials/quick-tip-create-smooth-enemy-movement-with-sinusoidal-motion--gamedev-6009
https://as3gametuts.com/2013/07/10/top-down-rpg-shooter-4-shooting/
]]

local effectControlMethods = {}
local CONTROL_METHOD = require '/effect/CONTROL_METHOD'

effectControlMethods = {
	[CONTROL_METHOD.GENERIC] = function(visualEffectSystem, effect, arguments, dt)
		local velocity = effect.components.spatial.velocity*dt
		effect.components.spatial.x = effect.components.spatial.x + 
			math.cos(effect.components.spatial.direction)*velocity
		effect.components.spatial.y = effect.components.spatial.y - 
			math.sin(effect.components.spatial.direction)*velocity
	end,
	
	--...
}

return effectControlMethods