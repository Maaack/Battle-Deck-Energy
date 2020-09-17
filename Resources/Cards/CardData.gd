extends Resource


class_name CardData

export(String) var title : String = 'CardData'
export(String, MULTILINE) var description : String = ''
export(int, 0, 9) var energy_cost : int = 1
export(Array, Resource) var battle_effects : Array = []
export(String) var type_tag : String = 'TYPE'
var transform_data : TransformData = TransformData.new()

func _to_string():
	return "%s:%d" % [title, get_instance_id()]

func has_effect(effect_type:String):
	for battle_effect in battle_effects:
		if battle_effect is BattleEffect:
			if battle_effect.effect_type == effect_type:
				return true
	return false

func get_effect(effect_type:String):
	for battle_effect in battle_effects:
		if battle_effect is BattleEffect:
			if battle_effect.effect_type == effect_type:
				return battle_effect
