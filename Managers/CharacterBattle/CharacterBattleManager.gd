extends Node


class_name CharacterBattleManager

signal drew_card_from_draw_pile(card)
signal drew_card(card)
signal discarded_card(card)
signal exhausted_card(card)
signal reshuffled_card(card)
signal played_card(card, opportunity)
signal gained_health(character, amount)
signal lost_health(character, amount)
signal gained_energy(character, amount)
signal lost_energy(character, amount)
signal updated_status(character, status, delta)
signal died(character)

onready var status_manager = $StatusManager

var defense_status_resource = preload("res://Resources/Statuses/Defense.tres")

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

func reset():
	randomize()
	character_data.energy = 0
	_reset_draw_pile()
	_reset_discard_pile()
	_reset_exhaust_pile()

func set_character_data(value:CharacterData):
	character_data = value
	reset()

func gain_health(amount: int = 1):
	character_data.health += amount
	emit_signal("gained_health", character_data, amount)

func lose_health(amount: int = 1):
	amount = min(character_data.health, amount)
	character_data.health -= amount
	emit_signal("lost_health", character_data, amount)
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
	emit_signal("gained_energy", character_data, amount)

func lose_energy(amount:int = 1):
	amount = min(character_data.energy, amount)
	character_data.energy -= amount
	emit_signal("lost_energy", character_data, amount)

func reset_energy():
	var recharge_amount : int = character_data.max_energy - character_data.energy
	gain_energy(recharge_amount)

func reshuffle_discard_pile():
	var discarded : Array = discard_pile.draw_all()
	for card in discarded:
		reshuffle_card(card)

func add_card_to_draw_pile(card:CardData):
	draw_pile.add_card(card)
	draw_pile.shuffle()
	emit_signal("reshuffled_card", card)

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
	add_card_to_draw_pile(card)

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

func discard_hand():
	var shuffled_cards : Array = hand.discard_all()
	shuffled_cards.shuffle()
	for card in shuffled_cards:
		discard_card(card)
	return shuffled_cards

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
		if origin == character_data or status.type_tag == EffectCalculator.VULNERABLE_STATUS:
			cycle_mode = StatusManager.CycleMode.START
		else:
			cycle_mode = StatusManager.CycleMode.END
	if status.type_tag == EffectCalculator.TOXIN_STATUS or status.type_tag == EffectCalculator.EN_GARDE_STATUS :
		cycle_mode = StatusManager.CycleMode.NONE
	status_manager.gain_status(status, cycle_mode)

func _run_start_of_turn_statuses():
	var toxin_status : StatusData = status_manager.get_status_by_type(EffectCalculator.TOXIN_STATUS)
	if toxin_status:
		take_damage(toxin_status.duration)
		status_manager.decrement_duration(toxin_status)
	var en_garde_status : StatusData = status_manager.get_status_by_type(EffectCalculator.EN_GARDE_STATUS)
	if en_garde_status:
		var defense_status = defense_status_resource.duplicate()
		defense_status.intensity = en_garde_status.intensity
		gain_status(defense_status, character_data)
		status_manager.decrement_duration(en_garde_status)

func update_start_of_turn_statuses():
	status_manager.decrement_durations(StatusManager.CycleMode.START)
	_run_start_of_turn_statuses()

func update_end_of_turn_statuses():
	status_manager.decrement_durations(StatusManager.CycleMode.END)

func get_statuses():
	return status_manager.status_type_map.values()

func _on_StatusManager_updated_status(status:StatusData, delta:int):
	emit_signal("updated_status", character_data, status, delta)
