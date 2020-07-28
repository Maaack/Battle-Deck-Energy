extends Container


onready var card_container = $CenteredControl

var card_scene : PackedScene setget set_card, get_card

func set_card(value:PackedScene):
	if not is_instance_valid(card_container):
		return
	_clear_children()
	card_scene = value
	if not is_instance_valid(card_scene):
		return
	var card_instance = card_scene.instance()
	card_container.add_child(card_instance)

func get_card():
	return card_scene

func _clear_children():
	if card_container.get_child_count() > 0:
		for child in card_container.get_children():
			child.queue_free()
