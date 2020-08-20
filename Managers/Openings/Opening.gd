extends CenterContainer


class_name BattleOpening

onready var glow_node = $CardSlot/GlowNode
onready var animation_node = $CardSlot/GlowNode/AnimationPlayer

func _to_string():
	return "BattleOpening:%d" % get_instance_id()

func get_opening_global_position():
	return $CardSlot.rect_global_position

func glow_on():
	glow_node.show()
	animation_node.play("GlowAnimation")

func glow_off():
	glow_node.hide()
	animation_node.stop()
