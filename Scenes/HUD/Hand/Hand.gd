extends HBoxContainer


onready var container_scene = preload("res://Scenes/HUD/Hand/CardContainer/CardContainer.tscn")

func add_card(card_scene:PackedScene):
	if not is_instance_valid(container_scene):
		return
	var container_instance = container_scene.instance()
	add_child(container_instance)
	container_instance.set_card(card_scene)
	
