--moves an elevator (very cool)

return {
	['id'] = 2,
	
	['variables'] = {
		currentTime = nil,
		totalTime = nil,
		variable = nil,
		spatialEntityHashtable = SpatialEntityHashtableSimple.new(),
		vel = 5,
		w = 672,
		h = 548,
		hitboxW = 672,
		hitboxH = 490,
		
		state = {
			STOP = 1,
			MOVING_UP = 2,
			MOVING_DOWN = 3,
		},
		
		activeState = 1,
		
		maxY = 3080,
		minY = 798,
		
		corridorHitboxW = 767,
		corridorHitboxH = 1794,
	},
	
	['init'] = function(scriptSystem, self)
		self.variables.activeState = 1
	end,
	
	['threads'] = {
		{
			priority = 1,
			method = function(scriptSystem, self, dt)
				
				if self.variables.activeState == 1 then
					--platform stopped
				
					--check if start moving condition is true:
					if love.keyboard.isDown('space') then
						
						--get entity:
						local entitySpritebox = scriptSystem.entitySystem:getEntityById(10, 3, 1).components.spritebox
						
						if entitySpritebox.y > self.variables.minY then
							--go up
							self.variables.activeState = 2
						else
							--go down
							self.variables.activeState = 3
						end
						
						--remove corridor hitbox
						local corridorHitbox = scriptSystem.entitySystem:getEntityById(2000, 3, 1).components.hitbox
						corridorHitbox.w = 0
						corridorHitbox.h = 0
					end
				else
					--platform moving
					
					--get platform entity and area grid, reset hashtable:
					self.variables.spatialEntityHashtable:reset()
					local entitySpritebox = scriptSystem.entitySystem:getEntityById(10, 3, 1).components.spritebox
					local grid = scriptSystem.spatialPartitioningSystem.area.grid
					
					--get all entities inside area:
					scriptSystem.spatialPartitioningSystem:getEntitiesInAreaByRoles(grid, self.variables.spatialEntityHashtable, {2,3,9}, entitySpritebox.x, entitySpritebox.y, self.variables.w, self.variables.h)
					
					if self.variables.activeState == 2 then
						--up
						
						--move platform and update it:
						entitySpritebox.y = entitySpritebox.y - self.variables.vel
				
						scriptSystem.spatialPartitioningSystem.defaultUpdatePositionMethods[scriptSystem.spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY](entitySpritebox.spatialEntity, grid)
						
						--loop entities and update them:
						for i=1, #self.variables.spatialEntityHashtable.indexTable do
							local parentEntity = self.variables.spatialEntityHashtable.entityTable[self.variables.spatialEntityHashtable.indexTable[i]].parentEntity
							
							--check if entity is inbounds:
							if scriptSystem.collisionSystem.collisionMethods:rectToRectDetection(entitySpritebox.x, entitySpritebox.y, entitySpritebox.x + (self.variables.hitboxW), entitySpritebox.y + (self.variables.hitboxH), parentEntity.x, parentEntity.y, parentEntity.x + parentEntity.w, parentEntity.y + parentEntity.h) then
							
								--move entity
								parentEntity.y = parentEntity.y - self.variables.vel
								parentEntity.componentTable.spritebox.y = parentEntity.componentTable.spritebox.y - self.variables.vel
								
								--keep entity in the platform (this sucks but whatever lol):
									--only need to check vertical values here
									--pure jank lol -> this is just an example
								if parentEntity.y < entitySpritebox.y then
									local mtv = entitySpritebox.y - parentEntity.y
									parentEntity.y = parentEntity.y + mtv
									parentEntity.componentTable.spritebox.y = parentEntity.componentTable.spritebox.y + mtv
								end
								
								if (parentEntity.y + parentEntity.h) > (entitySpritebox.y + self.variables.hitboxH) then
									local mtv = (entitySpritebox.y + self.variables.hitboxH) - (parentEntity.y + parentEntity.h)
									parentEntity.y = parentEntity.y + mtv
									parentEntity.componentTable.spritebox.y = parentEntity.componentTable.spritebox.y + mtv
								end
								
								if parentEntity.x < entitySpritebox.x then
									local mtv = entitySpritebox.x - parentEntity.x
									parentEntity.x = parentEntity.x + mtv
									parentEntity.componentTable.spritebox.x = parentEntity.componentTable.spritebox.x + mtv
								end
								
								if (parentEntity.x + parentEntity.w) > (entitySpritebox.x + self.variables.hitboxW) then
									local mtv = (entitySpritebox.x + self.variables.hitboxW) - (parentEntity.x + parentEntity.w)
									parentEntity.x = parentEntity.x + mtv
									parentEntity.componentTable.spritebox.x = parentEntity.componentTable.spritebox.x + mtv
								end
								
								--update entity
								scriptSystem.spatialPartitioningSystem.defaultUpdatePositionMethods[scriptSystem.spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY](parentEntity.spatialEntity, grid)
							end
						end
						
						--stop platform if reaches limit, reset state to 1(stop)
						if entitySpritebox.y <= self.variables.minY then
							entitySpritebox.y = self.variables.minY
							self.variables.activeState = 1
							
							--remove corridor hitbox
							local corridorHitbox = scriptSystem.entitySystem:getEntityById(2000, 3, 1).components.hitbox
							corridorHitbox.w = self.variables.corridorHitboxW
							corridorHitbox.h = self.variables.corridorHitboxH
						end
					else
						--down
						
						--move platform and update it:
						entitySpritebox.y = entitySpritebox.y + self.variables.vel
				
						scriptSystem.spatialPartitioningSystem.defaultUpdatePositionMethods[scriptSystem.spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY](entitySpritebox.spatialEntity, grid)
						
						--loop entities and update them:
						for i=1, #self.variables.spatialEntityHashtable.indexTable do
							local parentEntity = self.variables.spatialEntityHashtable.entityTable[self.variables.spatialEntityHashtable.indexTable[i]].parentEntity
							
							--check if entity is inbounds:
							if scriptSystem.collisionSystem.collisionMethods:rectToRectDetection(entitySpritebox.x, entitySpritebox.y, entitySpritebox.x + (self.variables.hitboxW), entitySpritebox.y + (self.variables.hitboxH), parentEntity.x, parentEntity.y, parentEntity.x + parentEntity.w, parentEntity.y + parentEntity.h) then
							
								--move entity
								parentEntity.y = parentEntity.y + self.variables.vel
								parentEntity.componentTable.spritebox.y = parentEntity.componentTable.spritebox.y + self.variables.vel
								
								--keep entity in the platform
								if parentEntity.y < entitySpritebox.y then
									local mtv = entitySpritebox.y - parentEntity.y
									parentEntity.y = parentEntity.y + mtv
									parentEntity.componentTable.spritebox.y = parentEntity.componentTable.spritebox.y + mtv
								end
								
								if (parentEntity.y + parentEntity.h) > (entitySpritebox.y + self.variables.hitboxH) then
									local mtv = (entitySpritebox.y + self.variables.hitboxH) - (parentEntity.y + parentEntity.h)
									parentEntity.y = parentEntity.y + mtv
									parentEntity.componentTable.spritebox.y = parentEntity.componentTable.spritebox.y + mtv
								end
								
								if parentEntity.x < entitySpritebox.x then
									local mtv = entitySpritebox.x - parentEntity.x
									parentEntity.x = parentEntity.x + mtv
									parentEntity.componentTable.spritebox.x = parentEntity.componentTable.spritebox.x + mtv
								end
								
								if (parentEntity.x + parentEntity.w) > (entitySpritebox.x + self.variables.hitboxW) then
									local mtv = (entitySpritebox.x + self.variables.hitboxW) - (parentEntity.x + parentEntity.w)
									parentEntity.x = parentEntity.x + mtv
									parentEntity.componentTable.spritebox.x = parentEntity.componentTable.spritebox.x + mtv
								end
								
								--update entity
								scriptSystem.spatialPartitioningSystem.defaultUpdatePositionMethods[scriptSystem.spatialPartitioningSystem.ENTITY_TYPES.GENERIC_ENTITY](parentEntity.spatialEntity, grid)
							end
						end
						
						--stop platform if reaches limit, reset state to 1(stop)
						if entitySpritebox.y >= self.variables.maxY then
							entitySpritebox.y = self.variables.maxY
							self.variables.activeState = 1
							
							--remove corridor hitbox
							local corridorHitbox = scriptSystem.entitySystem:getEntityById(2000, 3, 1).components.hitbox
							corridorHitbox.w = self.variables.corridorHitboxW
							corridorHitbox.h = self.variables.corridorHitboxH
						end
					end
					
				end
				
				--end of main if is here!!!!!!!
			end
		},
		
		--...
	}
}