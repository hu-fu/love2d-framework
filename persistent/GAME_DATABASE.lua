--In game db -> must have string keys and be easily converted to json
--ex: { "name":"John", "age":31, "city":"New York" }

local GAME_DB = {
	
	['generic_table'] = {
		--table for testing stuff
		{id = 1, x = 350, y = 350, sceneId=1}
		--...
	},
	
	['settings'] = {
		['screen_w'] = 800, 
		['screen_h'] = 600, 
		['fullscreen'] = false
	}
	
	--...
}

return GAME_DB