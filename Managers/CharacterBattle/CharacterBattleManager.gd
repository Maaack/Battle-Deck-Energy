extends Node


class_name CharacterBattleManager

const MAX_HAND_SIZE = 12

signal card_drawn(character, card)
signal card_added_to_hand(character, card)
signal card_removed_from_hand(character, card)
signal card_discarded(character, card)
signal card_exhausted(character, card)
signal card_reshuffled(character, card)
signal card_played(character, card, opportunity)
signal status_updated(character, status, delta)
signal character_died(character)
signal turn_ended(character)

onready var status_manager = $StatusManager
onready var iff_manager = $IFFManager

var defense_status_resource = preload("res://Resources/Statuses/Defense.tres")
var health_status_base = preload("res://Resources/Statuses/Health.tres")
var energy_status_base = preload("res://Resources/Statuses/Energy.tres")

var character_data : CharacterData
var starting_energy : int = 0
var current_energy : int = 0
var draw_pile : DeckData = DeckData.new()
var discard_pile : DeckData = DeckData.new()
var exhaust_pile : DeckData = DeckData.new()
var hand : HandData = HandData.new()
var statuses : Array = []
onready var base_opportunities : Dictionary = {
	CardData.CardType.ATTACK : 1,
	CardData.CardType.DEFEND : 1,
	CardData.CardType.SKILL : 1,
}

func _reset_energy():
	starting_energy = character_data.energy

func _reset_draw_pile():
	for card in character_data.deck:
		draw_pile.add_card(card.duplicate())
	draw_pile.shuffle()

func _reset_discard_pile():
	discard_pile.clear()

func _reset_exhaust_pile():
	exhaust_pile.clear()

func get_health_status_snapshot():
	var health_status_snapshot = health_status_base.duplicate()
	health_status_snapshot.intensity = character_data.health
	return health_status_snapshot

func get_energy_status_snapshot():
	var energy_status_snapshot = energy_status_base.duplicate()
	energy_status_snapshot.intensity = current_energy
	return energy_status_snapshot

func reset():
	_reset_draw_pile()
	_reset_discard_pile()
	_reset_exhaust_pile()
	_reset_energy()

func gain_health(amount: int = 1):
	character_data.health += amount
	var health_status_snapshot = get_health_status_snapshot()
	emit_signal("status_updated", character_data, health_status_snapshot, amount)

func lose_health(amount: int = 1):
	amount = min(character_data.health, amount)
	character_data.health -= amount
	var health_status_snapshot = get_health_status_snapshot()
	emit_signal("status_updated", character_data, health_status_snapshot, -(amount))
	if character_data.health == 0:
		emit_signal("character_died", character_data)

func gain_energy(amount:int = 1):
	current_energy += amount
	var energy_status_snapshot = get_energy_status_snapshot()
	emit_signal("status_updated", character_data, energy_status_snapshot, amount)

func lose_energy(amount:int = 1):
	amount = min(current_energy, amount)
	current_energy -= amount
	var energy_status_snapshot = get_energy_status_snapshot()
	emit_signal("status_updated", character_data, energy_status_snapshot, -(amount))

func reshuffle_card(card:CardData):
	draw_pile.add_card(card)
	draw_pile.shuffle()
	emit_signal("card_reshuffled", character_data, card)

func add_card_to_draw_pile(card:CardData):
	reshuffle_card(card)

func reshuffle_discard_pile():
	var discarded : Array = discard_pile.draw_all()
	for card in discarded:
		reshuffle_card(card)

func add_card_to_hand(card:CardData):
	hand.add_card(card)
	emit_signal("card_added_to_hand", character_data, card)

func add_card_to_discard_pile(card:CardData):
	discard_pile.add_card(card)
	emit_signal("card_discarded", character_data, card)

func add_card_to_exhaust_pile(card:CardData):
	exhaust_pile.add_card(card)
	emit_signal("card_exhausted", character_data, card)

func _discard_card_from_hand(card:CardData):
	hand.discard_card(card)
	emit_signal("card_removed_from_hand", character_data, card)

func discard_card(card:CardData):
	_discard_card_from_hand(card)
	add_card_to_discard_pile(card)

func exhaust_card(card:CardData):
	_discard_card_from_hand(card)
	add_card_to_exhaust_pile(card)

func draw_card(card = null):
	if draw_pile.size() < 1:
		reshuffle_discard_pile()
	var drawn_card : CardData
	if is_instance_valid(card):
		drawn_card = draw_pile.draw_specific_card(card)
	else:
		drawn_card = draw_pile.draw_card()
	if not is_instance_valid(drawn_card):
		return
	emit_signal("card_drawn", character_data, drawn_card)
	add_card_to_hand(drawn_card)

func draw_cards(count : int):
	for _i in range(count):
		draw_card()

func has_innate_cards_in_draw_pile():
	var innate_cards : Array = EffectCardFilter.include_innate_cards(draw_pile.cards)
	return innate_cards.size() > 0

func draw_innate_cards():
	var innate_cards : Array = EffectCardFilter.include_innate_cards(draw_pile.cards)
	for card in innate_cards:
		draw_card(card)

func has_discardable_cards_in_hand():
	var discarding_cards : Array = EffectCardFilter.include_discardable_cards(hand.cards)
	var exhausting_cards : Array = EffectCardFilter.include_exhaustable_cards(hand.cards)
	return discarding_cards.size() + exhausting_cards.size() > 0

func discard_hand():
	var discarding_cards : Array = EffectCardFilter.include_discardable_cards(hand.cards)
	var exhausting_cards : Array = EffectCardFilter.include_exhaustable_cards(hand.cards)
	discarding_cards.shuffle()
	exhausting_cards.shuffle()
	for card in discarding_cards:
		discard_card(card)
	for card in exhausting_cards:
		exhaust_card(card)

func play_card(card:CardData):
	lose_energy(card.energy_cost)
	emit_signal("card_played", character_data, card, null)

func play_card_on_opportunity(card:CardData, opportunity:OpportunityData):
	lose_energy(card.energy_cost)
	emit_signal("card_played", character_data, card, opportunity)

func end_turn():
	emit_signal("turn_ended", character_data)

func gain_status(status:StatusData, origin:CharacterData):
	var cycle_mode : int = StatusManager.CycleMode.NONE
	var is_origin : bool = origin == character_data
	var is_target : bool = true
	if status is RelatedStatusData:
		if status.target != character_data:
			is_target = false
	if status.has_the_d():
		if is_origin:
			cycle_mode = StatusManager.CycleMode.START_1
		else:
			cycle_mode = StatusManager.CycleMode.END
	match(status.type_tag):
		EffectCalculator.DEFENSE_STATUS, EffectCalculator.VULNERABLE_STATUS:
			cycle_mode = StatusManager.CycleMode.START_2
		EffectCalculator.POISONED_STATUS, EffectCalculator.BARRICADED_STATUS:
			cycle_mode = StatusManager.CycleMode.START_3
	status_manager.gain_status(status, cycle_mode, is_target)

func _run_start_of_turn_statuses():
	var poisoned_status : StatusData = status_manager.get_status(EffectCalculator.POISONED_STATUS)
	if poisoned_status:
		lose_health(poisoned_status.duration)
	var barricaded_status : StatusData = status_manager.get_status(EffectCalculator.BARRICADED_STATUS)
	if barricaded_status:
		var defense_status = defense_status_resource.duplicate()
		defense_status.intensity = barricaded_status.intensity
		gain_status(defense_status, character_data)

func has_statuses():
	return status_manager.has_statuses()

func update_early_start_of_turn_statuses():
	status_manager.decrement_durations(StatusManager.CycleMode.START_1)

func update_late_start_of_turn_statuses():
	status_manager.decrement_durations(StatusManager.CycleMode.START_2)
	_run_start_of_turn_statuses()
	status_manager.decrement_durations(StatusManager.CycleMode.START_3)

func update_end_of_turn_statuses():
	status_manager.decrement_durations(StatusManager.CycleMode.END)

func get_statuses():
	var all_statuses : Array = status_manager.status_map.values()
	for related_statuses in status_manager.related_status_source_map.values():
		if related_statuses is Dictionary:
			all_statuses += related_statuses.values()
	for related_statuses in status_manager.related_status_target_map.values():
		if related_statuses is Dictionary:
			all_statuses += related_statuses.values()
	return all_statuses

func get_status(type_tag:String):
	return status_manager.get_status(type_tag)

func get_related_status(type_tag:String, related:CharacterData, is_target : bool = true):
	return status_manager.get_related_status(type_tag, related, is_target)

func has_status(type_tag:String, source = null):
	return get_status(type_tag) != null

func _on_StatusManager_status_updated(status:StatusData, delta:int):
	emit_signal("status_updated", character_data, status, delta)
