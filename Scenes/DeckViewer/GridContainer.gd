extends Control


var card_container_scene = preload("res://Managers/Cards/CardContainer/GridCardContainer/GridCardContainer.tscn")

func add_card_container():
	var card_container = card_container_scene.instance()
	add_child(card_container)
	return card_container
