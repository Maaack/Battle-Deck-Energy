extends CenterContainer


onready var hand_container = $HBoxContainer

var container_scene = preload("res://Scenes/HUD/Hand/CardContainer/CardContainer.tscn")
var card_count : int = 0

func add_card(card_scene:PackedScene):
	if not is_instance_valid(container_scene):
		return
	var container_instance = container_scene.instance()
	hand_container.add_child(container_instance)
	container_instance.set_card(card_scene)
	hand_container.connect("resized", container_instance, "_on_Parent_resized")
	card_count += 1

func discard_hand():
	var discarded_cards : Array = []
	for child in hand_container.get_children():
		if child.has_method("get_card"):
			discarded_cards.append(child.get_card())
			child.queue_free()
			card_count -= 1
	if card_count > 0:
		print("Couldn't free all cards!")
	return discarded_cards
