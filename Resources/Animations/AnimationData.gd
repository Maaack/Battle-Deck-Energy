extends Resource


class_name AnimationData

var wait_time : float = 0.5
var animation_type : int = -1

func _to_string():
	return "wt:%f at:%d" % [wait_time, animation_type]
