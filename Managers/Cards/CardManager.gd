extends Node


class_name CardManager

signal focused_on_card(card_node)
signal focused_off_card(card_node)
signal clicked_card(card_node)
signal released_card(card_node)
signal tween_completed(card_node)

export(PackedScene) var base_card_scene : PackedScene
export(float, 0.0, 16.0) var default_tween_time : float = 0.5

var card_map : Dictionary = {}
var card_instance_map : Dictionary = {}

func add_card(card_data:CardData):
	if card_data in card_map:
		return card_map[card_data]
	var card_instance = base_card_scene.instance()
	if card_instance is CardNode2D:
		card_instance.card_data = card_data
		card_map[card_data] = card_instance
		card_instance_map[card_instance] = card_data
		add_child(card_instance)
		card_instance.connect("mouse_entered", self, "_on_Card_mouse_entered")
		card_instance.connect("mouse_exited", self, "_on_Card_mouse_exited")
		card_instance.connect("mouse_clicked", self, "_on_Card_mouse_clicked")
		card_instance.connect("mouse_released", self, "_on_Card_mouse_released")
		card_instance.connect("tween_completed", self, "_on_Card_tween_completed")
	return card_instance

func remove_card(card_data:CardData):
	var card_instance : CardNode2D = get_card_instance(card_data)
	if not is_instance_valid(card_instance):
		return
	card_map.erase(card_data)
	card_instance_map.erase(card_instance)
	card_instance.queue_free()

func get_card_instance(card_data:CardData):
	if not card_data in card_map:
		return
	return card_map[card_data]

func get_tween_time():
	return default_tween_time

func move_card(card_data:CardData, new_prs:PRSData, tween_time:float = get_tween_time()):
	if card_data.prs.is_equal(new_prs):
		return
	force_move_card(card_data, new_prs, tween_time)

func force_move_card(card_data:CardData, new_prs:PRSData, tween_time:float = get_tween_time()):
	var card: CardNode2D = get_card_instance(card_data)
	if is_instance_valid(card):
		card.tween_to(new_prs, tween_time)
	card_data.prs = new_prs

func _on_Card_mouse_entered(card_node:CardNode2D):
	emit_signal("focused_on_card", card_node)

func _on_Card_mouse_exited(card_node:CardNode2D):
	emit_signal("focused_off_card", card_node)

func _on_Card_mouse_clicked(card_node:CardNode2D):
	emit_signal("clicked_card", card_node)

func _on_Card_mouse_released(card_node:CardNode2D):
	emit_signal("released_card", card_node)

func _on_Card_tween_completed(card_node:CardNode2D):
	emit_signal("tween_completed", card_node)
