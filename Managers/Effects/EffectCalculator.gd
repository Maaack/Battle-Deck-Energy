extends Object


class_name EffectCalculator

const ATTACK_EFFECT = 'ATTACK'
const DEFEND_EFFECT = 'DEFEND'
const PARRY_EFFECT = 'PARRY'
const RICOCHET_EFFECT = 'RICOCHET'
const OPENER_EFFECT = 'OPENER'
const EXHAUST_EFFECT = 'EXHAUST'
const RETAIN_EFFECT = 'RETAIN'
const INNATE_EFFECT = 'INNATE'
const DRAW_CARD_EFFECT = 'DRAW_CARD'
const UNPLAYABLE_EFFECT = 'UNPLAYABLE'
const FORTIFY_EFFECT = 'FORTIFY'
const FOCUS_EFFECT = 'FOCUS'
const MOMENTARY_EFFECT = 'MOMENTARY'
const PLAY_AS_DEFEND_EFFECT = 'PLAY_AS_DEFEND'
const PLAY_AS_ATTACK_EFFECT = 'PLAY_AS_ATTACK'
const PLAY_AS_SKILL_EFFECT = 'PLAY_AS_SKILL'
const STRENGTH_STATUS = 'STRENGTH'
const ATTACK_UP_STATUS = 'ATTACK_UP'
const DEFENSE_UP_STATUS = 'DEFENSE_UP'
const WEAK_STATUS = 'WEAK'
const FRAGILE_STATUS = 'FRAGILE'
const FORTITUDE_STATUS = 'FORTITUDE'
const VULNERABLE_STATUS = 'VULNERABLE'
const DEFENSE_STATUS = 'DEFENSE'
const TOXIN_STATUS = 'TOXIN'
const EN_GARDE_STATUS = 'EN_GARDE'
const VENOMOUS_STATUS = 'VENOMOUS'
const TARGET_APPLY_ENERGY_EFFECT = 'TARGET_APPLY_ENERGY'
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

static func get_playable_types(card_data:CardData):
	var playable_types : Array = []
	playable_types.append(card_data.type)
	if card_data.has_effect(PLAY_AS_DEFEND_EFFECT):
		playable_types.append(CardData.CardType.DEFEND)
	if card_data.has_effect(PLAY_AS_ATTACK_EFFECT):
		playable_types.append(CardData.CardType.ATTACK)
	if card_data.has_effect(PLAY_AS_SKILL_EFFECT):
		playable_types.append(CardData.CardType.SKILL)
	return playable_types
