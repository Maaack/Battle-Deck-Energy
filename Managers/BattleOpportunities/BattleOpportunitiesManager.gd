extends Node


signal opportunity_added(opportunity)

enum OpportunityType{ATTACK, PARRY, DEFEND}

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

func _count_cards_of_type(source:CharacterData, target:CharacterData, type_tag:String):
	var count : int = 0
	if source in character_map:
		var opportunities : Array = character_map[source]
		for opportunity in opportunities:
			if opportunity is OpportunityData:
				if opportunity.target == target and is_instance_valid(opportunity.card_data):
					var card : CardData = opportunity.card_data
					if card.type_tag == type_tag:
						count += 1
	return count

func _count_attacks(source:CharacterData, target:CharacterData):
	return _count_cards_of_type(source, target, ATTACK_TYPE)

func _count_parries(source:CharacterData, target:CharacterData):
	return _count_cards_of_type(source, target, PARRY_TYPE)

func can_parry(source:CharacterData, target:CharacterData):
	var target_attack_count : int = _count_attacks(target, source)
	var parry_count : int = _count_parries(source, target)
	return parry_count < target_attack_count

func _new_attack_opportunity(source:CharacterData, target:CharacterData):
	var opportunity = OpportunityData.new()
	opportunity.source = source
	opportunity.target = target
	opportunity.opp_type = OpportunityType.ATTACK
	opportunity.allowed_types = offensive_slot_types
	if can_parry(source, target):
		opportunity.allowed_types += parry_slot_types
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

func reset_player_opportunities():
	character_map[player_data].clear()
	if not is_instance_valid(player_data):
		print("Error: Getting player opportunities with no player set.")
		return
	for opponent in opponents_data: 
		add_attack_opportunity(player_data, opponent)
	add_defend_opportunities(player_data, player_data, 2)

func reset_opponent_opportunities(opponent:CharacterData):
	if not opponent in opponents_data:
		print("Error: Getting opponent opportunities on unset opponent data.")
		return
	add_attack_opportunities(opponent, player_data)

func reset_all_opponent_opportunities():
	for opponent in opponents_data: 
		reset_opponent_opportunities(opponent)
