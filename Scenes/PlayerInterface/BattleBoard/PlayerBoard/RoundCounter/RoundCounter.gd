tool
extends Control


onready var count_label = $TextureRect/Panel/CountLabel

var battle_round : int = 0 setget set_battle_round

func _update_battle_round_count():
	if battle_round >= 0:
		count_label.text = str(battle_round)

func set_battle_round(value:int):
	battle_round = value
	_update_battle_round_count()

func _ready():
	_update_battle_round_count()

func advance_round():
	battle_round += 1
	_update_battle_round_count()
