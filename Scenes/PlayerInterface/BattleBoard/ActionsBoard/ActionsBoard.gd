extends HBoxContainer


onready var player_actions_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/PlayerActions/PlayerActions.tscn")
onready var opponent_actions_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/OpponentActions/OpponentActions.tscn")

var characters_map : Dictionary = {}

func add_character_actions(character:CharacterData, scene:PackedScene):
	if character in characters_map:
		return characters_map[character]
	var instance = scene.instance()
	add_child(instance)
	characters_map[character] = instance
	return instance

func add_player_actions(player:CharacterData):
	var instance = add_character_actions(player, player_actions_scene)
	return instance

func add_opponent_actions(opponent:CharacterData):
	var instance = add_character_actions(opponent, opponent_actions_scene)
	instance.character_data = opponent
	return instance

func defeat_opponent(opponent:CharacterData):
	var instance = get_opponent_actions_instance(opponent)
	instance.remove_all_openings()
	instance.queue_free()
	characters_map.erase(opponent)

func get_opponent_actions_instance(character:CharacterData):
	if character in characters_map:
		return characters_map[character]

func add_opponent_openings(opportunities:Array):
	var openings : Array = []
	for opportunity_data in opportunities:
		if opportunity_data is OpportunityData:
			var source = opportunity_data.source
			if source in characters_map:
				var actions_interface : OpponentActionsInterface = characters_map[source]
				if is_instance_valid(actions_interface):
					var opening : BattleOpening = actions_interface.add_opponent_opening(opportunity_data)
					if is_instance_valid(opening):
						openings.append(opening)
	return openings

func add_player_openings(opportunities:Array):
	var openings : Array = []
	for opportunity_data in opportunities:
		if opportunity_data is OpportunityData:
			var target = opportunity_data.target
			if target in characters_map:
				var actions_interface = characters_map[target]
				print("in characters_map %s " % str(actions_interface))
				if actions_interface is OpponentActionsInterface:
					var opening : BattleOpening = actions_interface.add_player_opening(opportunity_data)
					if is_instance_valid(opening):
						openings.append(opening)
				elif actions_interface is PlayerActionsInterface:
					var opening : BattleOpening = actions_interface.add_active_opening(opportunity_data)
					if is_instance_valid(opening):
						openings.append(opening)
	return openings

func remove_all_openings():
	for child in get_children():
		if child.has_method("remove_all_openings"):
			child.remove_all_openings()

func get_player_battle_openings():
	var battle_openings : Array = []
	for child in get_children():
		if child.has_method("get_player_battle_openings"):
			battle_openings += child.get_player_battle_openings()
	return battle_openings
