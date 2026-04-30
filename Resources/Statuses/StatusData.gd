extends Resource


class_name StatusData

enum StackType{INTENSITY,DURATION,COMBINED}
enum StatusType{NONE, BUFF, CURSE, EARLY_BUFF, DELAYED_BUFF, LATE_BUFF, EARLY_CURSE, RELATED_CURSE}

const GOOD_TYPES : Array[StatusType] = [StatusType.BUFF, StatusType.DELAYED_BUFF, StatusType.LATE_BUFF]

@export var title: String = 'Status'
@export_multiline var description : String = 'Status description.' # (String, MULTILINE)
@export var icon: Texture2D
@export var color: Color = Color.WHITE
@export var intensity: int = 0
@export var duration: int = 0
@export var type_tag: String = 'TYPE'
@export var stack_type: StackType = StackType.INTENSITY
@export var status_type: StatusType = StatusType.BUFF

func _to_string():
	return "StatusData:%d[%s-%d]" % [get_instance_id(), title, get_stack_value()]

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
		duration += max(value, -(duration))
		return duration
	else:
		intensity += max(value, -(intensity))
		return intensity

func reset_stack():
	if stacks_the_d():
		duration = 0
	else:
		intensity = 0

func is_good() -> bool:
	return status_type in GOOD_TYPES

func is_bad() -> bool:
	return (not is_good())
