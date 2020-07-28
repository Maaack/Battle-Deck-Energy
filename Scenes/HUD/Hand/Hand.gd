extends HBoxContainer


onready var container_scene = preload("res://Scenes/HUD/Hand/CardContainer/CardContainer.tscn")

func add_card(card_scene:PackedScene):
	if not is_instance_valid(container_scene):
		return
	var container_instance = container_scene.instance()
	add_child(container_instance)
	container_instance.set_card(card_scene)

func discard_hand():
	var discarded_cards : Array = []
	for child in get_children():
		if child.has_method("get_card"):
			discarded_cards.append(child.get_card())
			child.queue_free()
	return discarded_cards
