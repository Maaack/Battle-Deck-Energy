extends Node


signal played_card(character, card, opportunity)

var character_battle_manager_scene = preload("res://Managers/CharacterBattle/CharacterBattleManager.tscn")
var characters : Dictionary = {}
var character_played_cards : Dictionary = {}

func add_opponent(character_data:CharacterData):
	if is_instance_valid(character_data):
		var instance = character_battle_manager_scene.instance()
		add_child(instance)
		instance.character_data = character_data
		characters[character_data] = instance
		character_played_cards[character_data] = {}
		return instance

func _get_opponent_map(opportunities:Array):
	var opponent_map : Dictionary = {}
	for opportunity in opportunities:
		if opportunity is OpportunityData:
			if opportunity.source in characters:
				if not opportunity.source in opponent_map:
					opponent_map[opportunity.source] = []
				opponent_map[opportunity.source].append(opportunity)
	return opponent_map

func opponents_take_turn(opportunities:Array):
	var opponent_map = _get_opponent_map(opportunities)
	for child in get_children():
		if child is CharacterBattleManager:
			var character_data = child.character_data
			if not character_data.is_active():
				continue
			child.draw_hand()
			var played_cards : Dictionary = character_played_cards[character_data]
			var weighted_hand : WeightedDataList = WeightedDataList.new()
			for card in child.hand.cards:
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
			print("card %s played %d times " % [random_card.title, played_cards[random_card.title]])
			var opponent_opportunities : Array = opponent_map[character_data]
			for opportunity in opponent_opportunities:
				if opportunity is OpportunityData and random_card.type == opportunity.type:
					opportunity.card_data = random_card
					emit_signal("played_card", child.character_data, opportunity.card_data, opportunity)

func opponents_end_turn():
	for child in get_children():
		if child is CharacterBattleManager:
			child.discard_hand()
