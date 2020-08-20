extends Node


signal animation_started(animation_data)
signal queue_empty

onready var timer_node = $Timer

export(float, 0.0, 16.0) var default_tween_time : float = 0.5
export(float, 0.0, 16.0) var default_wait_time : float = 0.25

var animation_queue : Array = []
var card_animation_map : Dictionary = {}

func get_tween_time():
	return default_tween_time

func get_wait_time():
	return default_wait_time

func animate_move(card_data:CardData, new_prs:PRSData, tween_time:float = get_tween_time(), wait_time:float = get_wait_time(), anim_type:int = 0):
	var animation_data : AnimationData
	if card_data in card_animation_map and anim_type == card_animation_map[card_data].animation_type:
		animation_data = card_animation_map[card_data]
	else:
		animation_data = AnimationData.new()
	animation_data.card_data = card_data
	animation_data.prs = new_prs.duplicate()
	animation_data.tween_time = tween_time
	animation_data.animation_type = anim_type
	animation_data.wait_time = wait_time
	card_animation_map[card_data] = animation_data
	if not animation_data in animation_queue:
		animation_queue.append(animation_data)
	_start_timer(0)

func _start_timer(wait_time:float = get_wait_time()):
	if timer_node.time_left > 0.0:
		return
	if wait_time == 0.0:
		wait_time = 0.001
	timer_node.wait_time = wait_time
	timer_node.start()

func _animate(animation_data:AnimationData):
	emit_signal('animation_started', animation_data)

func _animate_next():
	if animation_queue.size() == 0:
		emit_signal("queue_empty")
		return
	var next_animation : AnimationData = animation_queue.pop_front()
	_start_timer(next_animation.wait_time)
	_animate(next_animation)

func delay_timer(delay_time : float = 1.0):
	_start_timer(delay_time)

func _on_Timer_timeout():
	_animate_next()
