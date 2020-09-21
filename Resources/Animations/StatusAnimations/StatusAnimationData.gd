extends AnimationData


class_name StatusAnimationData

var status_data : StatusData
var character_data : CharacterData
var delta : int

func _to_string():
	return "%s c:%s d:%d wt:%f at:%d" % [status_data, character_data, delta, wait_time, animation_type]
