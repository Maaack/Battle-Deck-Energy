extends Control


onready var opponents_board_container = $Opponents/HBoxContainer
onready var opponent_board_scene = preload("res://Scenes/HUD/BattleBoard/OpponentBoard/OpponentBoard.tscn")

func add_opponent_board(opponent:AIOpponent):
	var opponent_board_instance = opponent_board_scene.instance()
	opponents_board_container.add_child(opponent_board_instance)
	opponent_board_instance.opponent = opponent

func start_round():
	for child in opponents_board_container.get_children():
		if child.has_method("start_round"):
			child.start_round()

func end_round():
	for child in opponents_board_container.get_children():
		if child.has_method("end_round"):
			child.end_round()
