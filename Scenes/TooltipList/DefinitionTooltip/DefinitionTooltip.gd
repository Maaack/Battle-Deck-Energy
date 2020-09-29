extends PanelContainer


onready var term_label = $MarginContainer/VBoxContainer/TermLabel
onready var definition_label = $MarginContainer/VBoxContainer/DefinitionLabel

var term : String = ""
var definition : String = ""

func _ready():
	term_label.text = term
	definition_label.bbcode_text = "[center]%s[/center]" % definition
