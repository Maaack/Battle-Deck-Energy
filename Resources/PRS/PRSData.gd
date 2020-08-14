extends Resource


class_name PRSData

var position : Vector2 = Vector2()
var rotation : float = 0.0
var scale : Vector2 = Vector2(1.0, 1.0)

func duplicate(deep:bool = false):
	var duplicate = .duplicate(deep)
	duplicate.position = position
	duplicate.rotation = rotation
	duplicate.scale = scale
	return duplicate

func _to_string():
	return "%s, %.2f, %s" % [position, rotation, scale]

func is_equal(value):
	return position == value.position and rotation == value.rotation and scale == value.scale
