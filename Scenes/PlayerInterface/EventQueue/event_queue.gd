extends Node


class_name EventQueue

signal queue_empty

@onready var timer_node = $Timer

@export var default_tween_time : float = 0.5 # (float, 0.0, 16.0)
@export var default_wait_time : float = 0.25 # (float, 0.0, 16.0)

var event_queue : Array[EventData]
var event_data_map : Dictionary[String,EventData]

func start_timer(wait_time:float = 0):
	if timer_node.time_left > 0.0:
		return
	if wait_time == 0.0:
		_dequeue()
		return
	timer_node.wait_time = wait_time
	timer_node.start()

func delay_timer(delay_time:float = default_wait_time):
	start_timer(delay_time)

func is_empty():
	return event_queue.size() == 0

func _dequeue():
	if is_empty():
		queue_empty.emit()
		return
	var current_event : EventData = event_queue.pop_front()
	current_event.callable.call()
	current_event.wait_callable.call()

func queue(callable:Callable, wait_callable:Callable = delay_timer.bind(0.2), event_key:String = ""):
	var event_data : EventData
	if (not event_key.is_empty()) and event_key in event_data_map:
		event_data = event_data_map[event_key]
	else:
		event_data = EventData.new()
	event_data.callable = callable
	event_data.wait_callable = wait_callable
	if not event_key.is_empty():
		event_data_map[event_key] = event_data
	if event_data not in event_queue:
		event_queue.append(event_data)
	start_timer(0)

func _on_timer_timeout():
	_dequeue()
