extends Control


signal glow_on
signal glow_off
signal pressed

onready var button_node = $Button
onready var glow_node = $CenterContainer/Control/GlowNode
onready var animation_node = $CenterContainer/Control/GlowNode/GlowAnimationPlayer

var hovering : bool = false
var pressed : bool = false
var glowing : bool = false

func _on_Button_mouse_entered():
	hovering = true
	_update_glow()

func _on_Button_mouse_exited():
	hovering = false
	_update_glow()

func _on_Button_button_down():
	pressed = true
	_update_glow()

func _on_Button_button_up():
	pressed = false
	_update_glow()

func _update_glow():
	if hovering and not pressed and not button_node.disabled:
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

func _on_Button_pressed():
	emit_signal("pressed", self)
	button_node.disabled = true
