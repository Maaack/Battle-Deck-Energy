extends Node



var character_battle_manager_scene = preload("res://Managers/CharacterBattle/CharacterBattleManager.tscn")
var characters : Dictionary = {}

func add_opponent(character_data:CharacterData):
	if is_instance_valid(character_data):
		var instance = character_battle_manager_scene.instance()
		add_child(instance)
		instance.character_data = character_data
		characters[character_data] = instance

func opponents_take_turn():
	for child in get_children():
		if child is CharacterBattleManager:
			child.draw_hand()
			var random_index: int = randi() % child.hand.size()
			print("Opponent plays %s from %s" % [str(child.hand.cards[random_index]), child.hand.cards ])
			child.discard_hand()
