extends Resource


class_name StatusData

export(String) var title : String = 'Status'
export(String, MULTILINE) var description : String = 'Status description.'
export(Texture) var icon : Texture
export(int) var intensity : int = 0
export(int) var duration : int = 0
export(String) var type_tag : String = 'TYPE'

func _to_string():
	return "BattleEffect:%d" % get_instance_id()
