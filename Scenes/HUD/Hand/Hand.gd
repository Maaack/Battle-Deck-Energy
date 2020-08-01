extends CenterContainer


signal discarding_card

onready var hand_manager = $HandContainer/HandManager

func add_card(card:Card):
	hand_manager.add_card(card)

func discard_hand():
	hand_manager.discard_hand()

func get_center():
	return rect_position + (rect_size / 2)

func _on_HandManager_discarding_card(discarding_card:Card):
	emit_signal("discarding_card", discarding_card)
