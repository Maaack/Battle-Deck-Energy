extends HBoxContainer


onready var opponent_actions_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/OpponentActions/OpponentActions.tscn")

var opponents_map : Dictionary = {}

func add_opponent_actions(opponent_data:CharacterData):
	if opponent_data in opponents_map:
		return opponents_map[opponent_data]
	var instance = opponent_actions_scene.instance()
	add_child(instance)
	instance.opponent_data = opponent_data
	opponents_map[opponent_data] = instance
	return instance

func get_opponent_actions_instance(opponent:CharacterData):
	if opponent in opponents_map:
		return opponents_map[opponent]

func add_openings():
	for child in get_children():
		if child.has_method("add_player_opening"):
			child.add_player_opening()
		if child.has_method("add_opponent_opening"):
			child.add_opponent_opening()

func remove_openings():
	for child in get_children():
		if child.has_method("sub_player_opening"):
			child.sub_player_opening()
		if child.has_method("sub_opponent_opening"):
			child.sub_opponent_opening()

func get_player_battle_openings():
	var battle_openings : Array = []
	for child in get_children():
		if child.has_method("get_player_battle_openings"):
			battle_openings += child.get_player_battle_openings()
	return battle_openings
