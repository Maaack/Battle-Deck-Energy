tool
extends Node2D


class_name BaseCardNode2D

signal tween_completed(card_node_2d)
signal tween_started(card_node_2d)

onready var tween_node = $Tween
onready var body_node = $Card/Body

var _last_animation_type : int = 0

func tween_to(new_transform:TransformData, tween_time:float = 0.0, animation_type:int = -1):
	if is_instance_valid(tween_node):
		if tween_node.is_active():
			if _last_animation_type != animation_type:
				tween_time += tween_node.get_runtime()
			else:
				tween_time = tween_node.get_runtime()
			tween_node.remove_all()
		tween_node.interpolate_property(self, "position", position, new_transform.position, tween_time)
		tween_node.interpolate_property(self, "rotation", rotation, new_transform.rotation, tween_time)
		tween_node.interpolate_property(self, "scale", scale, new_transform.scale, tween_time)
		tween_node.start()
	_last_animation_type = animation_type

func _finish_tween():
	if tween_node.is_active():
		tween_node.seek(tween_node.get_runtime())

func _force_card_transform(transform:TransformData):
	position = transform.position
	rotation = transform.rotation
	scale = transform.scale

func _on_Tween_tween_started(object, key):
	emit_signal("tween_started", self)

func _on_Tween_tween_all_completed():
	emit_signal("tween_completed", self)
