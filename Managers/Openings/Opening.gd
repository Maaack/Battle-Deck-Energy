extends CenterContainer


class_name BattleOpening

signal card_slot_moved

onready var card_slot_node = $CardSlot
onready var glow_node = $CardSlot/GlowNode
onready var animation_node = $CardSlot/GlowNode/AnimationPlayer

var opportunity_data : OpportunityData setget set_opportunity_data
var assigned_card = null
var transform_data : TransformData

func _ready():
	transform_data = TransformData.new()
	transform_data.scale = Vector2(0.5, 0.5)

func _to_string():
	return "BattleOpening:%d" % get_instance_id()

func set_opportunity_data(value:OpportunityData):
	opportunity_data = value
	if is_instance_valid(card_slot_node):
		card_slot_node.allowed_types = opportunity_data.allowed_types

func get_source():
	return opportunity_data.source

func get_target():
	return opportunity_data.target
	
func is_open():
	return opportunity_data.is_open()

func glow_on():
	glow_node.glow_on()

func glow_off():
	glow_node.glow_off()

func glow_special():
	glow_node.glow_special()

func _on_CardSlot_item_rect_changed():
	emit_signal("card_slot_moved")
