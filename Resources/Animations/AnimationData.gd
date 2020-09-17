extends Resource


class_name AnimationData

var card_data : CardData
var transform_data : TransformData
var tween_time : float = 1.0
var wait_time : float = 0.5
var animation_type : int = -1

func _to_string():
	return "%s transform:%s tt:%f wt:%f at:%d" % [card_data, transform_data, tween_time, wait_time, animation_type]
