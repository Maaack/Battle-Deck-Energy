extends Control


class_name ScrollingTextPanel

signal continue_pressed

onready var scroll_container = $MarginContainer/ScrollContainer
onready var rich_text_label = $MarginContainer/ScrollContainer/RichTextLabel
onready var scroll_timer = $ScrollResetTimer

export(float) var max_speed_down : float = 2.0
export(float) var accel_down : float = 0.01

var current_speed : float = 1

func _process(delta):
	current_speed += accel_down
	if current_speed > max_speed_down:
		current_speed = max_speed_down
	if round(current_speed) > 0:
		var previous_scroll = scroll_container.scroll_vertical
		scroll_container.scroll_vertical += round(current_speed)
		if previous_scroll == scroll_container.scroll_vertical:
			set_process(false)

func set_text(bbcode:String):
	rich_text_label.bbcode_text = bbcode

func _on_RichTextLabel_gui_input(event):
	if event is InputEventMouseButton:
		current_speed = 0
		set_process(false)
		scroll_timer.start()

func _on_ScrollResetTimer_timeout():
	set_process(true)

func _on_ContinueButton_pressed():
	emit_signal("continue_pressed")
	queue_free()
