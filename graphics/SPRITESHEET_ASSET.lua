local SPRITESHEET = require '/graphics/SPRITESHEET'

return {
	[SPRITESHEET.DEFAULT] = {id=1, spritesheetPath='/default/default.png', quadPath='/default/default'},
	[SPRITESHEET.GENERIC_ENTITY] = {id=2, spritesheetPath='/entity/player.png', quadPath='/entity/player'},
	[SPRITESHEET.TEST_FLOOR] = {id=3, spritesheetPath='/test/floor_a.png', quadPath='/test/floor_a'},
	[SPRITESHEET.TEST_ITEM] = {id=4, spritesheetPath='/item/test_item.png', quadPath='/item/test_item'},
	[SPRITESHEET.TEST_PROJECTILE] = {id=5, spritesheetPath='/projectile/default.png', quadPath='/projectile/default'},
	[SPRITESHEET.TEST_EFFECT] = {id=6, spritesheetPath='/effect/default.png', quadPath='/effect/default'},
	[SPRITESHEET.TEST_DIAGONAL] = {id=7, spritesheetPath='/test/diagonal_obstacle.png', quadPath='/test/diagonal_obstacle'},
	[SPRITESHEET.TEST_DIAGONAL_TWO] = {id=7, spritesheetPath='/test/diagonal_obstacle_two.png', quadPath='/test/diagonal_obstacle_two'},
	[SPRITESHEET.HOLE] = {id=7, spritesheetPath='/test/hole.png', quadPath='/test/hole'},
}