extends CardManager


class_name FocusedCardManager

export(float, 0.0, 16.0) var default_focus_time : float = 0.15
export(Vector2) var scale_focused_card : Vector2 = Vector2(1.25, 1.25)

var _focused_card = null
var _focused_card_parent_index = null
var _focused_card_scale = null
var hold_focus : bool = false
var active : bool = true

func get_focus_time():
	return default_focus_time

func is_card_focused(card_node:CardNode2D):
	return _focused_card == card_node

func _can_change_focus():
	return not hold_focus and active

func remove_card(card_data:CardData):
	var card_instance : CardNode2D = get_card_instance(card_data)
	if not is_instance_valid(card_instance):
		return
	if _focused_card_parent_index != null and card_instance.get_position_in_parent() < _focused_card_parent_index:
		_focused_card_parent_index -= 1
	.remove_card(card_data)

func focus_on_card(card_node:CardNode2D):
	if not _can_change_focus():
		return
	if _focused_card != null:
		focus_off_card(_focused_card)
	_focused_card = card_node
	_focused_card_parent_index = _focused_card.get_position_in_parent()
	_focused_card_scale = _focused_card.card_data.transform_data.scale
	move_child(_focused_card, get_child_count())
	var new_transform : TransformData = _focused_card.card_data.transform_data.duplicate()
	new_transform.scale = scale_focused_card
	move_card(_focused_card.card_data, new_transform, get_focus_time())

func focus_off_card(card_node:CardNode2D):
	if not _can_change_focus() or not is_card_focused(card_node):
		return
	move_child(_focused_card, _focused_card_parent_index)
	_focused_card_parent_index = null
	var new_transform : TransformData = _focused_card.card_data.transform_data.duplicate()
	new_transform.scale = _focused_card_scale
	move_card(_focused_card.card_data, new_transform, get_focus_time())
	_focused_card = null
	_focused_card_scale = null

func _on_Card_mouse_entered(card_node:CardNode2D):
	focus_on_card(card_node)
	._on_Card_mouse_entered(card_node)

func _on_Card_mouse_exited(card_node:CardNode2D):
	focus_off_card(card_node)
	._on_Card_mouse_exited(card_node)
