extends Node


class_name AnimationQueue

signal animation_started(animation_data)
signal queue_empty

onready var timer_node = $Timer

export(float, 0.0, 16.0) var default_tween_time : float = 0.5
export(float, 0.0, 16.0) var default_wait_time : float = 0.25

var animation_queue : Array = []

func get_tween_time():
	return default_tween_time

func get_wait_time():
	return default_wait_time

func _start_timer(wait_time:float = get_wait_time()):
	if timer_node.time_left > 0.0:
		return
	if wait_time == 0.0:
		wait_time = 0.001
	timer_node.wait_time = wait_time
	timer_node.start()

func _animate(animation_data:AnimationData):
	emit_signal('animation_started', animation_data)

func is_queue_empty():
	return animation_queue.size() == 0

func _animate_next():
	if is_queue_empty():
		emit_signal("queue_empty")
		return
	var next_animation : AnimationData = animation_queue.pop_front()
	_start_timer(next_animation.wait_time)
	_animate(next_animation)

func delay_timer(delay_time : float = 1.0):
	_start_timer(delay_time)

func _on_Timer_timeout():
	_animate_next()
