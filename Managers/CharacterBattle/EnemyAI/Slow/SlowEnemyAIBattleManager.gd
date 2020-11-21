extends EnemyAIBattleManager


class_name SlowEnemyAIBattleManager

signal card_revealed(character, card, opportunity)

onready var slowed_cards_timer = $SlowedCardsTimer

var slowed_cards : Array = []

func _play_card(card : CardData, opportunity : OpportunityData):
	opportunity.card_data = card
	slowed_cards.append([card, opportunity])
	_discard_card_from_hand(card)
	emit_signal("card_revealed", character_data, card, opportunity)

func take_turn(opportunities : Array):
	if not character_data.is_alive():
		end_turn()
		return
	var weighted_hand : WeightedDataList = WeightedDataList.new()
	while (slowed_cards.size() > 0):
		var card_and_opp : Array = slowed_cards.pop_front()
		emit_signal("card_played", character_data, card_and_opp[0], card_and_opp[1])
		slowed_cards_timer.start()
		yield(slowed_cards_timer, "timeout")
	for card in hand.cards:
		if card is CardData:
			var divide_weight = 1
			var weighted_data = weighted_hand.append_data(card)
			if card.title in played_cards:
				divide_weight += played_cards[card.title]
			weighted_data.weight /= divide_weight
	var random_card : CardData = weighted_hand.get_random_data()
	if not random_card.title in played_cards:
		played_cards[random_card.title] = 0
	played_cards[random_card.title] += 1
	for opportunity in opportunities:
		if random_card.type == opportunity.type:
			_play_card(random_card, opportunity)
			end_turn()
			return
