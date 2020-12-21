extends Control


signal skip_loot_pressed
signal level_completed
signal view_deck_pressed(deck)
signal card_collected(card_data)
signal card_inspected(card_node)
signal card_forgotten(card_node)

const INIT_CARD_SCALE = Vector2(0.05, 0.05)

onready var loot_container = $MarginContainer/VBoxContainer/LootMargin/LootContainer
onready var card_manager = $MarginContainer/VBoxContainer/LootMargin/CenterContainer/Control/SelectorCardManager
onready var skip_loot_button = $SkipLootButton
onready var add_card_button = $AddCardButton
onready var spawn_card_timer = $SpawnCardTimer
onready var reposition_timer = $RepositionTimer

export(float, 0.0, 2.0) var default_animate_in_time : float = 0.2

export(Array, Resource) var card_options : Array = [] setget set_card_options

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
		
func _ready():
	_spawn_containers()
	yield(loot_container, "sort_children")
	_add_cards_to_containers()

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
	emit_signal("level_completed")

func _on_ViewDeckButton_pressed():
	if player_data is CharacterData:
		emit_signal("view_deck_pressed", player_data.deck)

func _on_SelectorCardManager_inspected_on_card(card_node_2d):
	emit_signal("card_inspected", card_node_2d)

func _on_SelectorCardManager_inspected_off_card(card_node_2d):
	emit_signal("card_forgotten", card_node_2d)

func _on_SelectorCardManager_clicked_card(card_node : CardNode2D):
	selected_card = card_node
	card_manager.hold_focus = false
	card_manager.focus_on_card(card_node)
	if not card_node.is_connected("mouse_exited", self, "_on_CardNode2D_mouse_exited"):
		card_node.connect("mouse_exited", self, "_on_CardNode2D_mouse_exited")
	card_manager.hold_focus = true
	add_card_button.disabled = false

func _on_AddCardButton_pressed():
	if not is_instance_valid(selected_card):
		return
	add_card_button.disabled = true
	emit_signal("card_collected", selected_card.card_data)
	skip_loot_button.disabled = true
	card_manager.focus_on_card(selected_card)
	card_manager.hold_focus = true
	selected_card.play_card()
	yield(selected_card, "animation_completed")
	emit_signal("card_forgotten", selected_card)
	emit_signal("level_completed")

func _on_CardNode2D_mouse_exited(card_node : CardNode2D):
	if card_node.is_connected("mouse_exited", self, "_on_CardNode2D_mouse_exited"):
		card_node.disconnect("mouse_exited", self, "_on_CardNode2D_mouse_exited")
	card_manager.stop_inspecting()
	
