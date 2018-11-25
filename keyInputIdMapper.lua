-----------------------------------
--Key/Input ID List (test version):
-----------------------------------
--[[
This is missing the 'current game state -> input id' layer
The 'keyMapping' must exist for both in-game and menu contexts
]]

keyInputIdMapper = {}

keyInputIdMapper.KEY_PRESS = 1
keyInputIdMapper.KEY_RELEASE = 2
keyInputIdMapper.KEY_HOLD = 3

keyInputIdMapper.defaultKeyMapping = {
	['up'] = {KEY_PRESS_MOVE_UP,KEY_RELEASE_MOVE_UP,KEY_HOLD_MOVE_UP},
	['left'] = {KEY_PRESS_MOVE_LEFT,KEY_RELEASE_MOVE_LEFT,KEY_HOLD_MOVE_LEFT},
	['down'] = {KEY_PRESS_MOVE_DOWN,KEY_RELEASE_MOVE_DOWN,KEY_HOLD_MOVE_DOWN},
	['right'] = {KEY_PRESS_MOVE_RIGHT,KEY_RELEASE_MOVE_RIGHT,KEY_HOLD_MOVE_RIGHT},
	['a'] = {KEY_PRESS_SET_TARGETING_STATE,KEY_RELEASE_SET_TARGETING_STATE,KEY_HOLD_SET_TARGETING_STATE},
	['s'] = {KEY_PRESS_SEARCH_TARGET,KEY_RELEASE_SEARCH_TARGET,KEY_HOLD_SEARCH_TARGET}
}

keyInputIdMapper.currentKeyMapping = {
	['up'] = {KEY_PRESS_MOVE_UP,KEY_RELEASE_MOVE_UP,KEY_HOLD_MOVE_UP},
	['left'] = {KEY_PRESS_MOVE_LEFT,KEY_RELEASE_MOVE_LEFT,KEY_HOLD_MOVE_LEFT},
	['down'] = {KEY_PRESS_MOVE_DOWN,KEY_RELEASE_MOVE_DOWN,KEY_HOLD_MOVE_DOWN},
	['right'] = {KEY_PRESS_MOVE_RIGHT,KEY_RELEASE_MOVE_RIGHT,KEY_HOLD_MOVE_RIGHT},
	['a'] = {KEY_PRESS_SET_TARGETING_STATE,KEY_RELEASE_SET_TARGETING_STATE,KEY_HOLD_SET_TARGETING_STATE},
	['s'] = {KEY_PRESS_SEARCH_TARGET,KEY_RELEASE_SEARCH_TARGET,KEY_HOLD_SEARCH_TARGET}
}

function keyInputIdMapper:getPressedKeyInputId(key)
	return self.currentKeyMapping[key][self.KEY_PRESS]
end

function keyInputIdMapper:getReleasedKeyInputId(key)
	return self.currentKeyMapping[key][self.KEY_RELEASE]
end

function keyInputIdMapper:getHeldKeyInputId(key)
	return self.currentKeyMapping[key][self.KEY_HOLD]
end

function keyInputIdMapper:getCurrentlyMappedKeys()
	local keys = {}
	for key, inputId in pairs(self.currentKeyMapping) do
		table.insert(keys, key)
	end
	return keys
end

function keyInputIdMapper:isKeyMapped(key)
	if self.currentKeyMapping[key] then
		return true
	else
		return false
	end
end

--[[
methods to load mapping file from memory
methods to change keys in the 'current mapping' list
(...)
]]

return keyInputIdMapper