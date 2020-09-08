extends Object

const ATTACK_EFFECT = 'ATTACK'
const DEFEND_EFFECT = 'DEFEND'
const PARRY_EFFECT = 'PARRY'
const RICOCHET_EFFECT = 'RICOCHET'
const EXHAUST_EFFECT = 'EXHAUST'
const RETAIN_EFFECT = 'RETAIN'
const INNATE_EFFECT = 'INNATE'
const STRENGTH_STATUS = 'STRENGTH'
const WEAK_STATUS = 'WEAK'
const FRAGILE_STATUS = 'FRAGILE'
const VULNERABLE_STATUS = 'VULNERABLE'
const DEFENSE_STATUS = 'DEFENSE'
const TARGET_APPLY_ENERGY_EFFECT = 'TARGET_APPLY_ENERGY'
const TARGET_IMMEDIATE_APPLY_ENERGY_EFFECT = 'TARGET_IMMEDIATE_APPLY_ENERGY'
const TARGET_IMMEDIATE_APPLY_STATUS = 'TARGET_IMMEDIATE_APPLY_STATUS'
const MOD_UP_RATIO = 1.500
const MOD_DOWN_RATIO = 0.6666

static func _get_source_status_types(effect_type:String):
	match(effect_type):
		ATTACK_EFFECT:
			return [STRENGTH_STATUS, WEAK_STATUS]
		DEFEND_EFFECT:
			return [FRAGILE_STATUS]
		_:
			return []

static func _get_target_status_types(effect_type:String):
	match(effect_type):
		ATTACK_EFFECT:
			return [VULNERABLE_STATUS]
		_:
			return []

static func _get_value_modified(value:int, modifier_type:String, modifier_value):
	match(modifier_type):
		VULNERABLE_STATUS:
			return int(value * MOD_UP_RATIO)
		STRENGTH_STATUS:
			return (value + modifier_value)
		WEAK_STATUS, FRAGILE_STATUS:
			return int(value * MOD_DOWN_RATIO)
	return value

static func get_effect_total(base_value:int, effect_type:String, source_statuses:Array, target_statuses=null):
	var total = base_value
	var source_status_types = _get_source_status_types(effect_type)
	for status_type in source_status_types:
		for status in source_statuses:
			if status is StatusData and status.type_tag == status_type:
				total = _get_value_modified(total, status_type, status.intensity)
	if target_statuses != null:
		var target_status_types = _get_target_status_types(effect_type)
		for status_type in target_status_types:
			for status in target_statuses:
				if status is StatusData and status.type_tag == status_type:
					total = _get_value_modified(total, status_type, status.intensity)
	return total
