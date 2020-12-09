extends Control

signal return_button_pressed
signal restart_button_pressed
signal save_and_exit_button_pressed

func _on_ReturnButton_pressed():
	emit_signal("return_button_pressed")

func _on_RestartButton_pressed():
	emit_signal("restart_button_pressed")

func _on_SaveAndExitButton_pressed():
	emit_signal("save_and_exit_button_pressed")
