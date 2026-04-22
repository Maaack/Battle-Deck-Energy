extends Node


class_name OpportunitiesManager

var opportunities : Array[OpportunityData]

func reset():
	opportunities.clear()
	EventBus.opportunities_reset.emit()

func _new_opportunity(type:int, source:CharacterData, target:CharacterData):
	var opportunity = OpportunityData.new()
	opportunity.source = source
	opportunity.target = target
	opportunity.type = type
	opportunities.append(opportunity)
	return opportunity

func get_matching_opportunities(type:int, source:CharacterData, target:CharacterData) -> Array[OpportunityData]:
	var match_func := func(data:OpportunityData): return data.type == type and data.source == source and data.target == target
	return opportunities.filter(match_func)

func get_matching_opportunity(type : int, source:CharacterData, target:CharacterData) -> OpportunityData:
	var matching_opportunities := get_matching_opportunities(type, source, target)
	if matching_opportunities.is_empty():
		return
	return matching_opportunities[0]

func add_opportunity(type:int, source:CharacterData, target:CharacterData):
	if not source.is_alive() or not target.is_alive():
		return
	var opportunity = _new_opportunity(type, source, target)
	EventBus.opportunity_added.emit(opportunity)
	return opportunity

func remove_opportunity_instance(opportunity:OpportunityData):
	var remove_index = opportunities.find(opportunity)
	if remove_index >= 0:
		opportunities.remove_at(remove_index)
		EventBus.opportunity_removed.emit(opportunity)

func remove_opportunity(type:int, source:CharacterData, target:CharacterData):
	var opportunity := get_matching_opportunity(type, source, target)
	remove_opportunity_instance(opportunity)

func modify_opportunities(type:int, source:CharacterData, target:CharacterData, modifier:float):
	var match_func := func(accum:int, data:OpportunityData): return accum + 1 if data.type == type and data.source == source and data.target == target else accum
	var current_count : int = opportunities.reduce(match_func, 0)
	var modified_count := floori(modifier * current_count)
	var opportunity_delta = modified_count - current_count
	if opportunity_delta > 0:
		for i in range(opportunity_delta):
			add_opportunity(type, source, target)
	elif opportunity_delta < 0:
		for i in range(-opportunity_delta):
			remove_opportunity(type, source, target)

func _on_character_died(character:CharacterData):
	var _opportunities = opportunities.duplicate()
	for opportunity in _opportunities:
		if opportunity.target == character:
			remove_opportunity_instance(opportunity)

func _ready():
	EventBus.character_died.connect(_on_character_died)
