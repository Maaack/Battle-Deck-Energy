extends Resource


class_name PlayerData

export(String) var name : String

var unique_id : int
var character_data : CharacterData 

func _to_string():
	return '%s(%d)' % [name, get_instance_id()]
