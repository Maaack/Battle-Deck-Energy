extends Object

const ATTACK_EFFECT = 'ATTACK'
const DEFEND_EFFECT = 'DEFEND'
const PARRY_EFFECT = 'PARRY'
const RICOCHET_EFFECT = 'RICOCHET'
const EXHAUST_EFFECT = 'EXHAUST'
const RETAIN_EFFECT = 'RETAIN'
const INNATE_EFFECT = 'INNATE'
const VULNERABLE_STATUS = 'VULNERABLE'
const TARGET_APPLY_ENERGY_EFFECT = 'TARGET_APPLY_ENERGY'
const TARGET_IMMEDIATE_APPLY_ENERGY_EFFECT = 'TARGET_IMMEDIATE_APPLY_ENERGY'
const TARGET_IMMEDIATE_APPLY_STATUS = 'TARGET_IMMEDIATE_APPLY_STATUS'


func _get_target_modifier_tag(type_tag:String):
	match(type_tag):
		ATTACK_EFFECT:
			return VULNERABLE_STATUS

func _get_value_modified(value:int, effect_type:String, modifier_value):
	match(effect_type):
		VULNERABLE_STATUS:
			return int(value * 1.5)
		_:
			return (value + modifier_value)
	return value

func _get_modifier_value(character:CharacterData, effect_type:String, character_modifier_map:Dictionary):
	if not character in character_modifier_map:
		return 0
	if not effect_type in character_modifier_map[character]:
		return 0
	return character_modifier_map[character][effect_type]

func get_effect_total(effect:BattleEffect, character_modifier_map:Dictionary, source:CharacterData, target=null):
	var total = effect.effect_quantity
	var effect_type = effect.effect_type
	var source_modifier_value = _get_modifier_value(source, effect_type, character_modifier_map)
	total = _get_value_modified(total, effect_type, source_modifier_value)
	if target != null:
		var target_effect_type = _get_target_modifier_tag(effect_type)
		if target_effect_type != null:
			var target_modifier_value = _get_modifier_value(target, target_effect_type, character_modifier_map)
			if target_modifier_value != 0:
				total = _get_value_modified(total, target_effect_type, target_modifier_value)
	return total
