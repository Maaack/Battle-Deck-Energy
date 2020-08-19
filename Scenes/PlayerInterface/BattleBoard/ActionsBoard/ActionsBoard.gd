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
