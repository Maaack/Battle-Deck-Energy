extends Node


class_name CharacterBattleManager

signal drew_card(card)
signal discarded_card(card)
signal exhausted_card(card)
signal reshuffled_card(card)
signal played_card(card, opportunity)
signal gained_health(character, amount)
signal lost_health(character, amount)
signal gained_energy(character, amount)
signal lost_energy(character, amount)
signal died(character)

var character_data : CharacterData setget set_character_data
var draw_pile : DeckData = DeckData.new()
var discard_pile : DeckData = DeckData.new()
var exhaust_pile : DeckData = DeckData.new()
var hand : HandData = HandData.new()

var _drawing_cards : int = 0
var _reshuffling_cards : int = 0

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

func draw_discarded_card():
	if _reshuffling_cards > 0:
		var card: CardData = discard_pile.draw_card()
		reshuffle_card(card)

func add_card_to_hand(card:CardData):
	hand.add_card(card)
	if _drawing_cards > 1:
		_drawing_cards -= 1

func discard_card_from_hand(card:CardData):
	hand.discard_card(card)
	if _drawing_cards > 1:
		_drawing_cards -= 1

func reshuffle_card(card:CardData):
	draw_pile.add_card(card)
	draw_pile.shuffle()
	emit_signal("reshuffled_card", card)

func discard_card(card:CardData):
	discard_card_from_hand(card)
	discard_pile.add_card(card)
	emit_signal("discarded_card", card)

func exhaust_card(card:CardData):
	exhaust_pile.add_card(card)
	emit_signal("exhausted_card", card)

func draw_card():
	if draw_pile.size() < 1:
		reshuffle_discard_pile()
	var card: CardData = draw_pile.draw_card()
	if not is_instance_valid(card):
		return
	add_card_to_hand(card)
	emit_signal("drew_card", card)

func draw_hand():
	for _i in range(character_data.hand_size):
		draw_card()

func discard_hand():
	var shuffled_cards : Array = hand.discard_all()
	shuffled_cards.shuffle()
	for card in shuffled_cards:
		discard_card(card)
	return shuffled_cards

func play_card(card:CardData, opportunity:OpportunityData):
	lose_energy(card.energy_cost)
	var discarded_flag = hand.discard_card(card)
	opportunity.card_data = card
	if discarded_flag:
		emit_signal("played_card", card, opportunity)
