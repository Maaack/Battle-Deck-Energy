extends HBoxContainer


@onready var player_actions_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/CharacterActionsInterface/Player/PlayerActionsInterface.tscn")
@onready var opponent_actions_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/CharacterActionsInterface/Opponent/OpponentActionsInterface.tscn")

var player_data : CharacterData: set = set_player_data
var characters_map : Dictionary = {}
var opportunities : Array[OpportunityData]
var opportunity_owner_map : Dictionary = {}
var opportunity_container_map : Dictionary = {}

func add_character_actions(character:CharacterData, scene:PackedScene):
	if character in characters_map:
		return characters_map[character]
	var instance = scene.instantiate()
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
	var container = add_opportunity_by_character(opportunity, opportunity_owner)
	opportunity_owner_map[opportunity] = opportunity_owner
	opportunity_container_map[opportunity] = container
	opportunities.append(opportunity)
	return container

func remove_opportunity(opportunity:OpportunityData):
	if not opportunity in opportunity_owner_map:
		return
	var opportunity_owner : CharacterData = opportunity_owner_map[opportunity]
	remove_opportunity_by_character(opportunity, opportunity_owner)
	opportunity_owner_map.erase(opportunity)
	opportunity_container_map.erase(opportunity)
	opportunities.erase(opportunity)

func remove_all_opportunities():
	for child in get_children():
		if child is CharacterActionsInterface:
			child.remove_all_opportunities()
	opportunity_owner_map.clear()
	opportunity_container_map.clear()
	opportunities.clear()

func update_status(character:CharacterData, status:StatusData):
	var interface : ActionsInterface = get_actions_instance(character)
	if not is_instance_valid(interface):
		return
	interface.update_status(status)
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

func _on_active_character_updated(character:CharacterData):
	mark_character_active(character)

func _on_turn_ended(character:CharacterData):
	mark_character_inactive(character)

func _on_opportunity_added(opportunity:OpportunityData):
	add_opportunity(opportunity)

func _on_opportunity_removed(opportunity:OpportunityData):
	remove_opportunity(opportunity)

func _on_opportunities_reset():
	remove_all_opportunities()

func get_opportunity_container(opportunity:OpportunityData) -> Control:
	if not opportunity in opportunity_container_map:
		return
	return opportunity_container_map[opportunity]

func get_character_sourced_opportunities(character:CharacterData) -> Array:
	var character_opportunities : Array
	for opportunity in opportunities:
		if opportunity.source == character:
			character_opportunities.append(opportunity)
	return character_opportunities

func get_all_opportunities() -> Array:
	return opportunities

func _ready():
	EventBus.active_character_updated.connect(_on_active_character_updated)
	EventBus.turn_ended.connect(_on_turn_ended)
	EventBus.opportunity_added.connect(_on_opportunity_added)
	EventBus.opportunity_removed.connect(_on_opportunity_removed)
	EventBus.opportunities_reset.connect(_on_opportunities_reset)
