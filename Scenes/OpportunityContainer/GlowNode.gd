extends Node2D


onready var animation_node = $AnimationPlayer
onready var glow_panel = $GlowPanel

export(StyleBox) var glow_on_style
export(StyleBox) var glow_not_style
export(StyleBox) var glow_special_style

func glow_on():
	show()
	glow_panel.set('custom_styles/panel', glow_on_style)
	animation_node.play("Glow")

func glow_not():
	show()
	glow_panel.set('custom_styles/panel', glow_not_style)
	animation_node.play("Glow")

func glow_special():
	show()
	glow_panel.set('custom_styles/panel', glow_special_style)
	animation_node.play("Glow")

func glow_off():
	var current_position : float = animation_node.current_animation_position
	animation_node.play("GlowNoLoop")
	animation_node.seek(current_position)
	yield(animation_node, "animation_finished")
	hide()
