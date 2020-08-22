extends Control


class_name OpponentActionsInterface

onready var opponent_opening_manager = $MarginContainer/VBoxContainer/MarginContainer/OpeningsContainer/Opponents
onready var player_opening_manager = $MarginContainer/VBoxContainer/MarginContainer/OpeningsContainer/Players
onready var health_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/HealthStat/HealthLabel
onready var energy_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/EnergyStat/EnergyLabel
onready var deck_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/DeckStat/DeckLabel

var opponent_data : CharacterData setget set_opponent_data

func set_opponent_data(value:CharacterData):
	opponent_data = value
	_update_opponent_stats()

func _ready():
	_update_opponent_stats()

func _update_opponent_stats():
	if not is_instance_valid(opponent_data):
		return
	if is_instance_valid(health_label):
		health_label.text = "%d / %d" % [opponent_data.health, opponent_data.max_health]
	if is_instance_valid(energy_label):
		energy_label.text = "%d / %d" % [opponent_data.energy, opponent_data.max_energy]
	if is_instance_valid(deck_label):
		deck_label.text = "%d" % [opponent_data.deck_size()]

func add_player_opening(opp_data:OpportunityData):
	return player_opening_manager.add_opening(opp_data)

func sub_player_opening():
	player_opening_manager.sub_opening()

func add_opponent_opening(opp_data:OpportunityData):
	return opponent_opening_manager.add_opening(opp_data)

func sub_opponent_opening():
	opponent_opening_manager.sub_opening()

func remove_all_openings():
	opponent_opening_manager.remove_all_openings()
	player_opening_manager.remove_all_openings()

func get_player_battle_openings():
	return player_opening_manager.get_battle_openings()

func get_opponent_battle_openings():
	return opponent_opening_manager.get_battle_openings()
