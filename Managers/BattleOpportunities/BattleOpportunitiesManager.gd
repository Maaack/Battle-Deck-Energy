extends Node


signal opportunity_added(opportunity)
signal opportunity_removed(opportunity)

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

func _new_opportunity(type:int, source:CharacterData, target:CharacterData):
	var opportunity = OpportunityData.new()
	opportunity.source = source
	opportunity.target = target
	opportunity.type = type
	character_map[source].append(opportunity)
	return opportunity

func add_opportunity(type:int, source:CharacterData, target:CharacterData):
	var opportunity = _new_opportunity(type, source, target)
	emit_signal("opportunity_added", opportunity)
	return opportunity

func add_opportunities(type, source:CharacterData, target:CharacterData, count:int = 1):
	var opportunities : Array = []
	for _i in range(count):
		opportunities.append(add_opportunities(type, source, target))
	return opportunities

func reset_player_opportunities():
	character_map[player_data].clear()
	if not is_instance_valid(player_data):
		print("Error: Getting player opportunities with no player set.")
		return
	for opponent in opponents_data: 
		add_opportunity(CardData.CardType.ATTACK, player_data, opponent)
	add_opportunity(CardData.CardType.DEFEND, player_data, player_data)
	add_opportunity(CardData.CardType.SKILL, player_data, player_data)

func reset_opponent_opportunities(opponent:CharacterData):
	if not opponent in opponents_data:
		print("Error: Getting opponent opportunities on unset opponent data.")
		return
	add_opportunity(CardData.CardType.DEFEND, opponent, opponent)
	add_opportunity(CardData.CardType.SKILL, opponent, opponent)
	add_opportunity(CardData.CardType.ATTACK, opponent, player_data)

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
