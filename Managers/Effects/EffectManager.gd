extends Node


signal damage_character(character, damage)

const ATTACK_EFFECT = 'ATTACK'
const DEFEND_EFFECT = 'DEFEND'
const PARRY_EFFECT = 'PARRY'
const TARGET_APPLY_ENERGY_EFFECT = 'TARGET_APPLY_ENERGY'
const TARGET_APPLY_STATUS = 'TARGET_APPLY_STATUS'
const EXHAUST_EFFECT = 'EXHAUST'
const RETAIN_EFFECT = 'RETAIN'
const INNATE_EFFECT = 'INNATE'

func _resolve_damage(effect_map:Dictionary):
	var attack : int = 0
	var defend : int = 0
	for effect in effect_map:
		match(effect):
			ATTACK_EFFECT:
				attack += effect_map[effect]
			PARRY_EFFECT:
				defend += effect_map[effect]
			DEFEND_EFFECT:
				defend += effect_map[effect]
	var total_damage = max(attack - defend, 0)
	return total_damage

func resolve_effects(character:CharacterData, effect_map:Dictionary):
	var total_damage = _resolve_damage(effect_map)
	if total_damage > 0:
		emit_signal("damage_character", character, total_damage)

func _resolve_opportunity_effect_target(opportunity:OpportunityData, effect:BattleEffect):
	# Temporary method to deal with not having self-targetted opportunities.
	match(effect.effect_type):
		PARRY_EFFECT:
			return opportunity.source
		DEFEND_EFFECT:
			return opportunity.source
	return opportunity.target

func get_target_effects(opportunities:Array):
	var target_effects : Dictionary = {}
	for opportunity in opportunities:
		if opportunity is OpportunityData and is_instance_valid(opportunity.card_data):
			for battle_effect in opportunity.card_data.battle_effects:
				var final_target = _resolve_opportunity_effect_target(opportunity, battle_effect)
				if not final_target in target_effects:
					target_effects[final_target] = {}
				if not battle_effect.effect_type in target_effects[final_target]:
					target_effects[final_target][battle_effect.effect_type] = 0
				target_effects[final_target][battle_effect.effect_type] += battle_effect.effect_quantity
	return target_effects

func include_innate_cards(cards:Array):
	var innate_cards : Array = []
	for card in cards:
		if card is CardData and card.has_effect(INNATE_EFFECT):
			innate_cards.append(card)
	return innate_cards

func exclude_retained_cards(cards:Array):
	var not_retained_cards : Array = []
	for card in cards:
		if card is CardData and not card.has_effect(RETAIN_EFFECT):
			not_retained_cards.append(card)
	return not_retained_cards
