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
var poisoned_status_resource = preload("res://Resources/Statuses/Poisoned.tres")
var riposte_status_resource = preload("res://Resources/Statuses/Riposte.tres")
var barricaded_status_resource = preload("res://Resources/Statuses/Barricaded.tres")
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

func _resolve_venemous_status(health_loss : int, source_battle_manager : CharacterBattleManager, target : CharacterData):
	if health_loss == 0:
		return
	var source : CharacterData = source_battle_manager.character_data
	var venomous_status : StatusData = source_battle_manager.get_status(EffectCalculator.VENOMOUS_STATUS)
	if venomous_status:
		var poisoned_status : StatusData = poisoned_status_resource.duplicate()
		poisoned_status.intensity = venomous_status.intensity
		poisoned_status.duration = venomous_status.duration
		emit_signal("apply_status", target, poisoned_status, source)

func _get_modified_damage(effect:EffectData, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var source_battle_manager : CharacterBattleManager = character_manager_map[source]
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var source_statuses = source_battle_manager.get_statuses()
	var target_statuses = target_battle_manager.get_statuses()
	return effect_calculator.get_effect_total(effect.amount, effect.type_tag, source_statuses, target_statuses)

func _resolve_damage(effect:EffectData, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var source_battle_manager : CharacterBattleManager = character_manager_map[source]
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var total_damage = _get_modified_damage(effect, source, target, character_manager_map)
	var health_damage = _apply_damage(source_battle_manager, target_battle_manager, total_damage)
	if source_battle_manager:
		_resolve_venemous_status(health_damage, source_battle_manager, target)

func _resolve_smash_damage(effect:EffectData, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var source_battle_manager : CharacterBattleManager = character_manager_map[source]
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var total_damage = _get_modified_damage(effect, source, target, character_manager_map)
	var defense_status : StatusData = target_battle_manager.get_status(EffectCalculator.DEFENSE_STATUS)
	if defense_status:
		var starting_damage = effect.amount
		var defense_mod = defense_status.get_stack_value()
		total_damage += min(defense_mod/2, starting_damage)
	var health_damage = _apply_damage(source_battle_manager, target_battle_manager, total_damage)
	if source_battle_manager:
		_resolve_venemous_status(health_damage, source_battle_manager, target)

func _resolve_self_damage(effect:EffectData, target:CharacterData, character_manager_map:Dictionary):
	var target_statuses = _get_character_statuses(target, character_manager_map)
	var total_damage = effect_calculator.get_effect_total(effect.amount, effect.type_tag, [], target_statuses)
	emit_signal("apply_health", target, -(total_damage), target)

func _resolve_status_to_damage(status: StatusData, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var source_battle_manager : CharacterBattleManager = character_manager_map[source]
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var health_damage = _apply_damage(source_battle_manager, target_battle_manager, status.get_stack_value())

func _resolve_related_status_type_damage(status: String, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var damaging_status : StatusData = target_battle_manager.get_related_status(status, source)
	if damaging_status:
		_resolve_status_to_damage(damaging_status, source, target, character_manager_map)

func _resolve_source_status_type_damage(status: String, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var source_battle_manager : CharacterBattleManager = character_manager_map[source]
	var damaging_status : StatusData = source_battle_manager.get_status(status)
	if damaging_status:
		_resolve_status_to_damage(damaging_status, source, target, character_manager_map)

func _resolve_target_status_type_damage(status: String, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var damaging_status : StatusData = target_battle_manager.get_status(status)
	if damaging_status:
		_resolve_status_to_damage(damaging_status, source, target, character_manager_map)

func _resolve_status(status:StatusData, mod:float, effect_type:String, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	var modified_status : StatusData = status.duplicate()
	var source_statuses = _get_character_statuses(source, character_manager_map)
	var target_statuses = _get_character_statuses(target, character_manager_map)
	var status_quantity : int = modified_status.get_stack_value()
	status_quantity *= mod
	status_quantity = effect_calculator.get_effect_total(status_quantity, effect_type, source_statuses, target_statuses)
	modified_status.set_stack_value(status_quantity)
	if modified_status is RelatedStatusData:
		var modifying_status : RelatedStatusData = modified_status.relating_status.duplicate()
		modified_status.source = source
		modified_status.target = target
		if modifying_status:
			modifying_status.source = source
			modifying_status.target = target
			modifying_status.relating_status = modified_status
			modifying_status.set_stack_value(modified_status.get_stack_value())
			emit_signal("apply_status", source, modifying_status, target)
		else:
			emit_signal("apply_status", source, modified_status, target)
	emit_signal("apply_status", target, modified_status, source)

func _resolve_statuses(effect:StatusEffectData, source:CharacterData, target:CharacterData, character_manager_map:Dictionary):
	for status in effect.statuses:
		_resolve_status(status, effect.amount, effect.type_tag, source, target, character_manager_map)

func _resolve_status_to_status(from_status_string : String, to_status : StatusData, source : CharacterData, target : CharacterData, character_manager_map : Dictionary, mod : float = 1.0):
	var source_battle_manager : CharacterBattleManager = character_manager_map[source]
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var source_status : StatusData = target_battle_manager.get_status(from_status_string)
	if source_status:
		var new_status : StatusData = to_status.duplicate()
		var new_value : int = int(float(source_status.get_stack_value()) * mod)
		new_status.set_stack_value(new_value)
		emit_signal("apply_status", target, new_status, source)

func _resolve_interrupt_statuses(cycle_type : int, target : CharacterData, character_manager_map : Dictionary):
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	target_battle_manager.status_manager.decrement_durations(cycle_type)

func _resolve_modify_status(status : StatusData, mod : float, effect_type : String, source : CharacterData, target : CharacterData, character_manager_map : Dictionary):
	var new_status : StatusData = status.duplicate()
	var original_value : int = status.get_stack_value()
	var delta : int = int(original_value * mod) - original_value
	new_status.set_stack_value(delta)
	_resolve_status(new_status, 1, effect_type, source, target, character_manager_map)

func _resolve_modify_related_status_type(status : String, mod : float, effect_type : String, source : CharacterData, target : CharacterData, character_manager_map : Dictionary):
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var modifying_status : StatusData = target_battle_manager.get_related_status(status, source)
	if modifying_status:
		_resolve_modify_status(modifying_status, mod, effect_type, source, target, character_manager_map)

func _resolve_modify_status_type(status : String, mod : float, effect_type : String, source : CharacterData, target : CharacterData, character_manager_map : Dictionary):
	var target_battle_manager : CharacterBattleManager = character_manager_map[target]
	var modifying_status : StatusData = target_battle_manager.get_status(status)
	if modifying_status:
		_resolve_modify_status(modifying_status, mod, effect_type, source, target, character_manager_map)

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
					EffectCalculator.INTERRUPT_EFFECT:
						_resolve_interrupt_statuses(StatusManager.CycleMode.BUFFS, final_target, character_manager_map)
					EffectCalculator.MARKED_DAMAGE_EFFECT:
						_resolve_related_status_type_damage(EffectCalculator.MARKED_STATUS, opportunity.source, final_target, character_manager_map)
					EffectCalculator.DOUBLE_MARKED_EFFECT:
						_resolve_modify_related_status_type(EffectCalculator.MARKED_STATUS, 2, effect.type_tag, opportunity.source, final_target, character_manager_map)
					EffectCalculator.CURE_POISONED_EFFECT:
						_resolve_modify_status_type(EffectCalculator.POISONED_STATUS, 0, effect.type_tag, opportunity.source, final_target, character_manager_map)
					EffectCalculator.CURE_VULNERABLE_EFFECT:
						_resolve_modify_status_type(EffectCalculator.VULNERABLE_STATUS, 0, effect.type_tag, opportunity.source, final_target, character_manager_map)
					EffectCalculator.CURE_FRAGILE_EFFECT:
						_resolve_modify_status_type(EffectCalculator.FRAGILE_STATUS, 0, effect.type_tag, opportunity.source, final_target, character_manager_map)
					EffectCalculator.CURE_WEAK_EFFECT:
						_resolve_modify_status_type(EffectCalculator.WEAK_STATUS, 0, effect.type_tag, opportunity.source, final_target, character_manager_map)
					EffectCalculator.SHIELD_ATTACK_EFFECT:
						_resolve_source_status_type_damage(EffectCalculator.DEFENSE_STATUS, opportunity.source, final_target, character_manager_map)
					EffectCalculator.HALF_DEFEND_TO_BARRICADED:
						_resolve_status_to_status(EffectCalculator.DEFENSE_STATUS, barricaded_status_resource, opportunity.source, final_target, character_manager_map, 0.5)
					EffectCalculator.DEFEND_TO_BARRICADED:
						_resolve_status_to_status(EffectCalculator.DEFENSE_STATUS, barricaded_status_resource, opportunity.source, final_target, character_manager_map)
					EffectCalculator.SMASH_ATTACK_EFFECT:
						_resolve_smash_damage(effect, opportunity.source, final_target, character_manager_map)
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
			var engaging_status : StatusData = source_battle_manager.get_related_status(EffectCalculator.ENGAGING_STATUS, target, false)
			if engaging_status != null:
				for _i in range(engaging_status.get_stack_value()):
					emit_signal("add_opportunity", CardData.CardType.ATTACK, source, target)
			var marking_status : StatusData = source_battle_manager.get_related_status(EffectCalculator.MARKING_STATUS, target, false)
			if marking_status != null:
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
