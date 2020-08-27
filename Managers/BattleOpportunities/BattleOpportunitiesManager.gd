extends Node


enum OpportunityType{ATTACK, PARRY, DEFEND}

const ATTACK_TYPE = 'ATTACK'
const DEFEND_TYPE = 'DEFEND'
const PARRY_TYPE = 'PARRY'

export(Array, String) var active_slot_types : Array = [DEFEND_TYPE]
export(Array, String) var offensive_slot_types : Array = [ATTACK_TYPE, PARRY_TYPE]

var player_data : CharacterData
var opponents_data : Array

func add_opponent(opponent:CharacterData):
	if is_instance_valid(opponent):
		opponents_data.append(opponent)

func get_attack_opportunity(source:CharacterData, target:CharacterData):
	var opportunity = OpportunityData.new()
	opportunity.source = source
	opportunity.target = target
	opportunity.opp_type = OpportunityType.ATTACK
	opportunity.allowed_types = offensive_slot_types
	return opportunity

func get_attack_opportunities(source:CharacterData, target:CharacterData, count:int = 1):
	var opportunities : Array = []
	for _i in range(count):
		opportunities.append(get_attack_opportunity(source, target))
	return opportunities

func get_defend_opportunity(source:CharacterData, target:CharacterData):
	var opportunity = OpportunityData.new()
	opportunity.source = source
	opportunity.target = target
	opportunity.opp_type = OpportunityType.DEFEND
	opportunity.allowed_types = active_slot_types
	return opportunity

func get_defend_opportunities(source:CharacterData, target:CharacterData, count:int = 1):
	var opportunities : Array = []
	for _i in range(count):
		opportunities.append(get_defend_opportunity(source, target))
	return opportunities

func get_player_opportunities():
	var opportunities : Array = []
	if not is_instance_valid(player_data):
		print("Error: Getting player opportunities with no player set.")
		return opportunities
	for opponent_data in opponents_data: 
		opportunities += get_attack_opportunities(player_data, opponent_data, 1)
	opportunities += get_defend_opportunities(player_data, player_data, 2)
	return opportunities

func get_opponent_oppotunities(opponent:CharacterData):
	var opportunities : Array = []
	if not opponent in opponents_data:
		print("Error: Getting opponent opportunities on unset opponent data.")
		return opportunities
	opportunities += get_attack_opportunities(opponent, player_data)
	return opportunities

func get_all_opponent_opportunities():
	var opportunities : Array = []
	for opponent_data in opponents_data: 
		opportunities += get_attack_opportunities(opponent_data, player_data)
	return opportunities
