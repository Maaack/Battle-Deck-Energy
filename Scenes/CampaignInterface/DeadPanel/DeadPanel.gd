extends Panel


signal retry_pressed
signal exit_pressed
signal forfeit_pressed

func _on_RetryButton_pressed():
	emit_signal("retry_pressed")

func _on_ExitButton_pressed():
	emit_signal("exit_pressed")

func _on_ForfeitButton_pressed():
	emit_signal("forfeit_pressed")
