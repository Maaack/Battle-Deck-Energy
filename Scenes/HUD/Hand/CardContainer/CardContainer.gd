extends Container


onready var card_container = $CenteredControl


func set_card(card_scene:PackedScene):
	if not is_instance_valid(card_container):
		return
	_clear_children()
	var card_instance = card_scene.instance()
	card_container.add_child(card_instance)

func _clear_children():
	if card_container.get_child_count() > 0:
		for child in card_container.get_children():
			child.queue_free()
