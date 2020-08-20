tool
extends Control


onready var count_label = $TextureRect/Panel/CountLabel

var count : int = 0 setget set_count

func set_count(value:int):
	count = value
	_update_count()

func _ready():
	_update_count()

func _update_count():
	if not is_instance_valid(count_label):
		return
	count_label.text = str(count)

func add_card():
	count += 1
	_update_count()

func remove_card():
	count -= 1
	_update_count()
