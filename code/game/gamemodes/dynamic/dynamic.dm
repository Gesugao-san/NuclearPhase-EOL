/decl/game_mode/dynamic
	name = "Dynamic (Easy)"
	round_description = "A default game type with few threats."
	extended_round_description = "Most of the equipment is perfectly functioning. Harmful random events occur less frequently."
	uid = "dynamic_easy"
	required_players = 5
	probability = 1
	difficulty = GAME_DIFFICULTY_EASY

/decl/game_mode/dynamic/normal
	name = "Dynamic (Normal)"
	round_description = "A default game type with a medium amount of threats."
	extended_round_description = "Some of the equipment is malfunctioning. Harmful random events occur at a normal pace."
	uid = "dynamic_normal"
	difficulty = GAME_DIFFICULTY_NORMAL
	required_players = 15

/decl/game_mode/dynamic/hard
	name = "Dynamic (Hard)"
	round_description = "A default game type with a large amount of threats and damaged equipment."
	extended_round_description = "The shelter is in a poor state. Harmful random events occur more frequently."
	uid = "dynamic_hard"
	difficulty = GAME_DIFFICULTY_HARD
	required_players = 30

/decl/game_mode/dynamic/hell
	name = "Dynamic (Hell)"
	round_description = "A default game type with a huge amount of threats and lots of destroyed equipment."
	extended_round_description = "The shelter is almost nonfunctional. Harmful random events occur very frequently."
	uid = "dynamic_hell"
	difficulty = GAME_DIFFICULTY_HELL
	required_players = 40