extends Node


signal apply_damage(character, damage)
signal apply_status(character, status)
signal apply_energy(character, energy)
signal add_opportunity(source, target)

const ATTACK_EFFECT = 'ATTACK'
const DEFEND_EFFECT = 'DEFEND'
const PARRY_EFFECT = 'PARRY'
const RICOCHET_EFFECT = 'RICOCHET'
const EXHAUST_EFFECT = 'EXHAUST'
const RETAIN_EFFECT = 'RETAIN'
const INNATE_EFFECT = 'INNATE'
const VULNERABLE_STATUS = 'VULNERABLE'
const TARGET_APPLY_ENERGY_EFFECT = 'TARGET_APPLY_ENERGY'

var effect_calculator = preload("res://Managers/Effects/EffectCalculator.gd")

func _resolve_opportunity_effect_target(opportunity:OpportunityData, effect:BattleEffect):
	if effect.is_aimed_at_target():
		return opportunity.target
	else: 
		return opportunity.source

func _resolve_damage(opportunities:Array, character_modifier_map:Dictionary):
	var attack_map : Dictionary = {}
	var defend_map : Dictionary = {}
	for opportunity in opportunities:
		if opportunity is OpportunityData and is_instance_valid(opportunity.card_data):
			for effect in opportunity.card_data.battle_effects:
				var final_target = _resolve_opportunity_effect_target(opportunity, effect)
				var final_value = effect_calculator.get_effect_total(effect, character_modifier_map, opportunity.source, opportunity.target)
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
			emit_signal("apply_damage", target, total_damage)

func _resolve_status_changes(opportunities:Array, character_modifier_map:Dictionary):
	for opportunity in opportunities:
		if opportunity is OpportunityData and is_instance_valid(opportunity.card_data):
			for effect in opportunity.card_data.battle_effects:
				if effect is BattleStatusEffect:
					var final_target = _resolve_opportunity_effect_target(opportunity, effect)
					for status in effect.statuses:
						emit_signal("apply_status", final_target, status)
				
func resolve_opportunities(opportunities:Array, character_modifier_map:Dictionary):
	_resolve_damage(opportunities, character_modifier_map)
	_resolve_status_changes(opportunities, character_modifier_map)

func resolve_immediate_opportunity(opportunity:OpportunityData, opponents:Array):
	if opportunity.card_data == null:
		return
	for effect in opportunity.card_data.battle_effects:
		if effect is BattleEffect and effect.is_immediate():
			match(effect.effect_type):
				PARRY_EFFECT:
					emit_signal("add_opportunity", opportunity.source, opportunity.target)
				RICOCHET_EFFECT:
					for opponent in opponents:
						if opponent != opportunity.target:
							emit_signal("add_opportunity", opportunity.source, opponent)
				TARGET_APPLY_ENERGY_EFFECT:
					emit_signal("apply_energy", opportunity.target, effect.effect_quantity)
			if effect is BattleStatusEffect:
				for status in effect.statuses:
					emit_signal("apply_status", opportunity.target, status)

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
