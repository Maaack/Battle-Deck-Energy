extends Resource


class_name PRSData

const DEFAULT_POSITION : Vector2 = Vector2()
const DEFAULT_ROTATION : float = 0.0
const DEFAULT_SCALE : Vector2 = Vector2(1.0, 1.0)

var position : Vector2 = DEFAULT_POSITION
var rotation : float = DEFAULT_ROTATION
var scale : Vector2 = DEFAULT_SCALE

func duplicate(deep:bool = false):
	var duplicate = .duplicate(deep)
	duplicate.position = position
	duplicate.rotation = rotation
	duplicate.scale = scale
	return duplicate

func _to_string():
	return "%s, %.2f, %s" % [position, rotation, scale]

func _init(init_position:Vector2 = DEFAULT_POSITION, init_rotation:float = DEFAULT_ROTATION, init_scale : Vector2 = DEFAULT_SCALE):
	position = init_position
	rotation = init_rotation
	scale = init_scale

func is_equal(value):
	return position == value.position and rotation == value.rotation and scale == value.scale
