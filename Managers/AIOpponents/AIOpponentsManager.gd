extends Node


signal played_card(character, card, opportunity)

var character_battle_manager_scene = preload("res://Managers/CharacterBattle/CharacterBattleManager.tscn")
var characters : Dictionary = {}

func add_opponent(character_data:CharacterData):
	if is_instance_valid(character_data):
		var instance = character_battle_manager_scene.instance()
		add_child(instance)
		instance.character_data = character_data
		characters[character_data] = instance
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
			if not child.character_data.is_active():
				continue
			child.draw_hand()
			var random_index: int = randi() % child.hand.size()
			var opponent_opportunities : Array = opponent_map[child.character_data]
			var opportunity : OpportunityData = opponent_opportunities.pop_front()
			opportunity.card_data = child.hand.cards[random_index]
			emit_signal("played_card", child.character_data, opportunity.card_data, opportunity)
			child.discard_hand()
