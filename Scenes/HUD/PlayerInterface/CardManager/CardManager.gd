extends Node


onready var card_container = $Container
onready var animation_queue = $AnimationQueue

export(PackedScene) var base_card_scene : PackedScene

var card_map : Dictionary = {}

func add_card(card_data:CardData):
	var card_instance = base_card_scene.instance()
	if card_instance is Card2:
		card_instance.card_data = card_data
		card_map[card_data] = card_instance
		card_container.add_child(card_instance)
	return card_instance

func remove_card(card_data:CardData):
	if card_data in card_map:
		var card_instance : Card2 = card_map[card_data]
		card_instance.queue_free()
		card_map.erase(card_data)

func get_card_instance(card_data:CardData):
	if not card_data in card_map:
		return
	return card_map[card_data]

