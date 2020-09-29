extends HBoxContainer


onready var player_actions_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/CharacterActionsInterface/Player/PlayerActionsInterface.tscn")
onready var opponent_actions_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/CharacterActionsInterface/Opponent/OpponentActionsInterface.tscn")

var player_data : CharacterData setget set_player_data
var characters_map : Dictionary = {}
var opportunity_owner_map : Dictionary = {}

func add_character_actions(character:CharacterData, scene:PackedScene):
	if character in characters_map:
		return characters_map[character]
	var instance = scene.instance()
	add_child(instance)
	instance.character_data = character
	characters_map[character] = instance
	return instance

func set_player_data(value:CharacterData):
	player_data = value
	add_character_actions(player_data, player_actions_scene)

func add_opponent(opponent:CharacterData):
	return add_character_actions(opponent, opponent_actions_scene)

func defeat_opponent(opponent:CharacterData):
	var interface : ActionsInterface = get_actions_instance(opponent)
	if not interface:
		return
	interface.defeat_character()

func get_actions_instance(character:CharacterData):
	if character in characters_map:
		return characters_map[character]

func add_opportunity_by_character(opportunity:OpportunityData, character:CharacterData):
	if not character in characters_map:
		return
	var interface : ActionsInterface = get_actions_instance(character)
	if not interface:
		return
	return interface.add_opportunity(opportunity)

func remove_opportunity_by_character(opportunity:OpportunityData, character:CharacterData):
	if not character in characters_map:
		return
	var actions_interface = characters_map[character]
	if actions_interface is ActionsInterface:
		actions_interface.remove_opportunity(opportunity)

func add_opportunity(opportunity:OpportunityData):
	var opportunity_owner : CharacterData
	if opportunity.source == player_data and opportunity.target != player_data:
		opportunity_owner = opportunity.target
	else:
		opportunity_owner = opportunity.source
	opportunity_owner_map[opportunity] = opportunity_owner
	return add_opportunity_by_character(opportunity, opportunity_owner)

func remove_opportunity(opportunity:OpportunityData):
	if not opportunity in opportunity_owner_map:
		return
	var opportunity_owner : CharacterData = opportunity_owner_map[opportunity]
	remove_opportunity_by_character(opportunity, opportunity_owner)

func remove_all_opportunities():
	for child in get_children():
		if child is CharacterActionsInterface:
			child.remove_all_opportunities()

func add_status(character:CharacterData, status:StatusData):
	var interface : ActionsInterface = get_actions_instance(character)
	if not is_instance_valid(interface):
		return
	interface.add_status(status)
	return interface

func remove_status(character:CharacterData, status:StatusData):
	var interface : ActionsInterface = get_actions_instance(character)
	if not is_instance_valid(interface):
		return
	interface.remove_status(status)
	return interface

func mark_character_active(character:CharacterData):
	if not character in characters_map:
		return
	var actions_interface : CharacterActionsInterface = characters_map[character]
	if actions_interface == null:
		return
	actions_interface.mark_active()

func mark_character_inactive(character:CharacterData):
	if not character in characters_map:
		return
	var actions_interface : CharacterActionsInterface = characters_map[character]
	if actions_interface == null:
		return
	actions_interface.mark_inactive()
