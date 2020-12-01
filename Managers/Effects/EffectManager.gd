extends Node


class_name EffectsManager

signal apply_health(character, health, source)
signal apply_status(character, status, origin)
signal apply_energy(character, energy, source)
signal add_opportunity(type, source, target)
signal add_card_to_hand(card, character)
signal add_card_to_draw_pile(card, character)
signal add_card_to_discard_pile(card, character)
signal spawn_card(card, character)
signal draw_from_draw_pile(character, count)

var effect_calculator = preload("res://Managers/Effects/EffectCalculator.gd")
var toxin_status_resource = preload("res://Resources/Statuses/Toxin.tres")
var riposte_status_resource = preload("res://Resources/Statuses/Riposte.tres")
var team_manager : TeamManager

func _resolve_opportunity_effect_targets(opportunity:OpportunityData, effect:EffectData):
	var targets : Array = []
	var primary_target : CharacterData
	if effect.is_aimed_at_target():
		primary_target = opportunity.target
	else:
		primary_target = opportunity.source
	if team_manager == null:
		print("Warning: EffectManager.team_manager is not set")
		return [primary_target]
	if effect.is_aimed_at_teammates():
		targets += team_manager.get_allies(primary_target)
	elif effect.is_aimed_at_entire_team():
		targets += team_manager.get_entire_team(primary_target)
	elif effect.is_aimed_at_enemies():
		targets += team_manager.get_enemies(primary_target)
	else:
		targets.append(primary_target)
	return targets

func _get_character_statuses(character:CharacterData, character_manager_map:Dictionary):
	if not character in character_manager_map:
		return []
	var character_manager : CharacterBattleManager = character_manager_map[character]
	return character_manager.get_statuses()

func _apply_damage(source_battle_manager : CharacterBattleManager, target_battle_manager : CharacterBattleManager, amount):
	var source = source_battle_manager.character_data
	var target = target_battle_manager.character_data
	var parry_status : StatusData = source_battle_manager.get_related_status(EffectCalculator.PARRIED_STATUS, target)
	if parry_status != null:
		var modified_status : StatusData = parry_status.duplicate()
		var parry_down = min(amount, modified_status.intensity)
		modified_status.intensity = -(parry_down)
		if modified_status.intensity != 0:
			var riposte_status = riposte_status_resource.duplicate()
			riposte_status.source = target
			riposte_status.target = source
			emit_signal("apply_status", target, riposte_status, target)
			emit_signal("apply_status", source, riposte_status, target)
			emit_signal("apply_status", source, modified_status, source)
		amount -= parry_down
	var defense_status : StatusData = target_battle_manager.get_status(EffectCalculator.DEFENSE_STATUS)
	if defense_status != null:
		var modified_status : StatusData = defense_status.duplicate()
		var defense_down = min(amount, modified_status.intensity)
		modified_status.intensity = -(defense_down)
		if modified_status.intensity != 0:
			emit_signal("apply_status", target, modified_status, source)
		amount -= defense_down
	if amount > 0:
		emit_signal("apply_health", target, -(amount), source)
	return amount

func _resolve_damage(effect:EffectData, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var source_battle_manager : CharacterBattleManager = character_manager_map[source]
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var source_statuses = source_battle_manager.get_statuses()
	var target_statuses = target_battle_manager.get_statuses()
	var total_damage = effect_calculator.get_effect_total(effect.amount, effect.type_tag, source_statuses, target_statuses)
	var health_damage = _apply_damage(source_battle_manager, target_battle_manager, total_damage)
	if source_battle_manager:
		var venomous_status : StatusData = source_battle_manager.get_status(EffectCalculator.VENOMOUS_STATUS)
		if venomous_status and health_damage > 0:
			var toxin_status : StatusData = toxin_status_resource.duplicate()
			toxin_status.intensity = venomous_status.intensity
			toxin_status.duration = venomous_status.duration
			emit_signal("apply_status", target, toxin_status, source)

func _resolve_self_damage(effect:EffectData, target:CharacterData, character_manager_map:Dictionary):
	var target_statuses = _get_character_statuses(target, character_manager_map)
	var total_damage = effect_calculator.get_effect_total(effect.amount, effect.type_tag, [], target_statuses)
	emit_signal("apply_health", target, -(total_damage), target)

func _resolve_status_to_damage(status: StatusData, source:CharacterData,  target:CharacterData):
	emit_signal("apply_health", target, -(status.get_stack_value()), source)

func _resolve_related_status_type_damage(status: String, source:CharacterData,  target:CharacterData, character_manager_map:Dictionary):
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var damaging_status : StatusData = target_battle_manager.get_related_status(status, source)
	if damaging_status != null:
		_resolve_status_to_damage(damaging_status, source, target)

func _resolve_source_status_type_damage(status: String, source:CharacterData,  target:CharacterData, character_manager_map:Dictionary):
	var source_battle_manager : CharacterBattleManager = character_manager_map[source]
	var damaging_status : StatusData = source_battle_manager.get_status(status)
	if damaging_status != null:
		_resolve_status_to_damage(damaging_status, source, target)

func _resolve_statuses(effect:StatusEffectData, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	for status in effect.statuses:
		var modified_status : StatusData = status.duplicate()
		var source_statuses = _get_character_statuses(source, character_manager_map)
		var target_statuses = _get_character_statuses(target, character_manager_map)
		var status_quantity : int = modified_status.get_stack_value()
		status_quantity *= effect.amount
		status_quantity = effect_calculator.get_effect_total(status_quantity, effect.type_tag, source_statuses, target_statuses)
		modified_status.set_stack_value(status_quantity)
		if modified_status is RelatedStatusData:
			modified_status.source = source
			modified_status.target = target
			emit_signal("apply_status", source, modified_status, source)
		emit_signal("apply_status", target, modified_status, source)

func _resolve_deck_mod(effect:DeckModEffectData, character:CharacterData):
	var new_card = effect.card.duplicate()
	emit_signal("spawn_card", new_card, character)
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
			var final_targets = _resolve_opportunity_effect_targets(opportunity, effect)
			for final_target in final_targets:
				match(effect.type_tag):
					EffectCalculator.ADD_ATTACK_EFFECT:
						for _i in range(effect.amount):
							emit_signal("add_opportunity", CardData.CardType.ATTACK, opportunity.source, final_target)
					EffectCalculator.ADD_DEFEND_EFFECT:
						for _i in range(effect.amount):
							emit_signal("add_opportunity", CardData.CardType.DEFEND, opportunity.source, final_target)
					EffectCalculator.ADD_SKILL_EFFECT:
						for _i in range(effect.amount):
							emit_signal("add_opportunity", CardData.CardType.SKILL, opportunity.source, final_target)
					EffectCalculator.DRAW_CARD_EFFECT:
						emit_signal("draw_from_draw_pile", final_target, effect.amount)
					EffectCalculator.GAIN_ENERGY_EFFECT:
						emit_signal("apply_energy", final_target, effect.amount, opportunity.source)
					EffectCalculator.LOSE_ENERGY_EFFECT:
						emit_signal("apply_energy", final_target, -(effect.amount), opportunity.source)
					EffectCalculator.MARKED_DAMAGE_EFFECT:
						_resolve_related_status_type_damage(EffectCalculator.MARKED_STATUS, opportunity.source, final_target, character_manager_map)
					EffectCalculator.SHIELD_ATTACK_EFFECT:
						_resolve_source_status_type_damage(EffectCalculator.DEFENSE_STATUS, opportunity.source, final_target, character_manager_map)
					EffectCalculator.ATTACK_EFFECT:
						_resolve_damage(effect, opportunity.source, final_target, character_manager_map)
				if effect is StatusEffectData:
					_resolve_statuses(effect, opportunity.source, final_target, character_manager_map)
				if effect is DeckModEffectData:
					_resolve_deck_mod(effect, final_target)

func add_all_opportunities(type : int, source : CharacterData, target : CharacterData, character_manager_map : Dictionary):
	var source_battle_manager : CharacterBattleManager = character_manager_map[source]
	var base_opportunities : int = source_battle_manager.base_opportunities[type]
	if base_opportunities != null:
		for _i in range(base_opportunities):
				emit_signal("add_opportunity", type, source, target)
	match(type):
		CardData.CardType.ATTACK:
			var riposte_status : StatusData = source_battle_manager.get_related_status(EffectCalculator.RIPOSTE_STATUS, target, false)
			if riposte_status != null:
				for _i in range(riposte_status.get_stack_value()):
					emit_signal("add_opportunity", CardData.CardType.ATTACK, source, target)
			var marked_status : StatusData = source_battle_manager.get_related_status(EffectCalculator.MARKED_STATUS, target, false)
			if marked_status != null:
				emit_signal("add_opportunity", CardData.CardType.ATTACK, source, target)
		CardData.CardType.DEFEND:
			var reinforced_status : StatusData = source_battle_manager.get_status(EffectCalculator.REINFORCED_STATUS)
			if reinforced_status != null:
				for _i in range(reinforced_status.get_stack_value()):
					emit_signal("add_opportunity", CardData.CardType.DEFEND, source, target)
			var fortified_status : StatusData = source_battle_manager.get_status(EffectCalculator.FORTIFIED_STATUS)
			if fortified_status != null:
				emit_signal("add_opportunity", CardData.CardType.DEFEND, source, target)
		CardData.CardType.SKILL:
			var focused_status : StatusData = source_battle_manager.get_status(EffectCalculator.FOCUSED_STATUS)
			if focused_status != null:
				for _i in range(focused_status.get_stack_value()):
					emit_signal("add_opportunity", CardData.CardType.SKILL, source, target)
			var planned_status : StatusData = source_battle_manager.get_status(EffectCalculator.PLANNED_STATUS)
			if planned_status != null:
				emit_signal("add_opportunity", CardData.CardType.SKILL, source, target)

func set_starting_energy(character_battle_manager : CharacterBattleManager):
	var base_energy = character_battle_manager.starting_energy - character_battle_manager.current_energy
	var character = character_battle_manager.character_data
	var charged_status : StatusData = character_battle_manager.get_status(EffectCalculator.CHARGED_STATUS)
	if charged_status != null:
		base_energy += charged_status.get_stack_value()
	emit_signal("apply_energy", character, base_energy, character)

func get_starting_draw_card_count(character_battle_manager : CharacterBattleManager):
	var character : CharacterData = character_battle_manager.character_data
	var draw_size : int = character.hand_size
	var current_hand_size : int = character_battle_manager.hand.size()
	var hastened_status : StatusData = character_battle_manager.get_status(EffectCalculator.HASTENED_STATUS)
	if hastened_status != null:
		draw_size += hastened_status.get_stack_value()
	draw_size = min(character_battle_manager.MAX_HAND_SIZE - current_hand_size, draw_size)
	return draw_size

func draw_starting_hand(character_battle_manager : CharacterBattleManager):
	var character = character_battle_manager.character_data
	var draw_size : int = get_starting_draw_card_count(character_battle_manager)
	if draw_size > 0:
		emit_signal("draw_from_draw_pile", character, draw_size)
