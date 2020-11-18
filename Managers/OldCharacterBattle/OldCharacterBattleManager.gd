extends Node


class_name OldCharacterBattleManager

signal drew_card_from_draw_pile(card)
signal drew_card(card)
signal discarded_card(card)
signal exhausted_card(card)
signal reshuffled_card(card)
signal played_card(card, opportunity)
signal updated_status(character, status, delta)
signal died(character)

onready var status_manager = $StatusManager

var defense_status_resource = preload("res://Resources/Statuses/Defense.tres")
var health_status_base = preload("res://Resources/Statuses/Health.tres")
var energy_status_base = preload("res://Resources/Statuses/Energy.tres")

var character_data : CharacterData setget set_character_data
var draw_pile : DeckData = DeckData.new()
var discard_pile : DeckData = DeckData.new()
var exhaust_pile : DeckData = DeckData.new()
var hand : HandData = HandData.new()
var statuses : Array = []

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
	energy_status_snapshot.intensity = character_data.energy
	return energy_status_snapshot

func reset():
	character_data.energy = 0
	_reset_draw_pile()
	_reset_discard_pile()
	_reset_exhaust_pile()

func set_character_data(value:CharacterData):
	character_data = value
	reset()

func gain_health(amount: int = 1):
	character_data.health += amount
	var health_status_snapshot = get_health_status_snapshot()
	emit_signal("updated_status", character_data, health_status_snapshot, amount)

func lose_health(amount: int = 1):
	amount = min(character_data.health, amount)
	character_data.health -= amount
	var health_status_snapshot = get_health_status_snapshot()
	emit_signal("updated_status", character_data, health_status_snapshot, -(amount))
	if character_data.health == 0:
		emit_signal("died", character_data)

func take_damage(amount: int = 1):
	var status : StatusData = status_manager.get_status_by_type(EffectCalculator.DEFENSE_STATUS)
	if status != null:
		var defense_down = min(amount, status.intensity)
		status.intensity -= defense_down
		emit_signal("updated_status", character_data, status.duplicate(), -(defense_down))
		if status.intensity == 0:
			status_manager.lose_status(status)
		amount -= defense_down
	if amount > 0:
		lose_health(amount)

func gain_energy(amount:int = 1):
	character_data.energy += amount
	var energy_status_snapshot = get_energy_status_snapshot()
	emit_signal("updated_status", character_data, energy_status_snapshot, amount)

func lose_energy(amount:int = 1):
	amount = min(character_data.energy, amount)
	character_data.energy -= amount
	var energy_status_snapshot = get_energy_status_snapshot()
	emit_signal("updated_status", character_data, energy_status_snapshot, -(amount))

func reset_energy():
	var recharge_amount : int = character_data.max_energy - character_data.energy
	gain_energy(recharge_amount)

func reshuffle_discard_pile():
	var discarded : Array = discard_pile.draw_all()
	for card in discarded:
		reshuffle_card(card)

func add_card_to_hand(card:CardData):
	hand.add_card(card)
	emit_signal("drew_card", card)

func add_card_to_discard_pile(card:CardData):
	discard_pile.add_card(card)
	emit_signal("discarded_card", card)

func add_card_to_exhaust_pile(card:CardData):
	exhaust_pile.add_card(card)
	emit_signal("exhausted_card", card)

func _discard_card_from_hand(card:CardData):
	hand.discard_card(card)

func reshuffle_card(card:CardData):
	draw_pile.add_card(card)
	draw_pile.shuffle()
	emit_signal("reshuffled_card", card)

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
	emit_signal("drew_card_from_draw_pile", drawn_card)
	add_card_to_hand(drawn_card)

func draw_hand():
	for _i in range(character_data.hand_size):
		draw_card()

func has_innate_cards_in_draw_pile():
	var innate_cards : Array = EffectCardFilter.include_innate_cards(draw_pile.cards)
	return innate_cards.size() > 0

func draw_innate_cards():
	var innate_cards : Array = EffectCardFilter.include_innate_cards(draw_pile.cards)
	for card in innate_cards:
		draw_card(card)

func discard_hand():
	var discarding_cards : Array = EffectCardFilter.include_discardable_cards(hand.cards)
	var exhausting_cards : Array = EffectCardFilter.include_exhaustable_cards(hand.cards)
	discarding_cards.shuffle()
	exhausting_cards.shuffle()
	for card in discarding_cards:
		discard_card(card)
	for card in exhausting_cards:
		exhaust_card(card)

func has_discardable_cards_in_hand():
	var discarding_cards : Array = EffectCardFilter.include_discardable_cards(hand.cards)
	var exhausting_cards : Array = EffectCardFilter.include_exhaustable_cards(hand.cards)
	return discarding_cards.size() + exhausting_cards.size() > 0

func play_card(card:CardData):
	lose_energy(card.energy_cost)
	var discarded_flag = hand.discard_card(card)
	if discarded_flag:
		emit_signal("played_card", card, null)
	
func play_card_on_opportunity(card:CardData, opportunity:OpportunityData):
	lose_energy(card.energy_cost)
	var discarded_flag = hand.discard_card(card)
	opportunity.card_data = card
	if discarded_flag:
		emit_signal("played_card", card, opportunity)
	
func gain_status(status:StatusData, origin:CharacterData):
	var cycle_mode : int = StatusManager.CycleMode.NONE
	if status.has_the_d():
		if origin == character_data:
			cycle_mode = StatusManager.CycleMode.START_1
		else:
			cycle_mode = StatusManager.CycleMode.END
	match(status.type_tag):
		EffectCalculator.DEFENSE_STATUS, EffectCalculator.VULNERABLE_STATUS:
			cycle_mode = StatusManager.CycleMode.START_2
		EffectCalculator.TOXIN_STATUS, EffectCalculator.EN_GARDE_STATUS:
			cycle_mode = StatusManager.CycleMode.START_3
	status_manager.gain_status(status, cycle_mode)

func _run_start_of_turn_statuses():
	var toxin_status : StatusData = status_manager.get_status_by_type(EffectCalculator.TOXIN_STATUS)
	if toxin_status:
		take_damage(toxin_status.duration)
	var en_garde_status : StatusData = status_manager.get_status_by_type(EffectCalculator.EN_GARDE_STATUS)
	if en_garde_status:
		var defense_status = defense_status_resource.duplicate()
		defense_status.intensity = en_garde_status.intensity
		gain_status(defense_status, character_data)

func update_early_start_of_turn_statuses():
	status_manager.decrement_durations(StatusManager.CycleMode.START_1)

func update_late_start_of_turn_statuses():
	status_manager.decrement_durations(StatusManager.CycleMode.START_2)
	_run_start_of_turn_statuses()
	status_manager.decrement_durations(StatusManager.CycleMode.START_3)

func update_end_of_turn_statuses():
	status_manager.decrement_durations(StatusManager.CycleMode.END)

func get_statuses():
	return status_manager.status_type_map.values()

func get_status_by_type(type_tag:String):
	return status_manager.get_status_by_type(type_tag)

func has_status_by_type(type_tag:String):
	return get_status_by_type(type_tag) != null

func _on_StatusManager_status_updated(status, delta):
	emit_signal("updated_status", character_data, status, delta)
