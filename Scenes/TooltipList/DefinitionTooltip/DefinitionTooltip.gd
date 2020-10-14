extends PanelContainer


const TERM_BBCODE_STRING = "[center][b]%s[/b][/center]"
const DEFINITION_BBCODE_STRING = "[center]%s[/center]"

onready var term_label = $MarginContainer/VBoxContainer/TermLabel
onready var definition_label = $MarginContainer/VBoxContainer/DefinitionLabel

var term : String = ""
var definition : String = ""

func _ready():
	term_label.bbcode_text = TERM_BBCODE_STRING % term
	definition_label.bbcode_text = DEFINITION_BBCODE_STRING % definition
