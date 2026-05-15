extends Node


class_name EventQueue

signal queue_empty
signal queue_timeout

@onready var timer_node = $Timer

@export var default_delay_time : float = 0.25 # (float, 0.0, 16.0)

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

func delay_timer(delay_time:float = default_delay_time):
	start_timer(delay_time)

func is_empty() -> bool:
	return event_queue.size() == 0

func get_true() -> bool:
	return true

func _dequeue() -> void:
	if is_empty():
		queue_empty.emit()
		return
	var current_event : EventData = event_queue.pop_front()
	if not current_event.start_condition.call():
		await current_event.start_signal
	current_event.callable.call()
	delay_timer(current_event.delay_time)

func queue(callable:Callable, delay_time:float = default_delay_time, start_condition:Callable = get_true, start_signal:Signal = queue_timeout, event_key:String = ""):
	var event_data : EventData
	if (not event_key.is_empty()) and event_key in event_data_map:
		event_data = event_data_map[event_key]
	else:
		event_data = EventData.new()
	event_data.callable = callable
	event_data.delay_time = delay_time
	event_data.start_condition = start_condition
	event_data.start_signal = start_signal
	if not event_key.is_empty():
		event_data_map[event_key] = event_data
	if event_data not in event_queue:
		event_queue.append(event_data)
	start_timer(0)

func _on_timer_timeout():
	queue_timeout.emit()
	_dequeue()
