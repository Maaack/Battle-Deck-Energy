extends Control


var tooltip_list_scene = preload("res://Scenes/TooltipList/TooltipList.tscn")

@export var list_position_margin: float = 132
@onready var file_lister = $FileLister

var key_definition_map : Dictionary = {}

func _reset_key_definition_map():
	key_definition_map.clear()
	for path in file_lister.files:
		var definition_data = load(path)
		if definition_data is DefinitionData:
			key_definition_map[definition_data.key] = definition_data

func _reset_tooltips():
	for child in get_children():
		child.queue_free()

func reset():
	_reset_tooltips()

func _ready():
	_reset_key_definition_map()
	EventBus.card_inspected.connect(_on_card_inspected)
	EventBus.card_restored.connect(_on_card_restored)
	EventBus.status_inspected.connect(_on_status_inspected)
	EventBus.status_restored.connect(_on_status_restored)

func define_key(key:String, list_instance:TooltipListNode2D):
	if not key in key_definition_map:
		return
	var definition_data : DefinitionData = key_definition_map[key]
	list_instance.add_definition_tooltip(definition_data)

func show_definitions(keys:Array, list_position:Vector2, list_upward:bool = false):
	_reset_tooltips()
	var tooltip_list_instance : TooltipListNode2D = tooltip_list_scene.instantiate()
	tooltip_list_instance.position = list_position
	add_child(tooltip_list_instance)
	if list_upward:
		tooltip_list_instance.tooltip_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
		tooltip_list_instance.tooltip_container.position.y -= tooltip_list_instance.tooltip_container.size.y
	for key in keys:
		define_key(key, tooltip_list_instance)

func _on_card_inspected(card_node:CardNode2D):
	var keys : Array = []
	var half_width : float = get_rect().size.x / 2.0
	var half_height : float = get_rect().size.y / 2.0
	var card_position : Vector2 = card_node.get_global_transform().get_origin()
	var list_position : Vector2 = card_node.right_tooltip_target.global_position
	var list_upward : bool = false
	if card_position.x > half_width:
		list_position = card_node.left_tooltip_target.global_position
	for effect_data in card_node.card_data.effects:
		if effect_data is StatusEffectData:
			for status_data in effect_data.statuses:
				if status_data is StatusData:
					keys.append(status_data.type_tag)
		elif effect_data is EffectData:
			keys.append(effect_data.type_tag)
	if card_position.y > half_height and keys.size() > 1:
		list_upward = true
		list_position = card_node.bottom_right_tooltip_target.global_position
		if card_position.x > half_width:
			list_position = card_node.bottom_left_tooltip_target.global_position
	show_definitions(keys, list_position, list_upward)

func _on_card_restored(_card_node:CardNode2D):
	reset()

func _on_status_inspected(status_icon:StatusIcon):
	var list_position : Vector2 = status_icon.tooltip_target.global_position
	if list_position.x < list_position_margin:
		list_position.x = list_position_margin
	if list_position.x > get_rect().size.x - list_position_margin:
		list_position.x = get_rect().size.x - list_position_margin
	var keys : Array = [status_icon.status_data.type_tag]
	show_definitions(keys, list_position)

func _on_status_restored(status_icon:StatusIcon):
	reset()
