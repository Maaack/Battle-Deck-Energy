extends Node


signal teams_updated
signal team_list_updated(team_list)

var teams : Dictionary = {}
var characters : Dictionary = {}

func get_team(character : CharacterData):
	if not character in characters:
		print("Warning: character %s not in characters map." % character)
		return
	return characters[character]

func get_team_list(team : String) -> Array:
	if not team in teams:
		teams[team] = []
		emit_signal("teams_updated")
	return teams[team]

func add_character(character : CharacterData, team : String):
	if character in characters:
		return
	get_team_list(team).append(character)
	characters[character] = team
	emit_signal("team_list_updated", teams[team])

func remove_character(character : CharacterData):
	if not character in characters:
		return
	var team = get_team(character)
	teams[team].erase(character)
	characters.erase(character)
	emit_signal("team_list_updated", teams[team])

func get_allies(character : CharacterData):
	var team = get_team(character)
	var team_list = get_team_list(team).duplicate()
	team_list.erase(character)
	return team_list

func get_enemies(character : CharacterData):
	var character_team = get_team(character)
	var all_enemies : Array = []
	for team in teams:
		if team == character_team:
			continue
		all_enemies += get_team_list(team)
	return all_enemies
