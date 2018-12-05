local TARGET_MAPPING = {}

TARGET_MAPPING.ENTITY_ROLES = require 'ENTITY_ROLE'

TARGET_MAPPING.TYPE_COMBAT = 1

TARGET_MAPPING.TYPES = {
	[TARGET_MAPPING.TYPE_COMBAT] = {
		[TARGET_MAPPING.ENTITY_ROLES.PLAYER] = {
			TARGET_MAPPING.ENTITY_ROLES.HOSTILE_NPC
		},
		
		[TARGET_MAPPING.ENTITY_ROLES.HOSTILE_NPC] = {
			TARGET_MAPPING.ENTITY_ROLES.PLAYER
		}
	}
}

return TARGET_MAPPING