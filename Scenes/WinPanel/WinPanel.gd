extends Panel


signal return_pressed

func _on_ReturnButton_pressed():
	emit_signal("return_pressed")
