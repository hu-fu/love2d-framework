local VISUAL_EFFECT_CONTROLLER_TYPE = require '/effect/VISUAL_EFFECT_CONTROLLER_TYPE'
local VISUAL_EFFECT_TEMPLATE_TYPE = require '/effect/VISUAL_EFFECT_TEMPLATE_TYPE'
local VISUAL_EFFECT_TYPE = require '/effect/EFFECT_TYPE'

local VISUAL_EFFECT_TEMPLATE = {
	[VISUAL_EFFECT_TEMPLATE_TYPE.GENERIC] = {
		effectType = VISUAL_EFFECT_TYPE.GENERIC,
		w = 0,
		h = 0,
		velocity = 700,
		spritesheetId = 6,
		spritesheetQuad = 1,
		spriteOffsetX = 0,
		spriteOffsetY = 0,
		controller = VISUAL_EFFECT_CONTROLLER_TYPE.GENERIC,
	}
	
	--...
}

return VISUAL_EFFECT_TEMPLATE