extends ActionsInterface


class_name CharacterActionsInterface

const ARMOR_STATUS = 'DEFENSE'

onready var nickname_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/NicknameLabel
onready var health_meter = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/HealthMeter
onready var status_icon_manager = $MarginContainer/VBoxContainer/StatusesMargin/StatusIconManager

func _update_nickname(nickname:String = ""):
	nickname_label.text = nickname

func update_health():
	if not is_instance_valid(health_meter):
		return
	if character_data == null:
		return
	health_meter.health = character_data.health

func update_max_health():
	if not is_instance_valid(health_meter):
		return
	if character_data == null:
		return
	health_meter.max_health = character_data.max_health

func update_meters():
	update_max_health()
	update_health()

func set_character_data(value:CharacterData):
	.set_character_data(value)
	update_meters()
	_update_nickname()

func add_status(status:StatusData):
	if status.type_tag == ARMOR_STATUS:
		health_meter.armor = status.intensity
		return
	status_icon_manager.add_status(status)

func remove_status(status:StatusData):
	if status.type_tag == ARMOR_STATUS:
		health_meter.armor = 0
		return
	status_icon_manager.remove_status(status)
