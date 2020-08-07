extends Control


const LABEL_STR = "%d / %d"

onready var energy_label = $Panel/Label

var energy : int = 3 setget set_energy
var max_energy : int = 3 setget set_max_energy

func set_energy(value:int):
	energy = value
	_update_meter()
	
func set_max_energy(value:int):
	max_energy = value
	_update_meter()

func _update_meter():
	if energy >= 0 and max_energy >= 0:
		energy_label.text = LABEL_STR % [energy, max_energy]

