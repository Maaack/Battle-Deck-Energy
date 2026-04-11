extends Resource


class_name CardData

enum CardType{NONE, ATTACK, DEFEND, SKILL, STRESS}

@export var title: String = 'CardData'
@export_multiline var description : String = '' # (String, MULTILINE)
@export var energy_cost : int = 1 # (int, 0, 9)
@export var icon: Texture2D
@export var base_color: Color
@export var effects : Array = [] # (Array, Resource)
@export var type: CardType = CardType.ATTACK

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
