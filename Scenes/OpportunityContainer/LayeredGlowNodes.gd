extends Node2D


onready var glow_node = $GlowNode
onready var glow_node_2 = $GlowNode2
onready var glow_delay_timer = $GlowDelayTimer

func glow_on():
	glow_delay_timer.stop()
	glow_node.glow_on()
	glow_delay_timer.start()
	yield(glow_delay_timer, "timeout")
	glow_node_2.glow_on()

func glow_not():
	glow_delay_timer.stop()
	glow_node.glow_not()
	glow_delay_timer.start()
	yield(glow_delay_timer, "timeout")
	glow_node_2.glow_not()

func glow_special():
	glow_delay_timer.stop()
	glow_node.glow_special()
	glow_delay_timer.start()
	yield(glow_delay_timer, "timeout")
	glow_node_2.glow_special()

func glow_off():
	glow_delay_timer.stop()
	glow_node.glow_off()
	glow_delay_timer.start()
	yield(glow_delay_timer, "timeout")
	glow_node_2.glow_off()

