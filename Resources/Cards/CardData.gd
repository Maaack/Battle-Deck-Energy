extends Resource


class_name CardData

enum CardType{NONE, ATTACK, DEFEND, SKILL, STRESS}

@export var title: String = 'CardData'
@export_multiline var description : String = '' # (String, MULTILINE)
@export_range(0, 9) var energy_cost : int = 1 # (int, 0, 9)
@export var icon: Texture2D
@export var base_color: Color
@export var effects : Array[EffectData] 
@export var type: CardType = CardType.ATTACK

var transform_data : TransformData = TransformData.new()

static func get_card_type_string(card_type:CardType) -> String:
	match card_type:
		CardType.ATTACK:
			return "Attack"
		CardType.DEFEND:
			return "Defend"
		CardType.SKILL:
			return "Skill"
		CardType.STRESS:
			return "Stress"
		CardType.NONE:
			return "None"
		_:
			return "Unknown"

func get_card_type():
	return get_card_type_string(type)

func _to_string():
	if get_instance_id() > 0:
		return "%s:%d" % [title, get_instance_id()]
	return title

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
