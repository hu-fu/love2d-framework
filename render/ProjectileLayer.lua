require '/render/RendererLayer'
require '/event/EventObjectPool'

local ProjectileLayer = RendererLayer.new(0, 0, 12, nil)

ProjectileLayer.projectileRenderer = require '/render/ProjectileRenderer'
ProjectileLayer.projectileList = nil

function ProjectileLayer:setProjectileList(projectileList)
	self.projectileList = projectileList
end

function ProjectileLayer:update(gameRenderer)
	self:reset()
end

function ProjectileLayer:draw(canvas)
	for i=1, #self.projectileList do
		if self.projectileList[i].active then
			self.projectileRenderer:drawEntity(canvas, self.projectileList[i].components)
		end
	end
end

function ProjectileLayer:reset()
	
end

return ProjectileLayer