extends Node


signal opportunity_added(opportunity)
signal opportunity_removed(opportunity)

enum OpportunityType{OPEN, ATTACK, PARRY, DEFEND}

const OPEN_TYPE = 'OPEN'
const ATTACK_TYPE = 'ATTACK'
const DEFEND_TYPE = 'DEFEND'
const PARRY_TYPE = 'PARRY'

export(Array, String) var active_slot_types : Array = [DEFEND_TYPE]
export(Array, String) var offensive_slot_types : Array = [ATTACK_TYPE]
export(Array, String) var parry_slot_types : Array = [PARRY_TYPE]

var player_data : CharacterData setget set_player_data
var opponents_data : Array
var character_map : Dictionary = {}

func set_player_data(value:CharacterData):
	player_data = value
	if is_instance_valid(player_data):
		character_map[player_data] = []

func add_opponent(opponent:CharacterData):
	if is_instance_valid(opponent):
		opponents_data.append(opponent)
		character_map[opponent] = []

func reset():
	for character in character_map:
		character_map[character].clear()

func _new_open_opportunity(source:CharacterData):
	var opportunity = OpportunityData.new()
	opportunity.source = source
	opportunity.opp_type = OpportunityType.OPEN
	opportunity.allowed_types = offensive_slot_types
	character_map[source].append(opportunity)
	return opportunity

func add_open_opportunity(source:CharacterData):
	var opportunity = _new_open_opportunity(source)
	emit_signal("opportunity_added", opportunity)
	return opportunity

func _new_attack_opportunity(source:CharacterData, target:CharacterData):
	var opportunity = OpportunityData.new()
	opportunity.source = source
	opportunity.target = target
	opportunity.opp_type = OpportunityType.ATTACK
	opportunity.allowed_types = offensive_slot_types
	character_map[source].append(opportunity)
	return opportunity

func add_attack_opportunity(source:CharacterData, target:CharacterData):
	var opportunity = _new_attack_opportunity(source, target)
	emit_signal("opportunity_added", opportunity)
	return opportunity

func add_attack_opportunities(source:CharacterData, target:CharacterData, count:int = 1):
	var opportunities : Array = []
	for _i in range(count):
		opportunities.append(add_attack_opportunity(source, target))
	return opportunities

func _new_defend_opportunity(source:CharacterData, target:CharacterData):
	var opportunity = OpportunityData.new()
	opportunity.source = source
	opportunity.target = target
	opportunity.opp_type = OpportunityType.DEFEND
	opportunity.allowed_types = active_slot_types
	character_map[source].append(opportunity)
	return opportunity

func add_defend_opportunity(source:CharacterData, target:CharacterData):
	var opportunity = _new_defend_opportunity(source, target)
	emit_signal("opportunity_added", opportunity)
	return opportunity

func add_defend_opportunities(source:CharacterData, target:CharacterData, count:int = 1):
	var opportunities : Array = []
	for _i in range(count):
		opportunities.append(add_defend_opportunity(source, target))
	return opportunities

func add_opportunity(source:CharacterData, target = null):
	if target is CharacterData:
		if source == target:
			add_defend_opportunity(source, target)
		else:
			add_attack_opportunity(source, target)
	else:
		add_open_opportunity(source)

func reset_player_opportunities():
	character_map[player_data].clear()
	if not is_instance_valid(player_data):
		print("Error: Getting player opportunities with no player set.")
		return
	add_defend_opportunities(player_data, player_data, 3)
	for opponent in opponents_data: 
		add_attack_opportunity(player_data, opponent)

func reset_opponent_opportunities(opponent:CharacterData):
	if not opponent in opponents_data:
		print("Error: Getting opponent opportunities on unset opponent data.")
		return
	add_defend_opportunities(opponent, opponent)
	add_attack_opportunities(opponent, player_data)

func reset_all_opponent_opportunities():
	for opponent in opponents_data: 
		reset_opponent_opportunities(opponent)

func get_character_opportunities(character:CharacterData):
	if not character in character_map:
		return []
	return character_map[character]

func remove_opportunity(opportunity:OpportunityData):
	for character in character_map:
		var opportunities : Array = character_map[character]
		var remove_index = opportunities.find(opportunity)
		if remove_index >= 0:
			opportunities.remove(remove_index)
			emit_signal("opportunity_removed", opportunity)
