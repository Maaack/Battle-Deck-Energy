extends Node


signal apply_damage(character, damage)
signal apply_status(character, status)
signal apply_energy(character, energy)
signal add_opportunity(source, target)

const ATTACK_EFFECT = 'ATTACK'
const DEFEND_EFFECT = 'DEFEND'
const PARRY_EFFECT = 'PARRY'
const OPENER_EFFECT = 'OPENER'
const RICOCHET_EFFECT = 'RICOCHET'
const FORTIFY_EFFECT = 'FORTIFY'
const EXHAUST_EFFECT = 'EXHAUST'
const RETAIN_EFFECT = 'RETAIN'
const INNATE_EFFECT = 'INNATE'
const VULNERABLE_STATUS = 'VULNERABLE'
const TARGET_APPLY_ENERGY_EFFECT = 'TARGET_APPLY_ENERGY'

var effect_calculator = preload("res://Managers/Effects/EffectCalculator.gd")

func _resolve_opportunity_effect_target(opportunity:OpportunityData, effect:EffectData):
	if effect.is_aimed_at_target():
		return opportunity.target
	else: 
		return opportunity.source

func _get_character_statuses(character:CharacterData, character_manager_map:Dictionary):
	if not character in character_manager_map:
		return []
	var character_manager : CharacterBattleManager = character_manager_map[character]
	return character_manager.get_statuses()

func _resolve_damage(effect:EffectData, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var source_statuses = _get_character_statuses(source, character_manager_map)
	var target_statuses = _get_character_statuses(target, character_manager_map)
	var total_damage = effect_calculator.get_effect_total(effect.effect_quantity, effect.effect_type, source_statuses, target_statuses)
	emit_signal("apply_damage", target, total_damage)

func _resolve_statuses(effect:StatusEffectData, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	for status in effect.statuses:
		var modified_status : StatusData = status.duplicate()
		var source_statuses = _get_character_statuses(source, character_manager_map)
		var target_statuses = _get_character_statuses(target, character_manager_map)
		var status_quantity : int
		if modified_status.stacks_the_d():
			status_quantity = modified_status.duration
		else:
			status_quantity = modified_status.intensity
		status_quantity *= effect.effect_quantity
		status_quantity = effect_calculator.get_effect_total(status_quantity, effect.effect_type, source_statuses, target_statuses)
		if modified_status.stacks_the_d():
			modified_status.duration = status_quantity
		else:
			modified_status.intensity = status_quantity
		emit_signal("apply_status", target, modified_status)

func resolve_opportunity(card:CardData, opportunity:OpportunityData, character_manager_map:Dictionary):
	for effect in card.battle_effects:
		if effect is EffectData and effect.is_immediate():
			var final_target = _resolve_opportunity_effect_target(opportunity, effect)
			match(effect.effect_type):
				PARRY_EFFECT, OPENER_EFFECT, FORTIFY_EFFECT:
					for _i in range(effect.effect_quantity):
						emit_signal("add_opportunity", opportunity.source, final_target)
				RICOCHET_EFFECT:
					for opponent in character_manager_map.keys():
						if opponent != final_target and opponent != opportunity.source:
							emit_signal("add_opportunity", opportunity.source, opponent)
				TARGET_APPLY_ENERGY_EFFECT:
					emit_signal("apply_energy", final_target, effect.effect_quantity)
				ATTACK_EFFECT:
					_resolve_damage(effect, opportunity.source, final_target, character_manager_map)
			if effect is StatusEffectData:
				_resolve_statuses(effect, opportunity.source, final_target, character_manager_map)

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
