extends HBoxContainer


var card_container_scene = preload("res://Managers/Cards/CardContainer/CardContainer.tscn")

func add_card_container():
	var card_container = card_container_scene.instance()
	add_child(card_container)
	return card_container
