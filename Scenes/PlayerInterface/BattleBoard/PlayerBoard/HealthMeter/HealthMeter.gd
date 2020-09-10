extends Control


const LABEL_STR = "%d / %d"

onready var health_bar = $MarginContainer/HealthBar
onready var health_label = $MarginContainer/HealthBar/HealthLabel

var health : int = 10 setget set_health
var max_health : int = 10 setget set_max_health

func _update_meter():
	if health >= 0 and max_health >= 0:
		health_label.text = LABEL_STR % [health, max_health]
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
