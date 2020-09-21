extends AnimationData


class_name CardAnimationData

var card_data : CardData
var transform_data : TransformData
var tween_time : float = 1.0

func _to_string():
	return "%s transform:%s tt:%f wt:%f at:%d" % [card_data, transform_data, tween_time, wait_time, animation_type]
