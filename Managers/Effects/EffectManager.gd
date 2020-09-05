extends Node


signal damage_character(character, damage)
signal modify_character(character, status)

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

func _get_effect_total(opportunity:OpportunityData, effect:BattleEffect, character_modifier_map:Dictionary):
	var total = effect.effect_quantity
	var effect_type = effect.effect_type
	var source_modifier_value = _get_modifier_value(opportunity.source, effect_type, character_modifier_map)
	total = _get_value_modified(total, effect_type, source_modifier_value)
	var target_effect_type = _get_target_modifier_tag(effect_type)
	if target_effect_type != null:
		var target_modifier_value = _get_modifier_value(opportunity.target, target_effect_type, character_modifier_map)
		if target_modifier_value != 0:
			total = _get_value_modified(total, target_effect_type, target_modifier_value)
	return total

func _resolve_damage(opportunities:Array, character_modifier_map:Dictionary):
	var attack_map : Dictionary = {}
	var defend_map : Dictionary = {}
	for opportunity in opportunities:
		if opportunity is OpportunityData and is_instance_valid(opportunity.card_data):
			for effect in opportunity.card_data.battle_effects:
				var final_target = _resolve_opportunity_effect_target(opportunity, effect)
				var final_value = _get_effect_total(opportunity, effect, character_modifier_map)
				if not final_target in attack_map or not final_target in defend_map:
					attack_map[final_target] = 0
					defend_map[final_target] = 0
				if effect is BattleEffect:
					match(effect.effect_type):
						ATTACK_EFFECT:
							attack_map[final_target] += final_value
						DEFEND_EFFECT:
							defend_map[final_target] += final_value
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
