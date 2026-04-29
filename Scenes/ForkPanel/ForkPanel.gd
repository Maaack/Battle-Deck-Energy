extends Control


signal path_selected(level:BattleLevelData)

const TEXT_STRING : String = "[b][i][color=%s]%s - %d[/color][/i][/b]"

@export var unknown_color : Color
@export var grapple_color : Color
@export var rogue_color : Color
@export var toxic_color : Color
@export_group("Levels")
@export var left_level : BattleLevelData
@export var right_level : BattleLevelData

@onready var left_text_label = %LeftTextLabel
@onready var right_text_label = %RightTextLabel
@onready var left_icons = %LeftIcons
@onready var right_icons = %RightIcons

func get_color_for_type(loot_type:BattleLevelData.LootType) -> Color:
	match(loot_type):
		BattleLevelData.LootType.GRAPPLE:
			return grapple_color
		BattleLevelData.LootType.ROGUE:
			return rogue_color
		BattleLevelData.LootType.TOXIC:
			return toxic_color
		_:
			return unknown_color

func get_loot_color_for_level(level:BattleLevelData) -> Color:
	return get_color_for_type(level.loot_type)

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

func set_label_text(label:RichTextLabel, level:BattleLevelData):
	var loot_color := get_loot_color_for_level(level).to_html()
	var loot_text := get_loot_text_for_level(level)
	label.text = TEXT_STRING % [loot_color, loot_text, level.rank]

func get_opponent_color(opponent:OpponentCharacterData) -> Color:
	var loot_type := opponent.type as BattleLevelData.LootType
	return get_color_for_type(loot_type)

func set_opponent_icons(container:Control, level:BattleLevelData) -> void:
	var iter := 0
	var count := level.opponents.size()
	for child in container.get_children():
		child.visible = iter < count
		if iter < count:
			child.modulate = get_opponent_color(level.opponents[iter])
		else:
			child.modulate = Color.WHITE
		iter += 1

func refresh():
	set_label_text(left_text_label, left_level)
	set_label_text(right_text_label, right_level)
	set_opponent_icons(left_icons, left_level)
	set_opponent_icons(right_icons, right_level)

func _ready():
	refresh()


func _on_left_button_pressed():
	path_selected.emit(left_level)
	queue_free()

func _on_right_button_pressed():
	path_selected.emit(right_level)
	queue_free()
