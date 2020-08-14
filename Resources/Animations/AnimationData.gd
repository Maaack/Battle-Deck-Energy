extends Resource


class_name AnimationData

var card_data : CardData
var prs : PRSData
var tween_time : float = 1.0
var wait_time : float = 0.5
var animation_type : int = -1

func _to_string():
	return "%s prs:%s tt:%f wt:%f at:%d" % [card_data, prs, tween_time, wait_time, animation_type]
