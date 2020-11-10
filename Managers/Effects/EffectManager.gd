extends Node

signal apply_health(character, health)
signal apply_status(character, status, origin)
signal apply_energy(character, energy)
signal add_opportunity(type, source, target)
signal add_card_to_hand(card, character)
signal add_card_to_draw_pile(card, character)
signal add_card_to_discard_pile(card, character)
signal draw_from_draw_pile(character, count)

var effect_calculator = preload("res://Managers/Effects/EffectCalculator.gd")
var toxin_effect_resource = preload("res://Resources/Statuses/Toxin.tres")

func _resolve_opportunity_effect_target(opportunity:OpportunityData, effect:EffectData):
	if effect.is_aimed_at_target():
		return opportunity.target
	else: 
		return opportunity.source

func _get_character_statuses(character:CharacterData, character_manager_map:Dictionary):
	if not character in character_manager_map:
		return []
	var character_manager : NewCharacterBattleManager = character_manager_map[character]
	return character_manager.get_statuses()

func _resolve_damage(effect:EffectData, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var source_statuses = _get_character_statuses(source, character_manager_map)
	var target_statuses = _get_character_statuses(target, character_manager_map)
	var total_damage = effect_calculator.get_effect_total(effect.amount, effect.type_tag, source_statuses, target_statuses)
	emit_signal("apply_health", target, -(total_damage))
	var source_battle_manager : NewCharacterBattleManager = character_manager_map[source]
	var target_battle_manager : NewCharacterBattleManager = character_manager_map[target]
	if source_battle_manager:
		var venomous_status : StatusData = source_battle_manager.get_status_by_type(EffectCalculator.VENOMOUS_STATUS)
		if venomous_status:
			var toxin_status : StatusData = toxin_effect_resource.duplicate()
			toxin_status.intensity = venomous_status.intensity
			toxin_status.duration = venomous_status.duration
			target_battle_manager.gain_status(toxin_status, source)

func _resolve_self_damage(effect:EffectData, target:CharacterData, character_manager_map:Dictionary):
	var target_statuses = _get_character_statuses(target, character_manager_map)
	var total_damage = effect_calculator.get_effect_total(effect.amount, effect.type_tag, [], target_statuses)
	emit_signal("apply_health", target, -(total_damage))

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
		status_quantity *= effect.amount
		status_quantity = effect_calculator.get_effect_total(status_quantity, effect.type_tag, source_statuses, target_statuses)
		if modified_status.stacks_the_d():
			modified_status.duration = status_quantity
		else:
			modified_status.intensity = status_quantity
		emit_signal("apply_status", target, modified_status, source)

func _resolve_deck_mod(effect:DeckModEffectData, character:CharacterData):
	var new_card = effect.card.duplicate()
	match(effect.destination):
		DeckModEffectData.DestinationMode.HAND:
			emit_signal("add_card_to_hand", new_card, character)
		DeckModEffectData.DestinationMode.DRAW:
			emit_signal("add_card_to_draw_pile", new_card, character)
		DeckModEffectData.DestinationMode.DISCARD:
			emit_signal("add_card_to_discard_pile", new_card, character)

func _resolve_self_effects(effect:EffectData, character:CharacterData, character_manager_map:Dictionary):
	match(effect.type_tag):
		EffectCalculator.ATTACK_EFFECT:
			_resolve_self_damage(effect, character, character_manager_map)
		EffectCalculator.DRAW_CARD_EFFECT:
			emit_signal("draw_from_draw_pile", character, effect.amount)
		EffectCalculator.GAIN_ENERGY_EFFECT:
			emit_signal("apply_energy", character, effect.amount)
		EffectCalculator.LOSE_ENERGY_EFFECT:
			emit_signal("apply_energy", character, -(effect.amount))
	if effect is StatusEffectData:
		_resolve_statuses(effect, character, character, character_manager_map)
	if effect is DeckModEffectData:
		_resolve_deck_mod(effect, character)

func resolve_on_draw(card:CardData, character:CharacterData, character_manager_map:Dictionary):
	for effect in card.effects:
		if effect is EffectData:
			if not effect.applies_on_draw():
				continue
			_resolve_self_effects(effect, character, character_manager_map)

func resolve_on_discard(card:CardData, character:CharacterData, character_manager_map:Dictionary):
	for effect in card.effects:
		if effect is EffectData:
			if not effect.applies_on_discard():
				continue
			_resolve_self_effects(effect, character, character_manager_map)

func resolve_on_play(card:CardData, character:CharacterData, character_manager_map:Dictionary):
	for effect in card.effects:
		if effect is EffectData:
			if not effect.applies_on_play():
				continue
			_resolve_self_effects(effect, character, character_manager_map)

func resolve_on_play_opportunity(card:CardData, opportunity:OpportunityData, character_manager_map:Dictionary):
	for effect in card.effects:
		if effect is EffectData:
			if not effect.applies_on_play():
				continue
			var final_target = _resolve_opportunity_effect_target(opportunity, effect)
			match(effect.type_tag):
				EffectCalculator.PARRY_EFFECT, EffectCalculator.OPENER_EFFECT:
					for _i in range(effect.amount):
						emit_signal("add_opportunity", CardData.CardType.ATTACK, opportunity.source, final_target)
				EffectCalculator.RICOCHET_EFFECT:
					for opponent in character_manager_map.keys():
						if opponent != final_target and opponent != opportunity.source:
							emit_signal("add_opportunity", CardData.CardType.ATTACK, opportunity.source, opponent)
				EffectCalculator.FORTIFY_EFFECT:
					for _i in range(effect.amount):
						emit_signal("add_opportunity", CardData.CardType.DEFEND, opportunity.source, final_target)
				EffectCalculator.FOCUS_EFFECT:
					for _i in range(effect.amount):
						emit_signal("add_opportunity", CardData.CardType.SKILL, opportunity.source, final_target)
				EffectCalculator.DRAW_CARD_EFFECT:
					emit_signal("draw_from_draw_pile", final_target, effect.amount)
				EffectCalculator.GAIN_ENERGY_EFFECT:
					emit_signal("apply_energy", final_target, effect.amount)
				EffectCalculator.LOSE_ENERGY_EFFECT:
					emit_signal("apply_energy", final_target, -(effect.amount))
				EffectCalculator.ATTACK_EFFECT:
					_resolve_damage(effect, opportunity.source, final_target, character_manager_map)
			if effect is StatusEffectData:
				_resolve_statuses(effect, opportunity.source, final_target, character_manager_map)
			if effect is DeckModEffectData:
				_resolve_deck_mod(effect, final_target)
