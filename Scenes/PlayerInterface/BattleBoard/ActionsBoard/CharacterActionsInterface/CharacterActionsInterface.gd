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
onready var active_panel = $ActivePanel

export(PackedScene) var stab_audio_scene : PackedScene
export(PackedScene) var clank_audio_scene : PackedScene
export(PackedScene) var shield_audio_scene : PackedScene

func _update_nickname(nickname:String = ""):
	nickname_label.text = nickname

func _get_random_pitch():
	return rand_range(0.89090, 1.12246)

func spawn_audio_stream(audio_stream_instance:AudioStreamPlayer2D):
	health_meter.add_child(audio_stream_instance)
	audio_stream_instance.pitch_scale = _get_random_pitch()
	audio_stream_instance.play()
	yield(audio_stream_instance, "finished")
	audio_stream_instance.queue_free()

func play_stab_audio():
	spawn_audio_stream(stab_audio_scene.instance())

func play_clank_audio():
	spawn_audio_stream(clank_audio_scene.instance())

func play_shield_audio():
	spawn_audio_stream(shield_audio_scene.instance())
	
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

func update_status(status:StatusData):
	match(status.type_tag):
		EffectCalculator.ENERGY_STATUS:
			return
		EffectCalculator.HEALTH_STATUS:
			if health_meter.health > status.intensity:
				play_stab_audio()
			health_meter.health = status.intensity
			return
		EffectCalculator.DEFENSE_STATUS:
			if health_meter.armor > status.intensity:
				play_clank_audio()
			elif health_meter.armor < status.intensity:
				play_shield_audio()
			health_meter.armor = status.intensity
			return
	status_icon_manager.update_status(status)

func defeat_character():
	remove_all_opportunities()

func _on_OpportunitiesContainter_update_opportunity(opportunity, container):
	emit_signal("update_opportunity", opportunity, container)

func _on_StatusIconManager_status_forgotten(status_icon):
	emit_signal("status_forgotten", status_icon)

func _on_StatusIconManager_status_inspected(status_icon):
	emit_signal("status_inspected", status_icon)

func mark_active():
	active_panel.show()

func mark_inactive():
	active_panel.hide()
