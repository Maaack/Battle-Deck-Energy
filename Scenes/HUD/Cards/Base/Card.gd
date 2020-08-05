tool
extends Node2D


class_name Card

signal glow_on
signal glow_off
signal discard
signal position_reached

onready var glow_node = $Control/CenterContainer/Control/GlowNode
onready var animation_node = $Control/CenterContainer/Control/GlowNode/AnimationPlayer
onready var tween_node = $CardTween

export(Resource) var init_card_settings setget set_init_card_settings

var card_settings : CardSettings
var hovering : bool = false
var pressed : bool = false
var glowing : bool = false
var discarding : bool = false
var exhausting : bool = false
var packed_scene : PackedScene setget set_packed_scene
var _moving_to_position = null


func set_init_card_settings(value:CardSettings):
	init_card_settings = value
	if init_card_settings is CardSettings:
		card_settings = init_card_settings
	_update_card_front()

func set_packed_scene(value:PackedScene):
	packed_scene = value

func get_energy_cost():
	if card_settings is CardSettings:
		return card_settings.energy_cost

func _ready():
	_update_card_front()

func _update_card_front():
	if not is_instance_valid(card_settings):
		return
	if card_settings.title != "":
		$Control/CardFront/TitlePanel/TitleLabel.text = card_settings.title
	if card_settings.description != "":
		$Control/CardFront/DescriptionPanel/MarginContainer/DescriptionLabel.text = card_settings.description
	if card_settings.energy_cost >= 0:
		$Control/BDEPanel/BDECostLabel.text = str(card_settings.energy_cost)

func _update_glow():
	if hovering and not pressed:
		if not glowing:
			glowing = true
			emit_signal("glow_on", self)
		glow_node.glow_on()
	else:
		if glowing:
			glowing = false
			emit_signal("glow_off", self)
		glow_node.glow_off()

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
				discard()

func discard():
	discarding = true
	emit_signal("discard", self)

func _get_tween_time():
	return 0.5

func tween_to_position(new_position:Vector2, tween_time:float = _get_tween_time()):
	if _moving_to_position == new_position:
		return
	_moving_to_position = new_position
	if is_instance_valid(tween_node):
		if tween_node.is_active():
			tween_node.stop_all()
		tween_node.interpolate_property(self, "position", position, new_position, tween_time)
		tween_node.start()

func _on_CardTween_tween_completed(object, key):
	emit_signal("position_reached", self)
