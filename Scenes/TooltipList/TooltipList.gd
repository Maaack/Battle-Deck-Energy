extends Node2D


class_name TooltipListNode2D

onready var tooltip_container = $VBoxContainer

var tooltip_scene = preload("res://Scenes/TooltipList/DefinitionTooltip/DefinitionTooltip.tscn")

var key_definition_map : Dictionary = {}

func _add_definition_tooltip(term:String, definition:String):
	var tooltip_instance = tooltip_scene.instance()
	tooltip_instance.term = term
	tooltip_instance.definition = definition
	tooltip_container.add_child(tooltip_instance)
	return tooltip_instance

func add_definition_tooltip(definition_data:DefinitionData):
	if definition_data.term in key_definition_map:
		return
	key_definition_map[definition_data.term] = definition_data
	_add_definition_tooltip(definition_data.term, definition_data.definition)
	for sub_definition_data in definition_data.related_definitions:
		if sub_definition_data is DefinitionData:
			add_definition_tooltip(sub_definition_data)

