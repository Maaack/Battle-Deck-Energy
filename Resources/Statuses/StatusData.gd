extends Resource


class_name StatusData

enum StackType{INTENSITY,DURATION}

export(String) var title : String = 'Status'
export(String, MULTILINE) var description : String = 'Status description.'
export(Texture) var icon : Texture
export(Color) var color : Color = Color.white
export(int) var intensity : int = 0
export(int) var duration : int = 0
export(String) var type_tag : String = 'TYPE'
export(StackType) var stack_type = StackType.INTENSITY

func _to_string():
	return "StatusData:%d:%s" % [get_instance_id(), title]

func stacks_the_d():
	return stack_type == StackType.DURATION

func has_the_d():
	return duration > 0

func get_stack_value():
	if stacks_the_d():
		return duration
	else:
		return intensity

func set_stack_value(value:int):
	if stacks_the_d():
		duration = value
	else:
		intensity = value

func add_to_stack(value:int):
	if stacks_the_d():
		duration += value
		return duration
	else:
		intensity += value
		return intensity

func reset_stack():
	if stacks_the_d():
		duration = 0
	else:
		intensity = 0
