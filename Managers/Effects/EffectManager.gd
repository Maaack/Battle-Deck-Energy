extends Node


signal damage_character(character, damage)
signal modify_character(character, status)

const ATTACK_EFFECT = 'ATTACK'
const DEFEND_EFFECT = 'DEFEND'
const PARRY_EFFECT = 'PARRY'
const RICOCHET_EFFECT = 'RICOCHET'
const VULNERABILITY_EFFECT = 'VULNERABILITY'
const TARGET_APPLY_ENERGY_EFFECT = 'TARGET_APPLY_ENERGY'
const TARGET_IMMEDIATE_APPLY_ENERGY_EFFECT = 'TARGET_IMMEDIATE_APPLY_ENERGY'
const TARGET_APPLY_STATUS = 'TARGET_APPLY_STATUS'
const TARGET_IMMEDIATE_APPLY_STATUS = 'TARGET_IMMEDIATE_APPLY_STATUS'
const EXHAUST_EFFECT = 'EXHAUST'
const RETAIN_EFFECT = 'RETAIN'
const INNATE_EFFECT = 'INNATE'

func _resolve_opportunity_effect_target(opportunity:OpportunityData, effect:BattleEffect):
	# Temporary method to deal with not having self-targetted opportunities.
	# Update: Still temporary, effects need distinction between source and target blocking.
	match(effect.effect_type):
		PARRY_EFFECT:
			return opportunity.source
		DEFEND_EFFECT:
			return opportunity.source
	return opportunity.target

func _get_target_modifier_tag(type_tag:String):
	match(type_tag):
		ATTACK_EFFECT:
			return VULNERABILITY_EFFECT

func _get_opportunity_source_modifier(opportunity:OpportunityData, effect:BattleEffect, character_modifier_map:Dictionary):
	if not opportunity.source in character_modifier_map:
		return 0
	if not effect.effect_type in character_modifier_map[opportunity.source]:
		return 0
	return character_modifier_map[opportunity.source][effect.effect_type]

func _get_opportunity_target_modifier(opportunity:OpportunityData, effect:BattleEffect, character_modifier_map:Dictionary):
	var effect_type = _get_target_modifier_tag(effect.effect_type)
	if effect_type == null:
		return 0
	if not opportunity.target in character_modifier_map:
		return 0
	if not effect_type in character_modifier_map[opportunity.target]:
		return 0
	return character_modifier_map[opportunity.target][effect_type]

func _resolve_damage(opportunities:Array, character_modifier_map:Dictionary):
	var attack_map : Dictionary = {}
	var defend_map : Dictionary = {}
	for opportunity in opportunities:
		if opportunity is OpportunityData and is_instance_valid(opportunity.card_data):
			for effect in opportunity.card_data.battle_effects:
				var final_target = _resolve_opportunity_effect_target(opportunity, effect)
				var source_modifier = _get_opportunity_source_modifier(opportunity, effect, character_modifier_map)
				var target_modifier = _get_opportunity_target_modifier(opportunity, effect, character_modifier_map)
				if not final_target in attack_map or not final_target in defend_map:
					attack_map[final_target] = 0
					defend_map[final_target] = 0
				if effect is BattleEffect:
					match(effect.effect_type):
						ATTACK_EFFECT:
							attack_map[final_target] += effect.effect_quantity + source_modifier + target_modifier
						DEFEND_EFFECT:
							defend_map[final_target] += effect.effect_quantity + source_modifier + target_modifier
	for target in attack_map:
		var attack = attack_map[target]
		var defend = defend_map[target]
		var total_damage = max(attack - defend, 0)
		if total_damage > 0:
			emit_signal("damage_character", target, total_damage)

func _resolve_status_changes(opportunities:Array, character_modifier_map:Dictionary):
	for opportunity in opportunities:
		if opportunity is OpportunityData and is_instance_valid(opportunity.card_data):
			for effect in opportunity.card_data.battle_effects:
				if effect is BattleStatusEffect:
					var final_target = _resolve_opportunity_effect_target(opportunity, effect)
					for status in effect.statuses:
						emit_signal("modify_character", final_target, status)
				
func resolve_opportunities(opportunities:Array, character_modifier_map:Dictionary):
	_resolve_damage(opportunities, character_modifier_map)
	_resolve_status_changes(opportunities, character_modifier_map)

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
