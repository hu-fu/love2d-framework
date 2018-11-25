--[[
http://www.somethinghitme.com/2013/11/13/snippets-i-always-forget-movement/
http://weeklycoder.com/2015/07/22/the-incredibly-useful-sine-waves-part-1-trigonometry-game-dev-primer/
https://www.raywenderlich.com/35866/trigonometry-for-game-programming-part-1
https://gamedevelopment.tutsplus.com/tutorials/quick-tip-create-smooth-enemy-movement-with-sinusoidal-motion--gamedev-6009
https://as3gametuts.com/2013/07/10/top-down-rpg-shooter-4-shooting/
]]

local projectileControlMethods = {}
local CONTROL_METHOD = require '/projectile/CONTROL_METHOD'
local projectileTargetingMethods = require '/projectile/projectileTargetingMethods'

projectileControlMethods = {
	[CONTROL_METHOD.GENERIC] = function(projectileSystem, projectile, arguments, dt)
		local velocity = projectile.components.spatial.velocity*dt
		projectile.components.spatial.x = projectile.components.spatial.x + 
			math.cos(projectile.components.spatial.direction)*velocity
		projectile.components.spatial.y = projectile.components.spatial.y - 
			math.sin(projectile.components.spatial.direction)*velocity
	end,
	
	--...
}

return projectileControlMethods