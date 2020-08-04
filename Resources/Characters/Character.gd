extends Resource


class_name Character

export(Array, PackedScene) var starting_deck : Array = []
export(int, 0, 64) var starting_max_health : int = 20
export(int, 0, 8) var starting_max_energy: int = 3
export(int, 0, 16) var starting_hand_size: int = 5

var deck : Array = []
var max_health : int = 0
var max_energy : int = 0
var health : int = 0
var energy : int = 0
var hand_size : int = 0

func _to_string():
	return str(deck)

func deck_size():
	return deck.size()

func start():
	if starting_deck is Array:
		deck = starting_deck.duplicate()
	if starting_max_health > 0:
		max_health = starting_max_health
		health = max_health
	if starting_max_energy > 0:
		max_energy = starting_max_energy
		energy = max_energy
	if starting_hand_size > 0 :
		hand_size = starting_hand_size
