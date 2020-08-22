extends Node


enum OpportunityType{ATTACK, DEFEND}

var player_data : CharacterData
var opponents_data : Array

func add_opponent(opponent_data:CharacterData):
	if is_instance_valid(opponent_data):
		opponents_data.append(opponent_data)

func get_attack_opportunity(source:CharacterData, target:CharacterData):
	var opportunity = OpportunityData.new()
	opportunity.source = source
	opportunity.target = target
	opportunity.opp_type = OpportunityType.ATTACK
	return opportunity

func get_attack_opportunities(source:CharacterData, target:CharacterData, count:int = 1):
	var opportunities : Array = []
	for _i in range(count):
		opportunities.append(get_defend_opportunity(source, target))
	return opportunities

func get_defend_opportunity(source:CharacterData, target:CharacterData):
	var opportunity = OpportunityData.new()
	opportunity.source = source
	opportunity.target = target
	opportunity.opp_type = OpportunityType.DEFEND
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
		opportunities += get_attack_opportunities(player_data, opponent_data, 2)
	return opportunities

func get_opponent_oppotunities(opponent_data:CharacterData):
	var opportunities : Array = []
	if not opponent_data in opponents_data:
		print("Error: Getting opponent opportunities on unset opponent data.")
		return opportunities
	opportunities += get_attack_opportunities(opponent_data, player_data)
	return opportunities

func get_all_opponent_opportunities():
	var opportunities : Array = []
	for opponent_data in opponents_data: 
		opportunities += get_attack_opportunities(opponent_data, player_data)
	return opportunities
