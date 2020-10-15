extends Control


const LABEL_STR = "%d / %d"

onready var current_energy_label = $Panel/CurrentLabel
onready var max_energy_label = $Panel/MaxLabel

var energy : int = 3 setget set_energy
var max_energy : int = 3 setget set_max_energy

func _update_meter():
	if energy >= 0 and max_energy >= 0:
		current_energy_label.text = str(energy)
		max_energy_label.text = str(max_energy)
	
func set_energy(value:int):
	energy = value
	_update_meter()
	
func set_max_energy(value:int):
	max_energy = value
	_update_meter()

func set_energy_values(value: int, max_value: int):
	energy = value
	max_energy = max_value
	_update_meter()
