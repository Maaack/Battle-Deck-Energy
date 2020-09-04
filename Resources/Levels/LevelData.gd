extends Resource


class_name LevelData

export(Array, String) var tags : Array = []
export(Array, Resource) var opponents : Array = []

func _to_string():
	return str(tags)
