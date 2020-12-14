extends DeckViewer


class_name DeckCleaner

signal card_cleaned(card_data)


func _on_SelectorCardManager_double_clicked_card(card_node:CardNode2D):
	emit_signal("card_cleaned", card_node.card_data)
	emit_signal("card_forgotten", null)
	emit_signal("back_pressed")
