extends FocusedCardManager


func focus_on_card(card_node:CardNode2D):
	if hold_focus:
		return
	.focus_on_card(card_node)
	card_node.glow_on()

func focus_off_card(card_node:CardNode2D):
	if hold_focus or not is_card_focused(card_node):
		return
	.focus_off_card(card_node)
	card_node.glow_off()
