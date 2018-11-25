---------------------
--Projectile Control:
---------------------
--[[
maybe it should be expanded for something other than projectiles. Or maybe not.

http://www.somethinghitme.com/2013/11/13/snippets-i-always-forget-movement/
http://weeklycoder.com/2015/07/22/the-incredibly-useful-sine-waves-part-1-trigonometry-game-dev-primer/
https://www.raywenderlich.com/35866/trigonometry-for-game-programming-part-1
https://gamedevelopment.tutsplus.com/tutorials/quick-tip-create-smooth-enemy-movement-with-sinusoidal-motion--gamedev-6009
https://as3gametuts.com/2013/07/10/top-down-rpg-shooter-4-shooting/
]]

local projectileControlMethods = {}

projectileControlMethods.trigConversion = require 'trigLookupTables'
projectileControlMethods.ENTITY_TYPES = require '/entity/ENTITY_TYPE'

function projectileControlMethods:projectileTest(dir, vel, x, y)
	return math.cos(dir)*vel, math.sin(dir)*vel
end

--create a guidance system somewhere (auto directs to target)

return projectileControlMethods