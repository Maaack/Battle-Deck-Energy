extends Resource


class_name CardData

export(String) var title : String = 'CardData'
export(String, MULTILINE) var description : String = ''
export(int, 0, 9) var energy_cost : int = 1
export(Array, Resource) var effects : Array = []
export(String) var type_tag : String = 'TYPE'
var transform_data : TransformData = TransformData.new()

func _to_string():
	return "%s:%d" % [title, get_instance_id()]

func has_effect(type_tag:String):
	for battle_effect in effects:
		if battle_effect is EffectData:
			if battle_effect.type_tag == type_tag:
				return true
	return false

func get_effect(type_tag:String):
	for battle_effect in effects:
		if battle_effect is EffectData:
			if battle_effect.type_tag == type_tag:
				return battle_effect
