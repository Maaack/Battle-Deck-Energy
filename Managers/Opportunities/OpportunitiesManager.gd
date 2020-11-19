extends Node


class_name OpportunitiesManager

signal opportunity_added(opportunity)
signal opportunity_removed(opportunity)
signal opportunities_reset

var opportunities : Array = []

func reset():
	opportunities.clear()
	emit_signal("opportunities_reset")

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
	emit_signal("opportunity_added", opportunity)
	return opportunity

func remove_opportunity(opportunity:OpportunityData):
	var remove_index = opportunities.find(opportunity)
	if remove_index >= 0:
		opportunities.remove(remove_index)
		emit_signal("opportunity_removed", opportunity)

func get_matching_opportunity(source:CharacterData, target:CharacterData, type : int):
	for opportunity in opportunities:
		if opportunity is OpportunityData:
			if opportunity.source == source \
			and opportunity.target == target \
			and opportunity.type == type:
				return opportunity
