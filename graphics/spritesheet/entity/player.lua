--needs better organization, but it's fine

local quads = {
			--Default (1-8)
			{0,75,75,75,602,692}, {75,75,75,75,602,692}, {150,75,75,75,602,692}, 
			{225,75,75,75,602,692}, {300,75,75,75,602,692}, {375,75,75,75,602,692},  
			{450,75,75,75,602,692}, {525,75,75,75,602,692},
			
			--Walk (9-32)
			{75,75,75,75,602,692},{75,0,75,75,602,692},{75,150,75,75,602,692},
			{0,75,75,75,602,692},{0,0,75,75,602,692},{0,150,75,75,602,692},
			{525,75,75,75,602,692},{525,0,75,75,602,692},{525,150,75,75,602,692},
			{450,75,75,75,602,692},{450,0,75,75,602,692},{450,150,75,75,602,692},
			{375,75,75,75,602,692},{375,0,75,75,602,692},{375,150,75,75,602,692},
			{300,75,75,75,602,692},{300,0,75,75,602,692},{300,150,75,75,602,692},
			{225,75,75,75,602,692},{225,0,75,75,602,692},{225,150,75,75,602,692},
			{150,75,75,75,602,692},{150,0,75,75,602,692},{150,150,75,75,602,692},
			
			--Idle (33-48)
			{75,225,75,75,602,692}, {75,300,75,75,602,692},
			{0,225,75,75,602,692}, {0,300,75,75,602,692},
			{525,225,75,75,602,692}, {525,300,75,75,602,692},
			{450,225,75,75,602,692}, {450,300,75,75,602,692},
			{375,225,75,75,602,692}, {375,300,75,75,602,692},
			{300,225,75,75,602,692}, {300,300,75,75,602,692},
			{225,225,75,75,602,692}, {225,300,75,75,602,692},
			{150,225,75,75,602,692}, {150,300,75,75,602,692},
			
			--Attack (49-72)
			{0,375,75,75,602,692},{0,450,75,75,602,692},{0,525,75,75,602,692},
			{75,375,75,75,602,692},{75,450,75,75,602,692},{75,525,75,75,602,692},
			{150,375,75,75,602,692},{150,450,75,75,602,692},{150,525,75,75,602,692},
			{225,375,75,75,602,692},{225,450,75,75,602,692},{225,525,75,75,602,692},
			{300,375,75,75,602,692},{300,450,75,75,602,692},{300,525,75,75,602,692},
			{375,375,75,75,602,692},{375,450,75,75,602,692},{375,525,75,75,602,692},
			{450,375,75,75,602,692},{450,450,75,75,602,692},{450,525,75,75,602,692},
			{525,375,75,75,602,692},{525,450,75,75,602,692},{525,525,75,75,602,692},
			
			
			--hit (73-80)
			{0,600,75,75,602,692},{75,600,75,75,602,692},{150,600,75,75,602,692},
			{225,600,75,75,602,692},{300,600,75,75,602,692},{375,600,75,75,602,692},
			{450,600,75,75,602,692},{525,600,75,75,602,692},
		}

return quads