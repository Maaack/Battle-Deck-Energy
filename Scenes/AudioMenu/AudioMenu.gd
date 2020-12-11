extends Control

signal return_button_pressed

const MASTER_AUDIO_BUS = 'Master'
const SFX_AUDIO_BUS = 'SFX'
const MUSIC_AUDIO_BUS = 'Music'

onready var master_slider = $Panel/MarginContainer/VBoxContainer/MasterControl/MasterHSlider
onready var sfx_slider = $Panel/MarginContainer/VBoxContainer/SFXControl/SFXHSlider
onready var music_slider = $Panel/MarginContainer/VBoxContainer/MusicControl/MusicHSlider
onready var mute_button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/MuteButton

func _get_bus_volume_2_linear(bus_name : String):
	var bus_index : int = AudioServer.get_bus_index(bus_name)
	var audio_db : float = AudioServer.get_bus_volume_db(bus_index)
	return db2linear(audio_db)

func _is_muted():
	var bus_index : int = AudioServer.get_bus_index(MASTER_AUDIO_BUS)
	return AudioServer.is_bus_mute(bus_index)

func _update_settings():
	master_slider.value = _get_bus_volume_2_linear(MASTER_AUDIO_BUS)
	sfx_slider.value = _get_bus_volume_2_linear(SFX_AUDIO_BUS)
	music_slider.value = _get_bus_volume_2_linear(MUSIC_AUDIO_BUS)
	mute_button.pressed = _is_muted()

func _ready():
	_update_settings()

func _on_ReturnButton_pressed():
	emit_signal("return_button_pressed")

func _on_MasterHSlider_value_changed(value):
	var bus_index : int = AudioServer.get_bus_index(MASTER_AUDIO_BUS)
	AudioServer.set_bus_volume_db(bus_index, linear2db(value))

func _on_SFXHSlider_value_changed(value):
	var bus_index : int = AudioServer.get_bus_index(SFX_AUDIO_BUS)
	AudioServer.set_bus_volume_db(bus_index, linear2db(value))

func _on_MusicHSlider_value_changed(value):
	var bus_index : int = AudioServer.get_bus_index(MUSIC_AUDIO_BUS)
	AudioServer.set_bus_volume_db(bus_index, linear2db(value))

func _on_MuteButton_toggled(button_pressed):
	var bus_index : int = AudioServer.get_bus_index(MASTER_AUDIO_BUS)
	AudioServer.set_bus_mute(bus_index, button_pressed)

func _unhandled_key_input(event):
	if event.is_action_released('ui_mute'):
		mute_button.pressed = !(mute_button.pressed)
