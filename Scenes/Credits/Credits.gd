extends Control


signal continue_pressed

onready var scroll_container = $ScrollContainer
onready var rich_text_label = $ScrollContainer/RichTextLabel
onready var scroll_timer = $ScrollResetTimer
onready var heading_fonts : Array = [h1_font, h2_font, h3_font, h4_font]

export(String) var attribution_file_path : String = "res://ATTRIBUTION.md"
export(DynamicFont) var h1_font
export(DynamicFont) var h2_font
export(DynamicFont) var h3_font
export(DynamicFont) var h4_font
export(int) var lines_prefixed : int = 22
export(int) var lines_suffixed : int = 25
export(float) var max_speed_down : float = 5.0
export(float) var accel_down : float = 0.01

var current_speed : float = 1

func load_file(file_path):
	var file : File = File.new()
	file.open(file_path, File.READ)
	var text : String = file.get_as_text()
	file.close()
	return text

func regex_replace_urls(credits:String):
	var regex = RegEx.new()
	var match_string : String = "\\[([^\\]]*)\\]\\(([^\\)]*)\\)"
	var replace_string : String = "[url=$2]$1[/url]"
	regex.compile(match_string)
	return regex.sub(credits, replace_string, true)

func regex_replace_titles(credits:String):
	print(heading_fonts)
	var iter = 0
	for heading_font in heading_fonts:
		if heading_font is DynamicFont:
			iter += 1
			var regex = RegEx.new()
			var match_string : String = "([^#])#{%d} ([^\n]*)" % iter
			var replace_string : String = "$1[font=%s]$2[/font]" % [heading_font.resource_path]
			regex.compile(match_string)
			credits = regex.sub(credits, replace_string, true)
	return credits

func _ready():
	var text : String = load_file(attribution_file_path)
	text = text.right(text.find("\n")) # Trims first line "ATTRIBUTION"
	text = regex_replace_urls(text)
	text = regex_replace_titles(text)
	var prefix_lines = "\n".repeat(lines_prefixed)
	var suffix_lines = "\n".repeat(lines_suffixed)
	rich_text_label.bbcode_text = "%s[center]%s[/center]%s" % [prefix_lines, text, suffix_lines]

func _process(delta):
	current_speed += accel_down
	if current_speed > max_speed_down:
		current_speed = max_speed_down
	if round(current_speed) > 0:
		var previous_scroll = scroll_container.scroll_vertical
		scroll_container.scroll_vertical += round(current_speed)
		if previous_scroll == scroll_container.scroll_vertical:
			set_process(false)

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
