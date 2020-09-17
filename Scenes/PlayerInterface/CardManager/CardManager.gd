extends Node


signal focused_on_card(card_data)
signal focused_off_card(card_data)
signal dragging_card(card_data)
signal dropping_card(card_data)

export(PackedScene) var base_card_scene : PackedScene
export(float, 0.0, 16.0) var default_tween_time : float = 0.5
export(float, 0.0, 16.0) var default_wait_time : float = 0.25
export(float, 0.0, 16.0) var default_focus_time : float = 0.15
export(Vector2) var scale_focused_card : Vector2 = Vector2(1.25, 1.25)

var card_map : Dictionary = {}
var card_instance_map : Dictionary = {}
var focused_card = null
var dragged_card = null
var energy_limit = 0
var _focused_card_parent_index = null
var _focused_card_scale = null

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
	return card_instance

func remove_card(card_data:CardData):
	var card_instance : CardNode2D = get_card_instance(card_data)
	if not is_instance_valid(card_instance):
		return
	card_instance_map.erase(card_instance)
	if _focused_card_parent_index != null and card_instance.get_position_in_parent() < _focused_card_parent_index:
		_focused_card_parent_index -= 1
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

func get_focus_time():
	return default_focus_time

func move_card(card_data:CardData, new_transform:TransformData, tween_time:float = get_tween_time(), anim_type:int = 0):
	if card_data.transform_data.is_equal(new_transform):
		return
	force_move_card(card_data, new_transform, tween_time)

func force_move_card(card_data:CardData, new_transform:TransformData, tween_time:float = get_tween_time()):
	var card: CardNode2D = get_card_instance(card_data)
	if is_instance_valid(card):
		card.tween_to(new_transform, tween_time)
		return
	card_data.transform_data = new_transform

func focus_on_card(card_node:CardNode2D):
	focused_card = card_node
	if card_node.card_data.energy_cost > energy_limit:
		card_node.glow_not()
	else:
		card_node.glow_on()
	_focused_card_parent_index = card_node.get_position_in_parent()
	_focused_card_scale = card_node.card_data.transform_data.scale
	move_child(card_node, get_child_count())
	var new_transform : TransformData = card_node.card_data.transform_data.duplicate()
	new_transform.scale = scale_focused_card
	move_card(card_node.card_data, new_transform, get_focus_time())
	emit_signal("focused_on_card", card_node.card_data)

func focus_off_card(card_node:CardNode2D):
	card_node.glow_off()
	if focused_card == card_node:
		focused_card = null
		move_child(card_node, _focused_card_parent_index)
		_focused_card_parent_index = null
		var new_transform : TransformData = card_node.card_data.transform_data.duplicate()
		new_transform.scale = _focused_card_scale
		move_card(card_node.card_data, new_transform,  get_focus_time())
		_focused_card_scale = null
	emit_signal("focused_off_card", card_node.card_data)

func _on_Card_mouse_entered(card_node:CardNode2D):
	focus_on_card(card_node)

func _on_Card_mouse_exited(card_node:CardNode2D):
	focus_off_card(card_node)

func _on_Card_mouse_clicked(card_node:CardNode2D):
	if card_node.card_data.energy_cost > energy_limit:
		return
	dragged_card = card_node
	emit_signal("dragging_card", card_node.card_data)

func _on_Card_mouse_released(card_node:CardNode2D):
	if dragged_card != card_node:
		return
	dragged_card = null
	emit_signal("dropping_card", card_node.card_data)
