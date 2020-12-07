extends CardManager


func add_card(card_data:CardData):
	if card_data in card_map:
		return card_map[card_data]
	var card_instance = base_card_scene.instance()
	if card_instance is BaseCardNode2D:
		card_map[card_data] = card_instance
		card_instance_map[card_instance] = card_data
		add_child(card_instance)
		card_instance.connect("tween_completed", self, "_on_Card_tween_completed")
	return card_instance

func remove_card(card_data:CardData):
	var card_instance : CardNode2D = get_card_instance(card_data)
	if not is_instance_valid(card_instance):
		return
	card_map.erase(card_data)
	card_instance_map.erase(card_instance)
	card_instance.queue_free()
