extends CenterContainer


class_name BattleOpening

signal card_slot_moved

onready var card_slot_node = $CardSlot
onready var glow_node = $CardSlot/GlowNode
onready var animation_node = $CardSlot/GlowNode/AnimationPlayer

var opportunity_data : OpportunityData
var assigned_card = null
var prs_data : PRSData

func _ready():
	prs_data = PRSData.new()
	prs_data.scale = Vector2(0.5, 0.5)

func _to_string():
	return "BattleOpening:%d" % get_instance_id()

func is_open():
	return opportunity_data.is_open()

func glow_on():
	glow_node.show()
	animation_node.play("GlowAnimation")

func glow_off():
	glow_node.hide()
	animation_node.stop()

func _on_CardSlot_item_rect_changed():
	emit_signal("card_slot_moved")
