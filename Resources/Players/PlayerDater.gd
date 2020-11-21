extends Resource


class_name PlayerData

export(String) var name : String

func _to_string():
	return '%s(%d)' % [name, get_instance_id()]
