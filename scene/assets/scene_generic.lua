return {
	id = 1,
	
	tag = 'generic scene',
	
	areaId = 1,
	
	entityList = {
		['generic'] = {
			--generic
			{id = 1, role = 3, template = 1, x = 100, y = 100,
				scriptState = true, autoScriptId = 1, attackEquipped = {{1,1,1},{1,1,1},{1,1,1}}, 
				controllerId = 'entity_generic'},
			{id = 2, role = 3, template = 1, x = 200, y = 150,
				scriptState = true, autoScriptId = 1, attackEquipped = {{1,1,1},{1,1,1},{1,1,1}},
				controllerId = 'entity_generic'},
			{id = 3, role = 2, template = 1, x = 200, y = 350, playerInputState = true,
				attackEquipped = {{5,5,5},{5,5,5},{6,6,6}}},
			
			--floor
			{id = 100, role = 7, template = 2, x = 0, y = 0, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*1), y = 0, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*2), y = 0, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*3), y = 0, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*4), y = 0, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*5), y = 0, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			
			{id = 100, role = 7, template = 2, x = 0, y = 320*1, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*1), y = 320*1, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*2), y = 320*1, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*3), y = 320*1, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*4), y = 320*1, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*5), y = 320*1, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			
			{id = 100, role = 7, template = 2, x = 0, y = 320*2, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*1), y = 320*2, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*2), y = 320*2, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*3), y = 320*2, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*4), y = 320*2, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*5), y = 320*2, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			
			{id = 100, role = 7, template = 2, x = 0, y = 320*3, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*1), y = 320*3, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*2), y = 320*3, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*3), y = 320*3, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*4), y = 320*3, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			{id = 100, role = 7, template = 2, x = (320*5), y = 320*3, spritesheetId = 3, 
				spriteW = 320, spriteH = 320},
			
			--diagonal objects
			{id = 101, role = 4, template = 5, x = 200, y = 200, spritesheetId = 7, 
				spriteW = 144, spriteH = 144, hitboxW = 144, hitboxH = 144,
				quad = 1, collisionType = 4, mapCollisionType = 4},
			{id = 101, role = 4, template = 5, x = 200, y = 344, spritesheetId = 7, 
				spriteW = 144, spriteH = 144, hitboxW = 144, hitboxH = 144,
				quad = 3, collisionType = 7, mapCollisionType = 7},
			{id = 101, role = 4, template = 5, x = 344, y = 56, spritesheetId = 7, 
				spriteW = 144, spriteH = 144, hitboxW = 144, hitboxH = 144,
				quad = 1, collisionType = 4, mapCollisionType = 4},
			{id = 101, role = 4, template = 5, x = 344, y = 200, spritesheetId = 7, 
				spriteW = 144, spriteH = 144, hitboxW = 144, hitboxH = 144,
				quad = 3, collisionType = 7, mapCollisionType = 7},
			
			--hole
			{id = 102, role = 4, template = 5, x = 10, y = 10, spritesheetId = 9, 
				spriteW = 144, spriteH = 144, hitboxW = 144, hitboxH = 144,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			
			--foreground
			{id = 103, role = 12, template = 2, x = 164, y = 10, spritesheetId = 9, 
				spriteW = 144, spriteH = 144, quad = 1},
			
			--[[
			{id = 101, role = 4, template = 5, x = 200, y = 200, spritesheetId = 7, 
				spriteW = 144, spriteH = 144, hitboxW = 144, hitboxH = 144,
				quad = 1, collisionType = 4, mapCollisionType = 4},
			
			{id = 101, role = 4, template = 5, x = 400, y = 200, spritesheetId = 7, 
				spriteW = 144, spriteH = 144, hitboxW = 144, hitboxH = 144,
				quad = 2, collisionType = 5, mapCollisionType = 5},
			
			{id = 101, role = 4, template = 5, x = 200, y = 344, spritesheetId = 7, 
				spriteW = 144, spriteH = 144, hitboxW = 144, hitboxH = 144,
				quad = 4, collisionType = 6, mapCollisionType = 6},
				
			{id = 101, role = 4, template = 5, x = 400, y = 400, spritesheetId = 7, 
				spriteW = 144, spriteH = 144, hitboxW = 144, hitboxH = 144,
				quad = 3, collisionType = 7, mapCollisionType = 7},
			
			]]
			
			--event
			--{id = 201, role = 8, template = 3, x = 200, y = 200, spritesheetId = 1, 
			--	spriteW = 0, spriteH = 0},
				
			--item
			{id = 301, role = 9, template = 4, x = 500, y = 250, spritesheetId = 4, 
				spriteW = 15, spriteH = 15},
			
		},
		--...
	},
	
	scriptIdList = {1},
	
	--add as many stuff as needed
}