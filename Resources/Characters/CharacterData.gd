extends Resource


class_name CharacterData

export(String) var nickname : String = 'You'
export(int, 0, 1024) var starting_max_health : int = 20 setget set_starting_max_health
export(int, 0, 8) var starting_max_energy: int = 3 setget set_starting_max_energy
export(int, 0, 16) var starting_hand_size: int = 5 setget set_starting_hand_size
export(Array, Resource) var starting_deck : Array = [] setget set_starting_deck

var deck : Array = []
var max_health : int = 0
var max_energy : int = 0
var health : int = 0
var energy : int = 0
var hand_size : int = 0

func _to_string():
	return "Character:%d" % get_instance_id()

func is_alive():
	return health > 0

func reset_health():
	if starting_max_health > 0:
		max_health = starting_max_health
		health = max_health

func _reset_starting_energy():
	if starting_max_energy > 0:
		max_energy = starting_max_energy
		energy = max_energy

func reset_hand_size():
	if starting_hand_size > 0 :
		hand_size = starting_hand_size

func reset_deck():
	for card in starting_deck:
		deck.append(card.duplicate())

func set_starting_deck(value:Array):
	starting_deck = value
	reset_deck()

func set_starting_max_health(value:int):
	starting_max_health = value
	reset_health()

func set_starting_max_energy(value:int):
	starting_max_energy = value
	_reset_starting_energy()

func set_starting_hand_size(value:int):
	starting_hand_size = value
	reset_hand_size()

func deck_size():
	return deck.size()
