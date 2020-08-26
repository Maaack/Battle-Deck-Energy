extends HBoxContainer


onready var opponent_actions_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/OpponentActions/OpponentActions.tscn")

var opponents_map : Dictionary = {}

func add_opponent_actions(opponent_data:CharacterData):
	if opponent_data in opponents_map:
		return opponents_map[opponent_data]
	var instance = opponent_actions_scene.instance()
	add_child(instance)
	instance.opponent_data = opponent_data
	opponents_map[opponent_data] = instance
	return instance

func defeat_opponent(opponent:CharacterData):
	var instance = get_opponent_actions_instance(opponent)
	instance.remove_all_openings()
	instance.queue_free()
	opponents_map.erase(opponent)

func get_opponent_actions_instance(opponent:CharacterData):
	if opponent in opponents_map:
		return opponents_map[opponent]

func add_opponent_openings(opps_data:Array):
	var openings : Array = []
	for opportunity_data in opps_data:
		if opportunity_data is OpportunityData:
			var source = opportunity_data.source
			if source in opponents_map:
				var actions_interface : OpponentActionsInterface = opponents_map[source]
				if is_instance_valid(actions_interface):
					var opening : BattleOpening = actions_interface.add_opponent_opening(opportunity_data)
					if is_instance_valid(opening):
						openings.append(opening)
	return openings

func add_player_openings(opps_data:Array):
	var openings : Array = []
	for opportunity_data in opps_data:
		if opportunity_data is OpportunityData:
			var target = opportunity_data.target
			if target in opponents_map:
				var actions_interface : OpponentActionsInterface = opponents_map[target]
				if is_instance_valid(actions_interface):
					var opening : BattleOpening = actions_interface.add_player_opening(opportunity_data)
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
