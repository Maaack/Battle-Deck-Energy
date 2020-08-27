extends Resource


class_name CardData

export(String) var title : String = 'CardData'
export(String, MULTILINE) var description : String = ''
export(int, 0, 9) var energy_cost : int = 1
export(Array, Resource) var battle_effects : Array = []
export(String) var type_tag : String = 'TYPE'
var prs : PRSData = PRSData.new()

func _to_string():
	return "%s:%d" % [title, get_instance_id()]
