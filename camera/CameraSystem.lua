----------------
--Camera System:
----------------

local CameraSystem = {}

---------------
--Dependencies:
---------------

require '/camera/CameraObjects'
require '/event/EventObjectPool'
local SYSTEM_ID = require '/system/SYSTEM_ID'
CameraSystem.EVENT_TYPES = require '/event/EVENT_TYPE'
CameraSystem.CAMERA_BEHAVIOUR = require '/camera/CAMERA_BEHAVIOUR'
CameraSystem.CAMERA_BEHAVIOUR_SCRIPT = require '/camera/CAMERA_BEHAVIOUR_SCRIPT'
CameraSystem.CAMERA_EFFECT = require '/camera/CAMERA_EFFECT'
CameraSystem.CAMERA_EFFECT_METHOD = require '/camera/CAMERA_EFFECT_METHOD'

-------------------
--System Variables:
-------------------

CameraSystem.id = SYSTEM_ID.CAMERA

CameraSystem.focusEntityList = {}		--list of entity type *? for easy focus selection

CameraSystem.eventDispatcher = nil
CameraSystem.eventListenerList = {}

CameraSystem.setLensRequestPool = EventObjectPool.new(CameraSystem.EVENT_TYPES.SET_LENS, 5)

CameraSystem.currentBehaviour = nil
CameraSystem.activeEffects = {}
CameraSystem.lens = CameraLens.new()

----------------
--Event Methods:
----------------

CameraSystem.eventMethods = {
	[1] = {
		[1] = function(request)
			--request.entityDb
			CameraSystem:setFocusEntityList(request.entityDb)
		end,
		
		[2] = function(request)
			--init camera :)
		end
	}
}

---------------
--Init Methods:
---------------

function CameraSystem:init()
	self:resetView()
	self:initBehaviour(self.CAMERA_BEHAVIOUR.GENERIC, nil)
	
	--debug (get from the database):
	self:setLensQuad(0, 0, 1024, 768)
end

---------------
--Exec Methods:
---------------

function CameraSystem:update(dt)
	self:runBehaviour(dt)
	
	--TODO:
	self:updateLensOnSpatialSystem()
end

function CameraSystem:initBehaviour(behaviourId, initRequest)
	--init request is optional; some behaviours need it, others don't
	local behaviour = self:getBehaviour(behaviourId)
	if behaviour then
		self:setCurrentBehaviour(behaviour)
		self.currentBehaviour.init(self.currentBehaviour, self, initRequest)
	end
end

function CameraSystem:getBehaviour(behaviourId)
	return self.CAMERA_BEHAVIOUR_SCRIPT[behaviourId]
end

function CameraSystem:setCurrentBehaviour(behaviour)
	self.currentBehaviour = behaviour
end

function CameraSystem:runBehaviour(dt)
	self.currentBehaviour.update(self.currentBehaviour, self, dt)
end

function CameraSystem:initEffect(effect)
	self:resetEffect(effect)
	table.insert(self.activeEffects, 1, effect)
end

function CameraSystem:getEffect(effectId)
	return self.CAMERA_EFFECT_METHOD[effectId]
end

function CameraSystem:resetEffect(effect)
	effect.currentTime = 0
end

function CameraSystem:runActiveEffects(dt)
	for i=1, #self.activeEffects do
		self:runEffect(self.activeEffects[i], dt)
	end
end

function CameraSystem:runEffect(effect, dt)
	effect.currentTime = effect.currentTime + dt
	
	if effect.currentTime >= effect.totalTime then
		self:removeEffect(effect)
	else
		effect.method(self, effect)
	end
end

function CameraSystem:removeEffect(effect)
	for i=1, #self.activeEffects do
		if self.activeEffects == effect then
			table.remove(self.activeEffects, i)
			break
		end
	end
end

function CameraSystem:resetView()
	self.lens.x, self.lens.y, self.lens.w, self.lens.h = 0, 0, 0, 0
	self.lens.vel = 0
	self.lens.zoom = 0
	self.lens.spatialX = 0
	self.lens.spatialY = 0
	self.lens.spatialUpdate = false
end

function CameraSystem:getLens()
	return self.lens
end

function CameraSystem:getLensQuad()
	return self.lens.x, self.lens.y, self.lens.g, self.lens.h 
end

function CameraSystem:setLensQuad(x, y, w, h)
	self.lens.x, self.lens.y, self.lens.w, self.lens.h = x, y, w, h
end

function CameraSystem:setPosition(x, y)
	self.lens.x = x
	self.lens.y = y
end

function CameraSystem:move(x, y)
	self.lens.x = self.lens.x + x
	self.lens.y = self.lens.y + y
end

function CameraSystem:moveToPoint(x, y)
	--if not @ point(x,y) then increment x,y towards point using vel var
	--return true if at point, false if not
	--should be an effect
end

function CameraSystem:setZoom(zoom)
	self.lens.zoom = zoom
end

function CameraSystem:zoom(zoom)
	self.lens.zoom = self.lens.zoom + zoom
end

function CameraSystem:setVelocity(vel)
	self.lens.vel = vel
end

function CameraSystem:incrementVelocity(increment)
	self.lens.vel = self.lens.vel + increment
end

function CameraSystem:setFocusEntityList(entityDb)
	self.focusEntityList = nil
	self.focusEntityList = entityDb.globalTables
end

function CameraSystem:getFocusEntityById(entityId, entityType)
	if entityType then
		local entityList = self.focusEntityList[entityType]
		for i=1, #entityList do
			if entityList[i].components.main.id == entityId then
				return entityList[i]
			end
		end
	else
		for entityType, entityList in pairs(self.focusEntityList) do
			for i=1, #entityList do
				if entityList[i].components.main.id == entityId then
					return entityList[i]
				end
			end
		end
	end
end

function CameraSystem:updateLensOnSpatialSystem()
	--TODO, very important. Do it.
	--send new request to spatial system
	--request updates camera(spatialX, spatialY and spatialUpdate)
		--if updated x, y is diferent from the previous x, y then spatialUpdate = true
		--do this in the spatial system, creat a new request type 'UPDATE_CAMERA_LENS'
	--renderers can use this info for updates
end

function CameraSystem:setLensOnSystems()
	local request = self.setLensRequestPool:getCurrentAvailableObject()
	request.lens = self.lens
	self.setLensOnSystemMethods[SYSTEM_ID.GAME_RENDERER](self, request)
	self.setLensOnSystemMethods[SYSTEM_ID.SPATIAL_UPDATE](self, request)
	self.setLensRequestPool:incrementCurrentIndex()
end

CameraSystem.setLensOnSystemMethods = {
	[SYSTEM_ID.GAME_RENDERER] = function(self, request)
		self.eventDispatcher:postEvent(1, 1, request)
	end,
	
	[SYSTEM_ID.SPATIAL_UPDATE] = function(self, request)
		self.eventDispatcher:postEvent(2, 1, request)
	end,
	
	--...
}

----------------
--Return module:
----------------

return CameraSystem