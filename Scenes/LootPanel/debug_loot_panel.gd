extends "res://Scenes/LootPanel/LootPanel.gd"


var card_count_map : Dictionary[String, int]
var generations : int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_generate_card_options()
	generations += 1
	for card in card_options:
		if card.title not in card_count_map:
			card_count_map[card.title] = 1
			continue
		card_count_map[card.title] += 1

func _on_timer_timeout():
	print(generations, " : ", card_count_map)
