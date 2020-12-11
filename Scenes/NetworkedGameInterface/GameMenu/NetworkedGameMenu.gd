extends Control

signal return_button_pressed
signal forfeit_and_exit_button_pressed

onready var main_menu = $MainPanel
onready var audio_menu = $AudioMenu

func _on_ReturnButton_pressed():
	emit_signal("return_button_pressed")

func _on_ForfeitAndExitButton_pressed():
	emit_signal("forfeit_and_exit_button_pressed")

func reset():
	audio_menu.hide()
	main_menu.show()

func _on_OptionsButton_pressed():
	main_menu.hide()
	audio_menu.show()

func _on_AudioMenu_return_button_pressed():
	reset()
