extends HBoxContainer


onready var player_actions_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/PlayerActions/PlayerActions.tscn")
onready var opponent_actions_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/OpponentActions/OpponentActions.tscn")
onready var effect_text_animation_scene = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/StatusTextAnimation/StatusTextAnimation.tscn")

var player_data : CharacterData setget set_player_data
var characters_map : Dictionary = {}

func add_character_actions(character:CharacterData, scene:PackedScene):
	if character in characters_map:
		return characters_map[character]
	var instance = scene.instance()
	instance.character_data = character
	add_child(instance)
	characters_map[character] = instance
	return instance

func set_player_data(value:CharacterData):
	player_data = value
	var instance = add_character_actions(player_data, player_actions_scene)

func add_opponent(opponent:CharacterData):
	var instance = add_character_actions(opponent, opponent_actions_scene)

func defeat_opponent(opponent:CharacterData):
	var interface : ActionsInterface = get_actions_instance(opponent)
	interface.remove_all_openings()
	interface.queue_free()
	characters_map.erase(opponent)

func get_actions_instance(character:CharacterData):
	if character in characters_map:
		return characters_map[character]

func add_opening_by_character(opportunity:OpportunityData, character:CharacterData):
	if character in characters_map:
		var actions_interface = characters_map[character]
		if actions_interface is ActionsInterface:
			return actions_interface.add_opening(opportunity)

func add_opening(opportunity:OpportunityData):
	var opening : BattleOpening
	if opportunity.source == player_data and opportunity.target != player_data:
		opening = add_opening_by_character(opportunity, opportunity.target)
	else:
		opening = add_opening_by_character(opportunity, opportunity.source)
	return opening

func add_openings(opportunities:Array):
	var openings : Array = []
	for opportunity in opportunities:
		if opportunity is OpportunityData:
			var opening : BattleOpening = add_opening(opportunity)
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

func add_status(character:CharacterData, status:StatusData):
	var interface : ActionsInterface = get_actions_instance(character)
	if not is_instance_valid(interface):
		return
	interface.add_status(status)

func remove_status(character:CharacterData, status:StatusData):
	var interface : ActionsInterface = get_actions_instance(character)
	if not is_instance_valid(interface):
		return
	interface.remove_status(status)

func update_status(character:CharacterData, status:StatusData, delta: int):
	var interface : ActionsInterface = get_actions_instance(character)
	if not is_instance_valid(interface):
		return
	var interface_center = Vector2(interface.rect_size.x/2, interface.rect_size.y/2)
	var interface_offset = interface.rect_position + interface_center
	var effect_text_instance = effect_text_animation_scene.instance()
	add_child(effect_text_instance)
	effect_text_instance.position = interface_offset
	effect_text_instance.set_status_update(status, delta)
	interface.add_status(status)
