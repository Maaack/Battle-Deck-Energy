tool
extends RichTextEffect

# Syntax: [card_effect mod=0][/card_effect]

# Define the tag name.
var bbcode = "card_effect"
var lower_color : Color = Color("#cc0000")
var higher_color : Color = Color("#00aa00")

func _process_custom_fx(char_fx):
	# Get parameters, or use the provided default value if missing.
	var mod = char_fx.env.get("mod", 0)
	if not int(mod):
		return true
	if mod > 0:
		char_fx.color = higher_color
	elif mod < 0:
		char_fx.color = lower_color
	return true
