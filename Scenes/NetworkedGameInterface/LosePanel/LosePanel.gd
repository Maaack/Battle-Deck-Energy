extends Panel


signal exit_pressed

func _on_ExitButton_pressed():
	emit_signal("exit_pressed")
