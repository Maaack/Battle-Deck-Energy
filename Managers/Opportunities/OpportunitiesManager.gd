extends Node


class_name OpportunitiesManager

var opportunities : Array = []

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

func add_opportunity(type:int, source:CharacterData, target:CharacterData):
	if not source.is_alive() or not target.is_alive():
		return
	var opportunity = _new_opportunity(type, source, target)
	EventBus.opportunity_added.emit(opportunity)
	return opportunity

func remove_opportunity(opportunity:OpportunityData):
	var remove_index = opportunities.find(opportunity)
	if remove_index >= 0:
		opportunities.remove_at(remove_index)
		EventBus.opportunity_removed.emit(opportunity)

func get_matching_opportunity(source:CharacterData, target:CharacterData, type : int):
	for opportunity in opportunities:
		if opportunity is OpportunityData:
			if opportunity.source == source \
			and opportunity.target == target \
			and opportunity.type == type:
				return opportunity
