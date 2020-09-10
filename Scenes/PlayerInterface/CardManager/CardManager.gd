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
	if card_instance is BattleCard:
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
	var card_instance : BattleCard = get_card_instance(card_data)
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

func move_card(card_data:CardData, new_prs:PRSData, tween_time:float = get_tween_time(), anim_type:int = 0):
	if card_data.prs.is_equal(new_prs):
		return
	force_move_card(card_data, new_prs, tween_time)

func force_move_card(card_data:CardData, new_prs:PRSData, tween_time:float = get_tween_time()):
	var card: BattleCard = get_card_instance(card_data)
	if is_instance_valid(card):
		card.tween_to(new_prs, tween_time)
	card_data.prs = new_prs

func focus_on_card(card:CardData):
	focused_card = card
	var card_instance : BattleCard = get_card_instance(card)
	if not card_instance.signals_on_click or card.energy_cost > energy_limit:
		card_instance.glow_not()
	else:
		card_instance.glow_on()
	_focused_card_parent_index = card_instance.get_position_in_parent()
	_focused_card_scale = focused_card.prs.scale
	move_child(card_instance, get_child_count())
	var new_prs : PRSData = card.prs.duplicate()
	new_prs.scale = scale_focused_card
	move_card(card, new_prs, get_focus_time())
	emit_signal("focused_on_card", card)

func focus_off_card(card:CardData):
	var card_instance : BattleCard = get_card_instance(card)
	card_instance.glow_off()
	if focused_card == card:
		focused_card = null
		move_child(card_instance, _focused_card_parent_index)
		_focused_card_parent_index = null
		var new_prs : PRSData = card.prs.duplicate()
		new_prs.scale = _focused_card_scale
		move_card(card, new_prs,  get_focus_time())
		_focused_card_scale = null
	emit_signal("focused_off_card", card)

func _on_Card_mouse_entered(card_data:CardData):
	focus_on_card(card_data)

func _on_Card_mouse_exited(card_data:CardData):
	focus_off_card(card_data)

func _on_Card_mouse_clicked(card_data:CardData):
	if card_data.energy_cost > energy_limit:
		return
	dragged_card = card_data
	emit_signal("dragging_card", card_data)

func _on_Card_mouse_released(card_data:CardData):
	if dragged_card != card_data:
		return
	dragged_card = null
	emit_signal("dropping_card", card_data)
