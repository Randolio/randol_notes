# Showcase:
- https://streamable.com/hksbds

# Requirements:
- https://github.com/overextended/ox_inventory
- https://github.com/overextended/ox_lib

# Items to add to ox inventory

	["notepad"] = {
		label = "Notepad",
		weight = 0,
		stack = false,
		close = true,
		description = "Sometimes handy to remember something :)",
	},
	
	["tornnote"] = {
		label = "Torn Note",
		weight = 0,
		stack = false,
		close = false,
	},

# 
Run the sql. Put the notepad in a shop or in a loot pool somewhere. 
It will automatically assign an id to the notepad and insert a row into the database for it when it's created.
