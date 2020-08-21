extends CenterContainer


class_name BattleOpening

onready var glow_node = $CardSlot/GlowNode
onready var animation_node = $CardSlot/GlowNode/AnimationPlayer

var assigned_card = null
var prs_data : PRSData = PRSData.new()

func _to_string():
	return "BattleOpening:%d" % get_instance_id()

func get_global_position():
	return $CardSlot.rect_global_position

func get_prs_data():
	prs_data.position = get_global_position()
	prs_data.scale = Vector2(0.5,0.5)
	return prs_data

func glow_on():
	glow_node.show()
	animation_node.play("GlowAnimation")

func glow_off():
	glow_node.hide()
	animation_node.stop()
