extends Object


class_name EffectCalculator

const ATTACK_EFFECT = 'ATTACK'
const DEFEND_EFFECT = 'DEFEND'
const PARRY_EFFECT = 'PARRY'
const EXHAUST_EFFECT = 'EXHAUST'
const RETAIN_EFFECT = 'RETAIN'
const INNATE_EFFECT = 'INNATE'
const DRAW_CARD_EFFECT = 'DRAW_CARD'
const UNPLAYABLE_EFFECT = 'UNPLAYABLE'
const MOMENTARY_EFFECT = 'MOMENTARY'
const SHIELD_ATTACK_EFFECT = 'SHIELD_ATTACK'
const SMASH_ATTACK_EFFECT = 'SMASH_ATTACK'
const MARKED_DAMAGE_EFFECT = 'MARKED_DAMAGE'
const DOUBLE_MARKED_EFFECT = 'DOUBLE_MARKED'
const DEFEND_TO_BARRICADED = 'DEFEND_TO_BARRICADED'
const HALF_DEFEND_TO_BARRICADED = 'HALF_DEFEND_TO_BARRICADED'
const CURE_POISONED_EFFECT = 'CURE_POISONED'
const CURE_VULNERABLE_EFFECT = 'CURE_VULNERABLE'
const CURE_WEAK_EFFECT = 'CURE_WEAK'
const CURE_FRAGILE_EFFECT = 'CURE_FRAGILE'
const CURE_MARKED_EFFECT = 'CURE_MARKED'
const ADD_ATTACK_EFFECT = 'ADD_ATTACK'
const ADD_DEFEND_EFFECT = 'ADD_DEFEND'
const ADD_SKILL_EFFECT = 'ADD_SKILL'
const PLAY_AS_DEFEND_EFFECT = 'PLAY_AS_DEFEND'
const PLAY_AS_ATTACK_EFFECT = 'PLAY_AS_ATTACK'
const PLAY_AS_SKILL_EFFECT = 'PLAY_AS_SKILL'
const ATTACK_UP_STATUS = 'ATTACK_UP'
const DEFENSE_UP_STATUS = 'DEFENSE_UP'
const STRONG_STATUS = 'STRONG'
const WEAK_STATUS = 'WEAK'
const FRAGILE_STATUS = 'FRAGILE'
const DURABLE_STATUS = 'DURABLE'
const VULNERABLE_STATUS = 'VULNERABLE'
const DEFENSE_STATUS = 'DEFENSE'
const REBOUNDING_STATUS = 'REBOUNDING'
const CHARGED_STATUS = 'CHARGED'
const COUNTERING_STATUS = 'COUNTERING'
const POISONED_STATUS = 'POISONED'
const BARRICADED_STATUS = 'BARRICADED'
const VENOMOUS_STATUS = 'VENOMOUS'
const PLANNED_STATUS = 'PLANNED'
const FOCUSED_STATUS = 'FOCUSED'
const FORTIFIED_STATUS = 'FORTIFIED'
const REINFORCED_STATUS = 'REINFORCED'
const MARKED_STATUS = 'MARKED'
const MARKING_STATUS = 'MARKING'
const PARRIED_STATUS = 'PARRIED'
const RIPOSTE_STATUS = 'RIPOSTE'
const ENGAGED_STATUS = 'ENGAGED'
const ENGAGING_STATUS = 'ENGAGING'
const HASTENED_STATUS = 'HASTENED'
const GAIN_ENERGY_EFFECT = 'GAIN_ENERGY'
const LOSE_ENERGY_EFFECT = 'LOSE_ENERGY'
const HEALTH_STATUS = 'HEALTH'
const ENERGY_STATUS = 'ENERGY'
const MOD_UP_RATIO = 1.500
const MOD_DOWN_RATIO = 0.667

static func _get_source_status_types(type_tag:String):
	match(type_tag):
		ATTACK_EFFECT, PARRY_EFFECT, SMASH_ATTACK_EFFECT:
			return [ATTACK_UP_STATUS, STRONG_STATUS, WEAK_STATUS]
		DEFEND_EFFECT:
			return [DEFENSE_UP_STATUS, DURABLE_STATUS, FRAGILE_STATUS]
		_:
			return []

static func _get_target_status_types(type_tag:String):
	match(type_tag):
		ATTACK_EFFECT, PARRY_EFFECT, SMASH_ATTACK_EFFECT:
			return [VULNERABLE_STATUS]
		_:
			return []

static func _get_value_modified(value:float, modifier_type:String, modifier_value):
	match(modifier_type):
		STRONG_STATUS, VULNERABLE_STATUS, DURABLE_STATUS:
			return value * MOD_UP_RATIO
		ATTACK_UP_STATUS, DEFENSE_UP_STATUS:
			return (value + modifier_value)
		WEAK_STATUS, FRAGILE_STATUS:
			return value * MOD_DOWN_RATIO
	return value

static func _mod_effect_total_by_statuses(total : float, status_types : Array, statuses : Array):
	for status_type in status_types:
		for status in statuses:
			if status is StatusData and status.type_tag == status_type:
				total = _get_value_modified(total, status_type, status.get_stack_value())
	return total

static func get_effect_total(base_value:int, type_tag:String, source_statuses:Array, target_statuses=null):
	var total = float(base_value)
	var source_status_types = _get_source_status_types(type_tag)
	total = _mod_effect_total_by_statuses(total, source_status_types, source_statuses)
	if target_statuses != null:
		var target_status_types = _get_target_status_types(type_tag)
		total = _mod_effect_total_by_statuses(total, target_status_types, target_statuses)
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
