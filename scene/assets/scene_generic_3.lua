return {
	id = 3,
	
	tag = 'generic scene 3',
	
	areaId = 3,
	
	entityList = {
		['generic'] = {
			--generic
			{id = 1, role = 2, template = 1, x = 400, y = 4000, playerInputState = true,
				attackEquipped = {{5,5,5},{5,5,5},{6,6,6}}, areaSpawnId = nil},
				--note: if the areaSpawnId is ~= nil here the game will use the save file position
					--if there's no save file the x and y will be used instead
			
			--background b
			{id = 100, role = 7, template = 2, x = 0, y = 3579, spritesheetId = 25, 
				spriteW = 2112, spriteH = 4943},
			
			--moving platform
			{id = 10, role = 7, template = 7, x = 744, y = 3080, spritesheetId = 26, 
				spriteW = 672, spriteH = 548, scriptState = true, autoScriptId = 2},
			
			--level hitboxes
			{id = 1000, role = 4, template = 5, x = 40, y = 3468, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 655, hitboxH = 302,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1001, role = 4, template = 5, x = 1464, y = 3468, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 655, hitboxH = 302,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1002, role = 4, template = 5, x = 1705, y = 4190, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 191, hitboxH = 204,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1003, role = 4, template = 5, x = 264, y = 4190, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 191, hitboxH = 204,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1004, role = 4, template = 5, x = 0, y = 3469, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 41, hitboxH = 1499,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1005, role = 4, template = 5, x = 2121, y = 3469, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 41, hitboxH = 1499,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1006, role = 4, template = 5, x = 679, y = 793, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 66, hitboxH = 2787,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1007, role = 4, template = 5, x = 1413, y = 793, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 66, hitboxH = 2787,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1008, role = 4, template = 5, x = 629, y = 0, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 67, hitboxH = 795,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1009, role = 4, template = 5, x = 1463, y = 0, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 67, hitboxH = 795,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1010, role = 4, template = 5, x = 697, y = 0, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 765, hitboxH = 361,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			{id = 1011, role = 4, template = 5, x = 24, y = 4753, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 2162, hitboxH = 168,
				quad = 1, collisionType = 2, mapCollisionType = 2},
			
			--corridor hitbox (enable/disable on the area script)
			{id = 2000, role = 4, template = 5, x = 696, y = 1288, spritesheetId = 1, 
				spriteW = 0, spriteH = 0, hitboxW = 767, hitboxH = 1794,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			
			--[[
			{id = 2, role = 3, template = 6, x = 100, y = 100,
				scriptState = true, autoScriptId = 1, attackEquipped = {{1,1,1},{1,1,1},{1,1,1}}, 
				controllerId = 'entity_generic', directionLock = false},
			{id = 3, role = 3, template = 6, x = 200, y = 200,
				scriptState = true, autoScriptId = 1, attackEquipped = {{1,1,1},{1,1,1},{1,1,1}},
				controllerId = 'entity_generic', directionLock = false},
			]]
			
			--floor
			--[[
			{id = 100, role = 7, template = 2, x = 0, y = 0, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*1), y = 0, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*2), y = 0, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*3), y = 0, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*4), y = 0, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*5), y = 0, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			
			{id = 100, role = 7, template = 2, x = 0, y = 192*1, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*1), y = 192*1, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*2), y = 192*1, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*3), y = 192*1, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*4), y = 192*1, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*5), y = 192*1, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			
			{id = 100, role = 7, template = 2, x = 0, y = 192*2, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*1), y = 192*2, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*2), y = 192*2, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*3), y = 192*2, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*4), y = 192*2, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*5), y = 192*2, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			
			{id = 100, role = 7, template = 2, x = 0, y = 192*3, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*1), y = 192*3, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*2), y = 192*3, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*3), y = 192*3, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*4), y = 192*3, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			{id = 100, role = 7, template = 2, x = (288*5), y = 192*3, spritesheetId = 13, 
				spriteW = 288, spriteH = 192},
			]]
			
			--walls
			--[[
			{id = 102, role = 4, template = 5, x = 0, y = 0, spritesheetId = 15, 
				spriteW = 48, spriteH = 192, hitboxW = 48, hitboxH = 192,
				quad = 1, collisionType = 8, mapCollisionType = 8},
				
			{id = 102, role = 4, template = 5, x = 48, y = 0, spritesheetId = 14, 
				spriteW = 288, spriteH = 192, hitboxW = 288, hitboxH = 192,
				quad = 1, collisionType = 8, mapCollisionType = 8},
				
			{id = 102, role = 4, template = 5, x = 336, y = 0, spritesheetId = 15, 
				spriteW = 48, spriteH = 192, hitboxW = 48, hitboxH = 192,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			
			{id = 102, role = 4, template = 5, x = 384, y = 0, spritesheetId = 16, 
				spriteW = 144, spriteH = 192, hitboxW = 144, hitboxH = 192,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			
			{id = 102, role = 4, template = 5, x = 528, y = 0, spritesheetId = 15, 
				spriteW = 48, spriteH = 192, hitboxW = 48, hitboxH = 192,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			
			{id = 102, role = 4, template = 5, x = 576, y = 0, spritesheetId = 14, 
				spriteW = 288, spriteH = 192, hitboxW = 288, hitboxH = 192,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			
			{id = 102, role = 4, template = 5, x = 864, y = 0, spritesheetId = 18, 
				spriteW = 48, spriteH = 192, hitboxW = 48, hitboxH = 192,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			
			{id = 102, role = 4, template = 5, x = 912, y = 0, spritesheetId = 17, 
				spriteW = 144, spriteH = 192, hitboxW = 144, hitboxH = 192,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			
			{id = 102, role = 4, template = 5, x = 1056, y = 0, spritesheetId = 18, 
				spriteW = 48, spriteH = 192, hitboxW = 48, hitboxH = 192,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			]]
			
			--pilar
			--[[
			{id = 202, role = 4, template = 5, x = 300, y = 100, spritesheetId = 21, 
				spriteW = 130, spriteH = 382, hitboxW = 130, hitboxH = 382,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			]]
			
			--foreground grid
			--[[
			{id = 103, role = 12, template = 2, x = 0, y = -200, spritesheetId = 20, 
				spriteW = 971, spriteH = 991, quad = 1},
			]]
			
			--a big grid
			--[[
			{id = 202, role = 4, template = 5, x = 350, y = -800, spritesheetId = 19, 
				spriteW = 288, spriteH = 1227, hitboxW = 288, hitboxH = 1227,
				quad = 1, collisionType = 8, mapCollisionType = 8},
			]]
			
			--diagonal objects
			--[[
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
			]]--
			
			--foreground
			--[[
			{id = 103, role = 12, template = 2, x = 164, y = 10, spritesheetId = 9, 
				spriteW = 144, spriteH = 144, quad = 1},
			]]
			
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
			
			--event (this reloads the area)
			--{id = 201, role = 8, template = 3, x = 200, y = 200, spritesheetId = 1, 
			--	spriteW = 0, spriteH = 0},
				
			--item
			--{id = 301, role = 9, template = 4, x = 500, y = 250, spritesheetId = 4, 
			--	spriteW = 15, spriteH = 15},
			
		},
		--...
	},
	
	scriptIdList = {1, 2},
	
	--add as many stuff as needed
}