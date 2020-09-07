extends ActionsInterface


class_name OpponentActionsInterface

onready var opponent_opening_manager = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Opponents
onready var player_opening_manager = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Players
onready var nickname_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/NicknameLabel
onready var health_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/HealthStat/HealthLabel
onready var energy_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/EnergyStat/EnergyLabel
onready var status_icon_manager = $MarginContainer/VBoxContainer/StatusesMargin/StatusIconManager

func _update_opponent_stats():
	if not character_data is OpponentCharacterData:
		return
	if is_instance_valid(health_label):
		health_label.text = "%d / %d" % [character_data.health, character_data.max_health]
	if is_instance_valid(energy_label):
		energy_label.text = "%d / %d" % [character_data.energy, character_data.max_energy]
	if is_instance_valid(nickname_label):
		nickname_label.text =  character_data.nickname

func set_character_data(value:CharacterData):
	character_data = value
	_update_opponent_stats()

func _ready():
	_update_opponent_stats()

func update():
	_update_opponent_stats()

func add_opening(opportunity:OpportunityData):
	if opportunity.source == character_data:
		return opponent_opening_manager.add_opening(opportunity)
	elif opportunity.target == character_data:
		return player_opening_manager.add_opening(opportunity)

func remove_all_openings():
	opponent_opening_manager.remove_all_openings()
	player_opening_manager.remove_all_openings()

func get_player_battle_openings():
	return player_opening_manager.get_battle_openings()

func get_opponent_battle_openings():
	return opponent_opening_manager.get_battle_openings()

func add_status(status:StatusData):
	status_icon_manager.add_status(status)

func remove_status(status:StatusData):
	status_icon_manager.remove_status(status)
