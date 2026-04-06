extends Node2D


@onready var animation_node = $AnimationPlayer
@onready var glow_panel = $GlowPanel

@export var glow_on_style: StyleBox
@export var glow_not_style: StyleBox
@export var glow_special_style: StyleBox

func glow_on():
	show()
	glow_panel.set('theme_override_styles/panel', glow_on_style)
	animation_node.play("Glow")

func glow_not():
	show()
	glow_panel.set('theme_override_styles/panel', glow_not_style)
	animation_node.play("Glow")

func glow_special():
	show()
	glow_panel.set('theme_override_styles/panel', glow_special_style)
	animation_node.play("Glow")

func glow_off():
	var current_position : float = animation_node.current_animation_position
	animation_node.play("GlowNoLoop")
	animation_node.seek(current_position)
	await animation_node.animation_finished
	hide()
