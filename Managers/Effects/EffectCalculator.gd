extends Object

const ATTACK_EFFECT = 'ATTACK'
const DEFEND_EFFECT = 'DEFEND'
const PARRY_EFFECT = 'PARRY'
const RICOCHET_EFFECT = 'RICOCHET'
const EXHAUST_EFFECT = 'EXHAUST'
const RETAIN_EFFECT = 'RETAIN'
const INNATE_EFFECT = 'INNATE'
const STRENGTH_STATUS = 'STRENGTH'
const ATTACK_UP_STATUS = 'ATTACK_UP'
const DEFENSE_UP_STATUS = 'DEFENSE_UP'
const WEAK_STATUS = 'WEAK'
const FRAGILE_STATUS = 'FRAGILE'
const FORTITUDE_STATUS = 'FORTITUDE'
const VULNERABLE_STATUS = 'VULNERABLE'
const DEFENSE_STATUS = 'DEFENSE'
const TARGET_APPLY_ENERGY_EFFECT = 'TARGET_APPLY_ENERGY'
const TARGET_IMMEDIATE_APPLY_ENERGY_EFFECT = 'TARGET_IMMEDIATE_APPLY_ENERGY'
const TARGET_IMMEDIATE_APPLY_STATUS = 'TARGET_IMMEDIATE_APPLY_STATUS'
const MOD_UP_RATIO = 1.500
const MOD_DOWN_RATIO = 0.667

static func _get_source_status_types(type_tag:String):
	match(type_tag):
		ATTACK_EFFECT:
			return [ATTACK_UP_STATUS, STRENGTH_STATUS, WEAK_STATUS]
		DEFEND_EFFECT:
			return [DEFENSE_UP_STATUS, FORTITUDE_STATUS, FRAGILE_STATUS]
		_:
			return []

static func _get_target_status_types(type_tag:String):
	match(type_tag):
		ATTACK_EFFECT:
			return [VULNERABLE_STATUS]
		_:
			return []

static func _get_value_modified(value:float, modifier_type:String, modifier_value):
	match(modifier_type):
		STRENGTH_STATUS, VULNERABLE_STATUS, FORTITUDE_STATUS:
			return value * MOD_UP_RATIO
		ATTACK_UP_STATUS, DEFENSE_UP_STATUS:
			return (value + modifier_value)
		WEAK_STATUS, FRAGILE_STATUS:
			return value * MOD_DOWN_RATIO
	return value

static func get_effect_total(base_value:int, type_tag:String, source_statuses:Array, target_statuses=null):
	var total = float(base_value)
	var source_status_types = _get_source_status_types(type_tag)
	for status_type in source_status_types:
		for status in source_statuses:
			if status is StatusData and status.type_tag == status_type:
				total = _get_value_modified(total, status_type, status.get_stack_value())
	if target_statuses != null:
		var target_status_types = _get_target_status_types(type_tag)
		for status_type in target_status_types:
			for status in target_statuses:
				if status is StatusData and status.type_tag == status_type:
					total = _get_value_modified(total, status_type, status.get_stack_value())
	return int(total)
