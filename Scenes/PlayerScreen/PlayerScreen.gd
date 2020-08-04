extends Control


onready var health_meter = $HealthMeter

var player : Character setget set_player

func set_player(value:Character):
	if value is Character:
		player = value

func update_meter():
	health_meter.max_health = player.max_health
	health_meter.health = player.health
