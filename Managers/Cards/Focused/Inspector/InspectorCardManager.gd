extends FocusedCardManager


class_name InspectorCardManager

signal inspected_on_card(card_node_2d)
signal inspected_off_card(card_node_2d)

onready var timer_node = $InspectTimer

var _inspected_card = null

func _stop_inspecting_card(card_node:CardNode2D):
	timer_node.stop()
	if not is_instance_valid(_inspected_card):
		return
	emit_signal("inspected_off_card", _inspected_card)	
	_inspected_card = null

func focus_on_card(card_node:CardNode2D):
	if not _can_change_focus():
		return
	.focus_on_card(card_node)
	timer_node.start()

func focus_off_card(card_node:CardNode2D):
	if not _can_change_focus() or not is_card_focused(card_node):
		return
	.focus_off_card(card_node)
	_stop_inspecting_card(card_node)

func _on_InspectTimer_timeout():
	if not is_instance_valid(_focused_card):
		return
	_inspected_card = _focused_card
	emit_signal("inspected_on_card", _inspected_card)

func stop_inspecting():
	_stop_inspecting_card(get_focused_card())
	timer_node.stop()

