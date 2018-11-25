local ENTITY_TYPE = require '/entity/ENTITY_TYPE'
local ENTITY_COMPONENT = require '/entity/ENTITY_COMPONENT'
local ENTITY_ROLE = require '/entity/ENTITY_ROLE'

return {
	entityType = ENTITY_TYPE.GENERIC_ENTITY,
		
	components = {
		[ENTITY_COMPONENT.MAIN] = {
			id = 0
		},
			
		[ENTITY_COMPONENT.SCENE] = {
			defaultRole = 8,
			role = 8
		},
			
		[ENTITY_COMPONENT.SPRITEBOX] = {
			x = 0,
			y = 0,
			w = 0,
			h = 0,
			direction = 5,
			defaultSpritesheetId = 2,
			spritesheetId = 2,
			quad = 1,
			aniRepoId = 1
		},
		
		[ENTITY_COMPONENT.HITBOX] = {
			xDeviation = 0,
			yDeviation = 0,
			w = 0,
			h = 0,
			collisionType = 1,
			mapCollisionType = 3
		}
	}
}