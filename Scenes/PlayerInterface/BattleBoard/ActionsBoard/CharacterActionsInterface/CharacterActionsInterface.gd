extends ActionsInterface


class_name CharacterActionsInterface

signal update_opportunity(opportunity, container)
signal status_inspected(status_icon)
signal status_forgotten(status_icon)

const ARMOR_STATUS = 'DEFENSE'

onready var nickname_label = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/NicknameLabel
onready var health_meter = $MarginContainer/VBoxContainer/Panel/MarginContainer/Panel/MarginContainer/HBoxContainer/HealthMeter
onready var status_icon_manager = $MarginContainer/VBoxContainer/StatusesMargin/StatusIconManager
onready var opportunities_container = $MarginContainer/VBoxContainer/OpeningsMargin/OpportunitiesContainter

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

func add_opportunity(opportunity:OpportunityData):
	if opportunity in opportunities_map:
		return
	opportunities_map[opportunity] = true
	opportunities_container.add_opportunity(opportunity)
	return opportunities_container

func remove_opportunity(opportunity:OpportunityData, erase_flag = true):
	if not opportunity in opportunities_map:
		return
	opportunities_container.remove_opportunity(opportunity)
	if erase_flag:
		opportunities_map.erase(opportunity)

func remove_all_opportunities():
	for opportunity in opportunities_map:
		remove_opportunity(opportunity, false)
	opportunities_map.clear()

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

func defeat_character():
	remove_all_opportunities()

func _on_OpportunitiesContainter_update_opportunity(opportunity, container):
	emit_signal("update_opportunity", opportunity, container)

func _on_StatusIconManager_status_forgotten(status_icon):
	emit_signal("status_forgotten", status_icon)

func _on_StatusIconManager_status_inspected(status_icon):
	emit_signal("status_inspected", status_icon)
