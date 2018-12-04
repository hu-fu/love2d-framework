return {
{line = 1, thread = 1, action = 'none', actorName = "Main Char", text = "Hello! How are you?"},
{line = 2, thread = 1, action = 'none', actorName = "Secondary Char", text = "I'm fine. You?"},
{line = 3, id = "choice_1", thread = 1, action = 'choice', persistent = true, choice = {{id = 1, text = "Fine too.", jumpToThread = 2}, {id = 2, text = "None of your business", jumpToThread = 3}}},

--Fine too:
{line = 4, thread = 2, action = 'none', actorName = "Secondary Char", text = "Glad to hear that."},
{line = 5, thread = 2, action = 'none', actorName = "Secondary Char", text = "This sure is some quality dialogue!"},
{line = 6 thread = 2, action = 'end_thread', nextThread = 4},

--None of your business:
{line = 7, thread = 3, action = 'none', actorName = "Secondary Char", text = "How rude!"},
{line = 8, thread = 3, action = 'none', actorName = "Secondary Char", text = "Do not talk to me or my wife's son ever again!"},

{line = 9, thread = 4, action = 'none', actorName = "Secondary Char", text = "Good bye."},
{line = 10, thread = 4, action = 'end_all'},
}