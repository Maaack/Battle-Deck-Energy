extends CharacterBattleManager


class_name EnemyAIBattleManager

var played_cards : Dictionary = {}

func _play_card(card : CardData, opportunity : OpportunityData):
	opportunity.card_data = card
	emit_signal("card_played", character_data, card, opportunity)

func _end_turn():
	EventBus.turn_ended.emit(character_data)

func take_turn(opportunities : Array):
	if not character_data.is_alive():
		_end_turn()
		return
	var weighted_hand : WeightedDataList = WeightedDataList.new()
	for card in hand.cards:
		if card is CardData:
			var divide_weight = 1
			weighted_hand.append_data(card)
			if card.title in played_cards:
				divide_weight += played_cards[card.title]
			weighted_hand.weighted_map[card] = weighted_hand.weighted_map[card] / divide_weight
	var random_card : CardData = weighted_hand.get_random_data()
	if not random_card.title in played_cards:
		played_cards[random_card.title] = 0
	played_cards[random_card.title] += 1
	for opportunity in opportunities:
		if random_card.type == opportunity.type:
			_play_card(random_card, opportunity)
			_end_turn()
			return
