extends CenterContainer


class_name BattleOpening

signal card_assigned(opp_data, card)

onready var glow_node = $CardSlot/GlowNode
onready var animation_node = $CardSlot/GlowNode/AnimationPlayer

var opportunity_data : OpportunityData
var assigned_card = null setget set_assigned_card
var prs_data : PRSData = PRSData.new()

func _to_string():
	return "BattleOpening:%d" % get_instance_id()

func get_global_position():
	return $CardSlot.rect_global_position

func set_assigned_card(value:CardData):
	assigned_card = value
	if is_instance_valid(assigned_card):
		print("Playing card %s" % assigned_card)
		emit_signal("card_assigned", opportunity_data, assigned_card)

func get_prs_data():
	prs_data.position = get_global_position()
	prs_data.scale = Vector2(0.5,0.5)
	return prs_data

func is_open():
	return opportunity_data.is_open()

func glow_on():
	glow_node.show()
	animation_node.play("GlowAnimation")

func glow_off():
	glow_node.hide()
	animation_node.stop()
