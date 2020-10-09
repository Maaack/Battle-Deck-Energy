extends Control


signal skip_loot_pressed
signal view_deck_pressed(deck)
signal card_collected(card_data)
signal card_inspected(card_node)
signal card_forgotten(card_node)

const INIT_CARD_SCALE = Vector2(0.05, 0.05)

onready var loot_container = $MarginContainer/VBoxContainer/LootMargin/LootContainer
onready var card_manager = $MarginContainer/VBoxContainer/LootMargin/CenterContainer/Control/SelectorCardManager
onready var skip_loot_button = $MarginContainer/VBoxContainer/OptionsContainer/SkipLootButton
onready var spawn_card_timer = $SpawnCardTimer
onready var reposition_timer = $RepositionTimer

export(float, 0.0, 2.0) var default_animate_in_time : float = 0.2

var card_options : Array = [] setget set_card_options
var card_container_map : Dictionary = {}
var player_data = null
var selected_card = null

func _get_animate_in_time():
	return default_animate_in_time

func _add_card_option(card:CardData):
	var prev_transform : TransformData = card.transform_data.duplicate()
	card.transform_data.scale = INIT_CARD_SCALE
	var card_node : CardNode2D = card_manager.add_card(card)
	card_manager.move_card(card, prev_transform, _get_animate_in_time())

func _spawn_containers():
	for card in card_options:
		var container_node = loot_container.add_card_container()
		card_container_map[card] = container_node

func set_card_options(values:Array):
	card_options = []
	for card in values:
		card_options.append(card.duplicate())
	_spawn_containers()
	yield(loot_container, "sort_children")
	_add_cards_to_containers()

func _update_card_position(card:CardData):
	var center_offset : Vector2 = card_manager.get_global_transform().get_origin()
	var container : CardContainer = card_container_map[card]
	var transform : TransformData = card.transform_data.duplicate()
	transform.position = container.get_card_parent_position() - center_offset
	card_manager.force_move_card(card, transform, 0.05)

func _add_cards_to_containers():
	for card in card_container_map:
		var container : CardContainer = card_container_map[card]
		if card is CardData:
			spawn_card_timer.start()
			yield(spawn_card_timer, "timeout")
			var center_offset : Vector2 = card_manager.get_global_transform().get_origin()
			card.transform_data.position = container.get_card_parent_position() - center_offset
			_add_card_option(card)

func _on_SkipLootButton_pressed():
	emit_signal("skip_loot_pressed")
	queue_free()

func _on_ViewDeckButton_pressed():
	if player_data is CharacterData:
		emit_signal("view_deck_pressed", player_data.deck)

func _on_SelectorCardManager_inspected_on_card(card_node_2d):
	emit_signal("card_inspected", card_node_2d)

func _on_SelectorCardManager_inspected_off_card(card_node_2d):
	emit_signal("card_forgotten", card_node_2d)

func _on_SelectorCardManager_double_clicked_card(card_node):
	emit_signal("card_collected", card_node.card_data)
	skip_loot_button.disabled = true
	card_manager.focus_on_card(card_node)
	card_manager.hold_focus = true
	card_node.play_card()
	yield(card_node, "animation_completed")
	emit_signal("card_forgotten", card_node)
	queue_free()
