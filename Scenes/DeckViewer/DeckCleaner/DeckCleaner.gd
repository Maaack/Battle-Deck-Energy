extends DeckViewer


class_name DeckCleaner

signal card_cleaned(card_data)

onready var remove_card_button = $RemoveCardButton

func _on_SelectorCardManager_double_clicked_card(card_node:CardNode2D):
	emit_signal("card_cleaned", card_node.card_data)
	emit_signal("card_forgotten", null)
	emit_signal("back_pressed")

func _on_SelectorCardManager_clicked_card(card_node):
	selected_card = card_node
	card_manager.hold_focus = false
	card_manager.focus_on_card(card_node)
	card_node.connect("mouse_exited", self, "_on_CardNode2D_mouse_exited")
	card_manager.hold_focus = true
	remove_card_button.disabled = false

func _on_RemoveCardButton_pressed():
	if not is_instance_valid(selected_card):
		return
	emit_signal("card_cleaned", selected_card.card_data)
	emit_signal("card_forgotten", null)
	emit_signal("back_pressed")

func _on_CardNode2D_mouse_exited(card_node : CardNode2D):
	if card_node.is_connected("mouse_exited", self, "_on_CardNode2D_mouse_exited"):
		card_node.disconnect("mouse_exited", self, "_on_CardNode2D_mouse_exited")
	card_manager.stop_inspecting()
