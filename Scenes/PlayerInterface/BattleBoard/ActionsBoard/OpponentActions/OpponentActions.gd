extends ActionsInterface


class_name OpponentActionsInterface

onready var opponent_opening_container = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Opponents
onready var player_opening_container = $MarginContainer/VBoxContainer/OpeningsMargin/OpeningsContainer/Players
onready var nickname_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/NicknameLabel
onready var health_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/HealthStat/HealthLabel
onready var energy_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/EnergyStat/EnergyLabel
onready var status_icon_manager = $MarginContainer/VBoxContainer/StatusesMargin/StatusIconManager
onready var dead_cover = $DeadCover

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
	var container : Node
	if opportunity.source == character_data:
		container = opponent_opening_container
	elif opportunity.target == character_data:
		container = player_opening_container
	return _add_opening(opportunity, container)

func get_player_battle_openings():
	return get_non_source_battle_openings()

func get_opponent_battle_openings():
	return get_source_battle_openings()

func add_status(status:StatusData):
	status_icon_manager.add_status(status)

func remove_status(status:StatusData):
	status_icon_manager.remove_status(status)

func defeat_character():
	.defeat_character()
	dead_cover.show()
