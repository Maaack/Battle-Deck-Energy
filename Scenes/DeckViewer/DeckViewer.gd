extends Control


signal back_pressed
signal card_inspected(card_node)
signal card_forgotten(card_node)

const INIT_CARD_SCALE = Vector2(0.05, 0.05)

onready var deck_container = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
onready var card_manager = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer/SelectorCardManager
onready var spawn_card_timer = $SpawnCardTimer

export(float, 0.0, 2.0) var default_animate_in_time : float = 0.2

var deck : Array = [] setget set_deck
var card_container_map : Dictionary = {}
var selected_card = null

func _get_animate_in_time():
	return default_animate_in_time

func _add_card_option(card:CardData):
	var prev_transform : TransformData = card.transform_data.duplicate()
	card.transform_data.scale = INIT_CARD_SCALE
	card_manager.add_card(card)
	card_manager.move_card(card, prev_transform, _get_animate_in_time())

func _spawn_containers():
	for card in deck:
		var container_node = deck_container.add_card_container()
		card_container_map[card] = container_node

func set_deck(value:Array):
	for card in value:
		if card is CardData:
			deck.append(card.duplicate())
	_spawn_containers()
	yield(deck_container, "sort_children")
	_add_cards_to_containers()

func _add_cards_to_containers():
	for card in card_container_map:
		var container : CardContainer = card_container_map[card]
		if card is CardData:
			spawn_card_timer.start()
			yield(spawn_card_timer, "timeout")
			card.transform_data.position = container.get_card_parent_position()
			_add_card_option(card)

func _on_BackButton_pressed():
	emit_signal("card_forgotten", null)
	emit_signal("back_pressed")
	queue_free()

func _on_SelectorCardManager_inspected_on_card(card_node_2d):
	emit_signal("card_inspected", card_node_2d)

func _on_SelectorCardManager_inspected_off_card(card_node_2d):
	emit_signal("card_forgotten", card_node_2d)
