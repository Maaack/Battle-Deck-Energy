extends Control


class_name DeckViewer

signal back_pressed
signal card_inspected(card_node)
signal card_forgotten(card_node)

const INIT_CARD_SCALE = Vector2(0.05, 0.05)
const FINAL_CARD_SCALE = Vector2(1.0, 1.0)
const FINAL_ROTATION = 0

onready var deck_container = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
onready var card_manager = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer/SelectorCardManager
onready var spawn_card_timer = $SpawnCardTimer
onready var deck_label = $MarginContainer/VBoxContainer/DeckLabel

export(float, 0.0, 2.0) var default_animate_in_time : float = 0.2

var deck : Array = [] setget set_deck
var card_container_map : Dictionary = {}
var selected_card = null
var title : String setget set_title

func set_title(value : String):
	title = value
	if title.length() > 0:
		deck_label.show()
		deck_label.text = title

func _get_animate_in_time():
	return default_animate_in_time

func _add_card_option(card:CardData):
	var final_transform : TransformData = card.transform_data.duplicate()
	final_transform.scale = FINAL_CARD_SCALE
	final_transform.rotation = FINAL_ROTATION
	card.transform_data.scale = INIT_CARD_SCALE
	card_manager.add_card(card)
	card_manager.move_card(card, final_transform, _get_animate_in_time())

func _spawn_containers():
	for card in deck:
		var container_node = deck_container.add_card_container()
		card_container_map[card] = container_node

func _add_cards_from_deck():
	if not is_instance_valid(deck_container):
		return
	_spawn_containers()
	yield(deck_container, "sort_children")
	_add_cards_to_containers()

func set_deck(value:Array):
	for card in value:
		if card is CardData:
			deck.append(card)
	_add_cards_from_deck()

func _add_cards_to_containers():
	for card in card_container_map:
		var container : CardContainer = card_container_map[card]
		if card is CardData:
			spawn_card_timer.start()
			yield(spawn_card_timer, "timeout")
			var container_offset : Vector2 = deck_container.get_global_transform().get_origin()
			card.transform_data.position = container.get_card_parent_position() - container_offset
			_add_card_option(card)

func _on_BackButton_pressed():
	emit_signal("card_forgotten", null)
	emit_signal("back_pressed")

func _on_SelectorCardManager_inspected_on_card(card_node_2d):
	emit_signal("card_inspected", card_node_2d)

func _on_SelectorCardManager_inspected_off_card(card_node_2d):
	emit_signal("card_forgotten", card_node_2d)
