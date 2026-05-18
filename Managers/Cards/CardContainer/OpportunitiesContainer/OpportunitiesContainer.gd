extends CardContainer


class_name OpportunitiesContainer

signal update_opportunity(opportunity, container)

const ATTACK_ACTIONS_STRING := "attack actions"
const DEFEND_ACTIONS_STRING := "defend actions"
const SKILL_ACTIONS_STRING := "skill actions"
const DEFAULT_ACTIONS_STRING := "actions"
const DEFINITION_STRING := "%d/%d %s available this turn."

@onready var glow_nodes = $CenterContainer/Control/LayeredGlowNodes
@onready var pip_types_container = %PipTypesContainer
@onready var pips_container = %PipsContainer
@onready var pip_slot_texture_rect = %PipSlotTextureRect

@export var cost_color : Color
@export var attack_color : Color
@export var attack_icon : Texture
@export var defend_color : Color
@export var defend_icon : Texture
@export var skill_color : Color
@export var skill_icon : Texture
@export var pip_icon : Texture

var type_map : Dictionary[CardData.CardType, int] = {}
var opportunity_cost : Dictionary[CardData.CardType, int]
var _pips_containers : Array[Node]
var _used_type_map : Dictionary[CardData.CardType, int] = {}
var opportunities : Array[OpportunityData] = []
var _type_pips_containers : Dictionary[CardData.CardType, Control]

func refresh() -> void:
	_update_slots()

func _clear_slots():
	for container in pip_types_container.get_children():
		container.queue_free()

func _setup_pip_slot_texture(type:CardData.CardType, used:bool = false, cost:bool = false) -> TextureRect:
	var texture_rect : TextureRect = pip_slot_texture_rect.duplicate()
	texture_rect.show()
	match(type):
		(CardData.CardType.ATTACK):
			texture_rect.modulate = attack_color
			texture_rect.texture = attack_icon
		(CardData.CardType.DEFEND):
			texture_rect.modulate = defend_color
			texture_rect.texture = defend_icon
		(CardData.CardType.SKILL):
			texture_rect.modulate = skill_color
			texture_rect.texture = skill_icon
	if used or cost:
		var _pip_texture_rect = texture_rect.get_child(0)
		_pip_texture_rect.texture = pip_icon
		_pip_texture_rect.show()
		if cost:
			_pip_texture_rect.modulate.a = 0.66
		else:
			_pip_texture_rect.modulate.a = 1.0
	return texture_rect

func _get_key_for_type(type:CardData.CardType) -> String:
	match(type):
		(CardData.CardType.ATTACK):
			return ATTACK_ACTIONS_STRING
		(CardData.CardType.DEFEND):
			return DEFEND_ACTIONS_STRING
		(CardData.CardType.SKILL):
			return SKILL_ACTIONS_STRING
		_:
			return DEFAULT_ACTIONS_STRING

func _connect_tooltip(control_node:Control, type:CardData.CardType, available:int, total:int):
		var _key := _get_key_for_type(type).capitalize()
		var _definition := DEFINITION_STRING % [available, total, _key]
		control_node.mouse_entered.connect(_on_mouse_entered.bind(control_node, _key, _definition))
		control_node.mouse_exited.connect(_on_mouse_exited.bind(control_node))

func _update_slots():
	_clear_slots()
	var all_types := type_map.merged(_used_type_map)
	for type in all_types:
		var _pips_container := pips_container.duplicate()
		_pips_container.show()
		_pips_containers.append(_pips_container)
		var _used_total := 0
		var _available_total := 0
		if type in _used_type_map:
			_used_total = _used_type_map[type]
			for iter in range(_used_total):
				var _pip_slot_texture := _setup_pip_slot_texture(type, true)
				_pips_container.add_child(_pip_slot_texture)
		if type in type_map:
			var _cost := 0
			_available_total = type_map[type]
			if type in opportunity_cost:
				_cost = opportunity_cost[type]
			for iter in range(_available_total):
				var _pip_slot_texture := _setup_pip_slot_texture(type, false, iter < _cost)
				_pips_container.add_child(_pip_slot_texture)
		_connect_tooltip(_pips_container, type, _available_total, _used_total + _available_total)
		pip_types_container.add_child(_pips_container)
		_type_pips_containers[type] = _pips_container

func add_opportunity(opportunity:OpportunityData):
	if opportunity in opportunities:
		return
	var type := opportunity.type
	if not type in type_map:
		type_map[type] = 0
	type_map[type] += 1
	opportunity.transform_data.scale = get_transform().get_scale()
	opportunities.append(opportunity)
	update_opportunity.emit(opportunity, self)
	refresh()

func use_opportunity(opportunity:OpportunityData):
	if not opportunity in opportunities:
		return
	var type := opportunity.type
	if type not in _used_type_map:
		_used_type_map[type] = 0
	_used_type_map[type] += 1
	refresh()

func remove_opportunity(opportunity:OpportunityData):
	if not opportunity in opportunities:
		return
	var type := opportunity.type
	if type in type_map:
		type_map[type] -= 1
	opportunities.erase(opportunity)
	update_opportunity.emit(opportunity, self)
	refresh()

func clear_opportunities():
	type_map.clear()
	_used_type_map.clear()
	_type_pips_containers.clear()
	opportunities.clear()
	opportunity_cost.clear()
	_clear_slots()

func get_type_count(type_tag:CardData.CardType) -> int:
	if type_tag not in type_map: return 0
	return type_map[type_tag]

func get_count() -> int:
	return opportunities.size()

func glow_on():
	if opportunities.size() == 0: return
	glow_nodes.glow_on()

func glow_off():
	glow_nodes.glow_off()

func glow_special():
	glow_nodes.glow_special()

func flash_opportunity_type(type_tag:CardData.CardType, flashes:int = 4, duration:float = 1.0):
	if type_tag not in _type_pips_containers:
		return
	var container := _type_pips_containers[type_tag]
	var tween := create_tween()
	var _flash_duration := duration / flashes
	for iter in range(flashes):
		tween.tween_property(container, "modulate:a", 0, _flash_duration * 0.5)
		tween.tween_property(container, "modulate:a", 1, _flash_duration * 0.5)

func _ready():
	EventBus.opportunity_used.connect(use_opportunity)
	EventBus.opportunity_removed.connect(remove_opportunity)

func _on_mouse_entered(control_node, key, definition):
	EventBus.node_inspected.emit(control_node, key, definition)

func _on_mouse_exited(control_node):
	EventBus.node_restored.emit(control_node)
