extends Node


signal opportunity_added(opportunity)
signal opportunity_removed(opportunity)

var character_map : Dictionary = {}

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
	if not target.is_alive():
		return
	var opportunity = _new_opportunity(type, source, target)
	emit_signal("opportunity_added", opportunity)
	return opportunity

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
