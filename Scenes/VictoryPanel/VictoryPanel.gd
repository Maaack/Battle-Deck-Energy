extends Panel


signal continue_pressed

func _on_ContinueButton_pressed():
	emit_signal("continue_pressed")
