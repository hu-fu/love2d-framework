--In game db -> must have string keys and be easily converted to json
--ex: { "name":"John", "age":31, "city":"New York" }

local GAME_DB = {
	
	['generic_table'] = {
		{['id'] = 1, ['col_2'] = nil, ['col_3'] = nil},
		{['id'] = 2, ['col_2'] = nil, ['col_3'] = nil},
		--...
	},
	
	--...
}

return GAME_DB