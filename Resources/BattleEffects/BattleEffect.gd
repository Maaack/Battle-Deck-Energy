extends Resource


class_name BattleEffect

export(String) var effect_type : String = ''
export(Texture) var effect_icon : Texture
export(int) var effect_quantity : int = 0
export(Color) var effect_color : Color = Color()

func _to_string():
	return "BattleEffect:%d" % get_instance_id()
