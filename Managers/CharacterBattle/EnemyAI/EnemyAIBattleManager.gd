extends CharacterBattleManager


class_name EnemyAIBattleManager

var played_cards : Dictionary = {}

func take_turn(opportunities : Array):
	if not character_data.is_alive():
		return
	var weighted_hand : WeightedDataList = WeightedDataList.new()
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
		if opportunity is OpportunityData and random_card.type == opportunity.type:
			opportunity.card_data = random_card
			emit_signal("card_played", character_data, random_card, opportunity)
			discard_card(random_card)
			return
