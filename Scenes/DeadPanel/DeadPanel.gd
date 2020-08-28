extends Panel


signal retry_pressed

func _on_RetryButton_pressed():
	emit_signal("retry_pressed")
