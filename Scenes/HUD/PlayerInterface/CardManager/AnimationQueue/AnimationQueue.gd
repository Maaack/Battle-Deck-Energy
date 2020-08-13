extends Node


signal animations_complete

onready var tween_node = $Tween
onready var timer_node = $Timer

enum AnimationType{DRAWING, DISCARDING, EXHAUSTING, NONE = -1}

export(float, 0.0, 16.0) var default_tween_time : float = 0.5
export(float, 0.0, 16.0) var default_wait_time : float = 0.25

var animation_queue : Array = []
var nodes_animation_map : Dictionary = {}

func animate_move(node:Node2D, new_prs:PRSData, anim_time:float = get_tween_time(), wait_time:float = get_wait_time(), anim_type:int = AnimationType.NONE):
	var animation_data = AnimationData.new()
	animation_data.node_instance = node
	animation_data.prs = new_prs.duplicate()
	animation_data.tween_time = anim_time
	animation_data.animation_type = anim_type
	animation_data.wait_time = wait_time
	animation_queue.append(animation_data)
	_start_timer(animation_data.wait_time)

func _start_timer(wait_time:float = get_wait_time()):
	if timer_node.time_left > 0.0:
		return
	timer_node.wait_time = wait_time
	timer_node.start()


func _animate(animation_data:AnimationData):
	var prs : PRSData = animation_data.prs
	var node2D : Node2D = animation_data.node_instance
	var tween_time : float = animation_data.tween_time
	tween_node.interpolate_property(node2D, "position", node2D.position, prs.position, tween_time)
	tween_node.interpolate_property(node2D, "rotation", node2D.rotation, prs.rotation, tween_time)
	tween_node.interpolate_property(node2D, "scale", node2D.scale, prs.scale, tween_time)
	tween_node.start()

func get_tween_time():
	return default_tween_time

func get_wait_time():
	return default_wait_time

func _animate_next():
	if animation_queue.size() == 0:
		return
	var next_animation : AnimationData = animation_queue.pop_front()
	if next_animation.node_instance in nodes_animation_map:
		yield(tween_node, "tween_all_completed")
	_animate(next_animation)
	nodes_animation_map[next_animation.node_instance] = next_animation.animation_type
	_start_timer(next_animation.wait_time)

func _on_Timer_timeout():
	_animate_next()

func _on_Tween_tween_all_completed():
	emit_signal("animations_complete")

func _on_Tween_tween_completed(object, key):
	if object in nodes_animation_map:
		nodes_animation_map.erase(object)
	
