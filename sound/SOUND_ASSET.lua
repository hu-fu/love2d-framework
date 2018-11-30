--playType -> 'streaming' for bgm and 'static' for effects

local SOUND = require '/sound/SOUND'
local SOUND_TYPE = require '/sound/SOUND_TYPE'
local filePath = '/sound/assets/'

return {
	[SOUND.DEFAULT] = {id=1, sourceType = 'static', filename = filePath .. '/effect/default.wav'},
	[SOUND.DEFAULT_2] = {id=2, sourceType = 'stream', filename = filePath .. '/bgm/global_network.mp3'},
}