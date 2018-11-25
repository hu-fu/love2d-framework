PlayerEntityController = {}
PlayerEntityController.__index = PlayerEntityController

setmetatable(PlayerEntityController, {
	__call = function(cls, ...)
		return cls.new(...)
	end,
	})

function PlayerEntityController.new (id)
	local self = setmetatable ({}, PlayerEntityController)
		self.id = id
	return self
end

function PlayerEntityController:resolvePlayerInput(controllerSystem, input, inputComponent)
	
end

function PlayerEntityController:resolveEntityInput(controllerSystem, request, inputComponent)
	
end

function PlayerEntityController:resolveState(controllerSystem, inputComponent)
	
end

