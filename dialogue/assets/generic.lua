return {
{line = 1, thread = 1, action = 'start'},
{line = 2, thread = 1, action = 'none', actorId = 1, actorName = "Main Char", activeTime = 1.0, 
	text = "Hello! How are you?"},
{line = 3, thread = 1, action = 'none', actorId = 2, actorName = "Secondary Char", targetEntityId = 1, activeTime = 1.0, 
	text = "I'm fine. You?"},
{line = 4, id = "choice_1", thread = 1, action = 'choice', persistent = true, 
	choice = {{id = 1, text = "Fine too.", jumpToThread = 2}, {id = 2, text = "None of your business", jumpToThread = 3}}},

--Fine too:
{line = 5, thread = 2, action = 'none', actorId = 2, actorName = "Secondary Char", targetEntityId = 1, activeTime = 1.0, 
	text = "Glad to hear that."},
{line = 6, thread = 2, action = 'none', actorId = 2, actorName = "Secondary Char", targetEntityId = 1, activeTime = 1.0, 
	text = "This sure is some quality dialogue!"},
{line = 7, thread = 2, action = 'jump_thread', nextThread = 4},

--None of your business:
{line = 8, thread = 3, action = 'none', actorId = 2, actorName = "Secondary Char", targetEntityId = 1, activeTime = 1.0, 
	text = "How rude!"},
{line = 9, thread = 3, action = 'none', actorId = 2, actorName = "Secondary Char", targetEntityId = 1, activeTime = 1.0, 
	text = "Do not talk to me or my wife's son ever again!"},

{line = 11, thread = 4, action = 'none', actorId = 2, actorName = "Secondary Char", targetEntityId = 1, activeTime = 1.0, 
	text = "Good bye."},
{line = 12, thread = 4, action = 'end'},
}