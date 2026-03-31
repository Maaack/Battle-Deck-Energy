@tool
extends Node2D


class_name BaseCardNode2D

signal tween_completed(card_node_2d)
signal tween_started(card_node_2d)

@onready var body_node = $Card/Body

var _last_animation_type : int = 0
var tween_node : Tween
var target_transform : TransformData

func tween_to(new_transform:TransformData, tween_time:float = 0.0, animation_type:int = -1):
	if tween_node is Tween and tween_node.is_running():
		tween_node.stop()
	tween_node = create_tween()
	tween_started.emit(self)
	tween_node.tween_property(self, "position", new_transform.position, tween_time)
	tween_node.parallel().tween_property(self, "rotation", new_transform.rotation, tween_time)
	tween_node.parallel().tween_property(self, "scale", new_transform.scale, tween_time)
	_last_animation_type = animation_type
	target_transform = new_transform
	await tween_node.finished
	tween_completed.emit(self)

func _finish_tween():
	if tween_node and tween_node.is_running():
		position = target_transform.position
		rotation = target_transform.rotation
		scale = target_transform.scale

func _force_card_transform(transform:TransformData):
	position = transform.position
	rotation = transform.rotation
	scale = transform.scale
