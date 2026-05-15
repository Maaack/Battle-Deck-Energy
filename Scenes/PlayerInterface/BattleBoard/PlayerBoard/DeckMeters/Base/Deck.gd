@tool
extends Control

signal button_pressed
signal reshuffling_finished

@onready var count_label = $TextureRect/Panel/CountLabel

var count : int = 0: set = set_count
var reshuffling_count : int = 0

func set_count(value:int):
	count = value
	_update_count()

func is_reshuffling() -> bool:
	return reshuffling_count > 0

func is_reshuffled() -> bool:
	return reshuffling_count == 0

func can_draw() -> bool:
	return is_reshuffled() and count > 0

func _ready():
	_update_count()

func _update_count():
	if not is_instance_valid(count_label):
		return
	count_label.text = str(count)

func add_card():
	count += 1
	reshuffling_count -= 1
	reshuffling_count = max(0, reshuffling_count)
	_update_count()
	if reshuffling_count == 0:
		reshuffling_finished.emit()

func remove_card():
	count -= 1
	_update_count()

func _on_TextureButton_pressed():
	button_pressed.emit()
