extends Control


signal skip_loot_pressed
signal collected_card(card_data)

const INIT_CARD_SCALE = Vector2(0.05, 0.05)

onready var loot_container = $MarginContainer/VBoxContainer/LootMargin/LootContainer
onready var card_manager = $InspectorCardManager
onready var spawn_card_timer = $SpawnCardTimer

export(float, 0.0, 2.0) var default_animate_in_time : float = 0.2

var card_options : Array = [] setget set_card_options
var card_container_map : Dictionary = {}
var selected_card = null

func _get_animate_in_time():
	return default_animate_in_time

func _add_card_option(card:CardData):
	var prev_prs : PRSData = card.prs.duplicate()
	card.prs.scale = INIT_CARD_SCALE
	var card_node : CardNode2D = card_manager.add_card(card)
	card_manager.move_card(card, prev_prs, _get_animate_in_time())

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

func _add_cards_to_containers():
	for card in card_container_map:
		var container : CardContainer = card_container_map[card]
		if card is CardData:
			spawn_card_timer.start()
			yield(spawn_card_timer, "timeout")
			card.prs.position = container.get_card_global_position()
			_add_card_option(card)

func _on_ContinueButton_pressed():
	emit_signal("continue_pressed")

func _on_InspectorCardManager_released_card(card_node:CardNode2D):
	if selected_card != null:
		return
	selected_card = card_node
	card_manager.focus_on_card(card_node)
	card_manager.hold_focus = true
	card_node.play_card()
	yield(card_node, "animation_completed")
	emit_signal("collected_card", card_node.card_data)
	queue_free()


func _on_SkipLootButton_pressed():
	emit_signal("skip_loot_pressed")
	queue_free()
