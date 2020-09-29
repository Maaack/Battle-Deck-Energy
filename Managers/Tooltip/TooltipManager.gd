extends Control


var tooltip_list_scene = preload("res://Scenes/TooltipList/TooltipList.tscn")

export(Array, Resource) var term_definitions : Array = [] setget set_term_definitions

var key_definition_map : Dictionary = {}

func _reset_key_definition_map():
	key_definition_map.clear()
	for definition_data in term_definitions:
		if definition_data is DefinitionData:
			key_definition_map[definition_data.key] = definition_data

func _reset_tooltips():
	for child in get_children():
		child.queue_free()

func reset():
	_reset_tooltips()

func set_term_definitions(value:Array):
	term_definitions = value
	_reset_key_definition_map()

func define_key(key:String, list_instance:TooltipListNode2D):
	if not key in key_definition_map:
		return
	var definition_data : DefinitionData = key_definition_map[key]
	list_instance.add_definition_tooltip(definition_data)

func show_definitions(keys:Array, list_position:Vector2):
	_reset_tooltips()
	var tooltip_list_instance : TooltipListNode2D = tooltip_list_scene.instance()
	tooltip_list_instance.position = list_position
	add_child(tooltip_list_instance)
	for key in keys:
		define_key(key, tooltip_list_instance)

func inspect_card(card_node:CardNode2D):
	var keys : Array = []
	var half_width : float = get_rect().size.x / 2.0
	var card_position : Vector2 = card_node.get_global_transform().get_origin()
	var list_position : Vector2 = card_node.right_tooltip_target.global_position
	if card_position.x > half_width:
		list_position = card_node.left_tooltip_target.global_position
	for effect_data in card_node.card_data.effects:
		if effect_data is StatusEffectData:
			for status_data in effect_data.statuses:
				if status_data is StatusData:
					keys.append(status_data.type_tag)
		elif effect_data is EffectData:
			keys.append(effect_data.type_tag)
	show_definitions(keys, list_position)
