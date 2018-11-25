--state machine for projectile states (good idea, shit implementation - expand if needed)

local projectileState = {}

projectileState.states = {
	SPAWN = 1,
	ACTIVE = 2,
	DESTROY = 3
}

function projectileState:getNextState(state)
	if state < 3 then
		return state + 1
	else
		return nil
	end
end

function projectileState:getLastState()
	return self.DESTROY
end

function projectileState:getFirstState()
	return self.SPAWN
end

return projectileState