extends InspectorCardManager


signal dragging_card(card_data)
signal dropping_card(card_data)

var locked_cards : Dictionary = {}
var energy_available : int = 0 setget set_energy_available
var dragged_card = null

func set_energy_available(value:int):
	energy_available = value
	for card_data in card_map:
		var card_instance : CardNode2D = card_map[card_data]
		card_instance.update_affordability(energy_available)

func _ready():
	active = false

func _can_afford_card(card_node:CardNode2D):
	return card_node.card_data.energy_cost <= energy_available

func is_locked_card(card_data:CardData):
	return card_data in locked_cards

func lock_card(card_data:CardData):
	locked_cards[card_data] = true

func unlock_card(card_data:CardData):
	return locked_cards.erase(card_data)

func remove_card(card_data:CardData):
	unlock_card(card_data)
	.remove_card(card_data)

func move_card(card_data:CardData, new_transform:TransformData, tween_time:float = get_tween_time()):
	if card_data in locked_cards:
		return
	.move_card(card_data, new_transform, tween_time)

func focus_on_card(card_node:CardNode2D):
	if not _can_change_focus():
		return
	.focus_on_card(card_node)
	if card_node.is_playable() and _can_afford_card(card_node):
		card_node.glow_on()
	else:
		card_node.glow_not()

func focus_off_card(card_node:CardNode2D):
	if not _can_change_focus() or not is_card_focused(card_node):
		return
	.focus_off_card(card_node)
	card_node.glow_off()

func drag_to_position(position:Vector2):
	if dragged_card == null:
		return
	if dragged_card is CardNode2D:
		var transform_data = dragged_card.card_data.transform_data.duplicate()
		transform_data.position = position
		move_card(dragged_card.card_data, transform_data, 0.05)
		return dragged_card

func _is_card_playable(card_node:CardNode2D):
	return _can_change_focus() and card_node.is_playable() and not is_locked_card(card_node.card_data) and _can_afford_card(card_node)

func _on_Card_mouse_clicked(card_node:CardNode2D):
	._on_Card_mouse_clicked(card_node)
	if not _is_card_playable(card_node):
		return
	dragged_card = card_node
	_stop_inspecting_card(card_node)
	card_node.play_draw_audio()
	emit_signal("dragging_card", card_node.card_data)
	
func _on_Card_mouse_released(card_node:CardNode2D):
	._on_Card_mouse_released(card_node)
	card_node.play_drop_audio()
	if dragged_card != card_node:
		return
	dragged_card = null
	emit_signal("dropping_card", card_node.card_data)
