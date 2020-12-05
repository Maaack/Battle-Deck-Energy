extends Control


signal timeout

onready var second_timer = $SecondTimer
onready var label = $Panel/Label
onready var animation_player = $AnimationPlayer

var time : int = 0 setget set_time
var starting_time : int = 0

func _set_timer_text():
	label.text = str(time)

func _set_animations():
	if time == round(float(starting_time) / 4.0):
		animation_player.play("LastSeconds")
	elif time == round(float(starting_time) / 2.0):
		animation_player.play("FadeOutSlow")

func set_time(value : int):
	time = value
	starting_time = value
	_set_timer_text()
	second_timer.start()
	animation_player.play("FadeOutSlow")

func stop_timer():
	second_timer.stop()
	animation_player.play("FadeOutFast")

func _on_SecondTimer_timeout():
	if time == 0:
		return
	time -= 1
	_set_timer_text()
	_set_animations()
	if time == 0:
		emit_signal("timeout")
		stop_timer()
