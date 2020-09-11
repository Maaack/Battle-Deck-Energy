extends Control


const HEALTH_LABEL_STR = "%d / %d"
const ARMOR_LABEL_STR = "%d"

onready var health_bar = $MarginContainer/HealthBar
onready var health_label = $MarginContainer/HealthBar/HealthLabel
onready var armor_icon = $ArmorIcon
onready var armor_label = $ArmorIcon/ArmorLabel

export(StyleBox) var fg_normal : StyleBox = preload("res://Themes/StyleBoxes/Meters/HealthMeterStyleBox.tres")
export(StyleBox) var bg_normal : StyleBox = preload("res://Themes/StyleBoxes/Meters/HealthMeterBGStyleBox.tres")
export(StyleBox) var fg_armored : StyleBox = preload("res://Themes/StyleBoxes/Meters/HealthMeterArmoredStyleBox.tres")
export(StyleBox) var bg_armored : StyleBox = preload("res://Themes/StyleBoxes/Meters/HealthMeterArmoredBGStyleBox.tres")

var health : int = 10 setget set_health
var max_health : int = 10 setget set_max_health
var armor : int = 0 setget set_armor

func _update_meter():
	if health >= 0 and max_health >= 0:
		health_label.text = HEALTH_LABEL_STR % [health, max_health]
		health_bar.value = health
		health_bar.max_value = max_health

func set_health(value:int):
	health = value
	_update_meter()
	
func set_max_health(value:int):
	max_health = value
	_update_meter()

func set_health_values(value:int, max_value:int):
	health = value
	max_health = max_value
	_update_meter()

func set_armor(value:int):
	armor = value
	if armor > 0:
		armor_icon.show()
		health_bar.set("custom_styles/fg", fg_armored)
		health_bar.set("custom_styles/bg", bg_armored)
	else:
		armor_icon.hide()
		health_bar.set("custom_styles/fg", fg_normal)
		health_bar.set("custom_styles/bg", bg_normal)
	armor_label.text = ARMOR_LABEL_STR % armor
