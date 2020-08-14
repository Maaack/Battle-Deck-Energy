extends Node


signal focused_on_card(card_data)
signal focused_off_card(card_data)

export(PackedScene) var base_card_scene : PackedScene
export(float, 0.0, 16.0) var default_tween_time : float = 0.5
export(float, 0.0, 16.0) var default_wait_time : float = 0.25

var card_map : Dictionary = {}
var card_instance_map : Dictionary = {}
var focused_card = null

func add_card(card_data:CardData):
	if card_data in card_map:
		return card_map[card_data]
	var card_instance = base_card_scene.instance()
	if card_instance is Card2:
		card_instance.card_data = card_data
		card_map[card_data] = card_instance
		card_instance_map[card_instance] = card_data
		add_child(card_instance)
		card_instance.connect("mouse_entered", self, "_on_Card_mouse_entered")
		card_instance.connect("mouse_exited", self, "_on_Card_mouse_exited")
	return card_instance

func remove_card(card_data:CardData):
	var card_instance : Card2 = get_card_instance(card_data)
	if not is_instance_valid(card_instance):
		return
	card_instance_map.erase(card_instance)
	card_instance.queue_free()
	card_map.erase(card_data)

func get_card_instance(card_data:CardData):
	if not card_data in card_map:
		return
	return card_map[card_data]

func get_tween_time():
	return default_tween_time

func get_wait_time():
	return default_wait_time

func move_card(card_data:CardData, new_prs:PRSData, tween_time:float = get_tween_time(), anim_type:int = 0):
	var card: Card2 = get_card_instance(card_data)
	if is_instance_valid(card):
		card.tween_to(new_prs, tween_time)
	card_data.prs = new_prs

func focus_on_card(card_data):
	focused_card = card_data
	print("focus_on_card")
	emit_signal("focused_on_card", card_data)

func focus_off_card(card_data):
	if focused_card == card_data:
		focused_card = null
	print("focus_off")
	emit_signal("focused_off_card", card_data)

func _on_Card_mouse_entered(card_data:CardData):
	var card : Card2 = get_card_instance(card_data)
	card.glow_on()
	focus_on_card(card_data)

func _on_Card_mouse_exited(card_data:CardData):
	var card : Card2 = get_card_instance(card_data)
	card.glow_off()
	focus_off_card(card_data)
