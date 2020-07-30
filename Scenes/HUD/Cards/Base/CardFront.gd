tool
extends Node2D


class_name Card

signal glow_on
signal glow_off
signal discard

onready var glow_node = $Control/CenterContainer/Control/GlowNode
onready var animation_node = $Control/CenterContainer/Control/GlowNode/AnimationPlayer

export(Resource) var card_settings setget set_card_settings

var hovering : bool = false
var pressed : bool = false
var glowing : bool = false


func set_card_settings(value:CardSettings):
	card_settings = value
	_update_card_front()

func _ready():
	_update_card_front()

func _update_card_front():
	if not is_instance_valid(card_settings):
		return
	if card_settings.title != "":
		$Control/CardFront/TitlePanel/TitleLabel.text = card_settings.title
	if card_settings.description != "":
		$Control/CardFront/DescriptionPanel/MarginContainer/DescriptionLabel.text = card_settings.description
	if card_settings.bde_cost >= 0:
		$Control/BDEPanel/BDECostLabel.text = str(card_settings.bde_cost)

func _update_glow():
	if hovering and not pressed:
		if not glowing:
			glowing = true
			emit_signal("glow_on", self)
		glow_node.show()
		animation_node.play("Glow")
	else:
		if glowing:
			glowing = false
			emit_signal("glow_off", self)
		glow_node.hide()
		animation_node.stop()

func _on_CardFront_mouse_entered():
	hovering = true
	_update_glow()

func _on_CardFront_mouse_exited():
	hovering = false
	_update_glow()

func _on_CardFront_gui_input(event):
	if event is InputEventMouseButton and not event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				emit_signal("discard")
