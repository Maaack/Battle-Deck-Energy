extends Control


signal path_selected(level:BattleLevelData)

const TEXT_STRING : String = "[b][i][font_size=64][color=%s]%s - %d[/color][/font_size]\nwith %d %s[/i][/b]"

@export var unknown_color : Color
@export var grapple_color : Color
@export var rogue_color : Color
@export var toxic_color : Color
@export_group("Levels")
@export var left_level : BattleLevelData
@export var right_level : BattleLevelData

@onready var left_text_label = %LeftTextLabel
@onready var right_text_label = %RightTextLabel

func get_loot_color_for_level(level:BattleLevelData) -> Color:
	match(level.loot_type):
		BattleLevelData.LootType.GRAPPLE:
			return grapple_color
		BattleLevelData.LootType.ROGUE:
			return rogue_color
		BattleLevelData.LootType.TOXIC:
			return toxic_color
		_:
			return unknown_color

func get_loot_text_for_level(level:BattleLevelData) -> String:
	match(level.loot_type):
		BattleLevelData.LootType.GRAPPLE:
			return "Grapple"
		BattleLevelData.LootType.ROGUE:
			return "Rogue"
		BattleLevelData.LootType.TOXIC:
			return "Toxic"
		_:
			return "Unknown"

func set_label_text(label:RichTextLabel, level:LevelData):
	var loot_color := get_loot_color_for_level(level).to_html()
	var loot_text := get_loot_text_for_level(level)
	var enemy_text := "Enemy"
	if level.opponents.size() > 1:
		enemy_text = "Enemies"
	label.text = TEXT_STRING % [loot_color, loot_text, level.rank, level.opponents.size(), enemy_text]

func refresh():
	set_label_text(left_text_label, left_level)
	set_label_text(right_text_label, right_level)

func _ready():
	refresh()


func _on_left_button_pressed():
	path_selected.emit(left_level)
	queue_free()

func _on_right_button_pressed():
	path_selected.emit(right_level)
	queue_free()
