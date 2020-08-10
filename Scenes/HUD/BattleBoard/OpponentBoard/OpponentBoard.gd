extends Control


onready var opponent_opening_manager = $MarginContainer/HBoxContainer/OpeningsContainer/Opponents
onready var player_opening_manager = $MarginContainer/HBoxContainer/OpeningsContainer/Players
onready var health_label = $MarginContainer/HBoxContainer/CenterContainer/Panel/MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/HealthStat/HealthLabel
onready var energy_label = $MarginContainer/HBoxContainer/CenterContainer/Panel/MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/EnergyStat/EnergyLabel
onready var deck_label = $MarginContainer/HBoxContainer/CenterContainer/Panel/MarginContainer/VBoxContainer/Panel/MarginContainer/VBoxContainer/DeckStat/DeckLabel

var opponent : AIOpponent setget set_opponent

func set_opponent(value:AIOpponent):
	opponent = value
	_update_opponent_stats()

func _ready():
	_update_opponent_stats()

func _update_opponent_stats():
	if not is_instance_valid(opponent):
		return
	if is_instance_valid(health_label):
		health_label.text = "%d / %d" % [opponent.get_health(), opponent.get_max_health()]
	if is_instance_valid(energy_label):
		energy_label.text = "%d / %d" % [opponent.get_energy(), opponent.get_max_energy()]
	if is_instance_valid(deck_label):
		deck_label.text = "%d" % [opponent.get_deck_size()]

func add_player_opening():
	player_opening_manager.add_opening()

func sub_player_opening():
	player_opening_manager.sub_opening()

func add_opponent_opening():
	opponent_opening_manager.add_opening()

func sub_opponent_opening():
	opponent_opening_manager.sub_opening()

func get_player_opening_positions():
	return player_opening_manager.get_opening_positions()

func get_opponent_opening_positions():
	return opponent_opening_manager.get_opening_positions()

func start_round():
	add_player_opening()
	add_opponent_opening()

func end_round():
	sub_player_opening()
	sub_opponent_opening()
