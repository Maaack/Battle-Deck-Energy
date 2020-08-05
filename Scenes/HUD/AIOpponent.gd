extends Resource


class_name AIOpponent

var character : Character setget set_character
var draw_pile : Array = []
var hand : Array = []
var discard_pile : Array = []
var energy : int = 0
var health : int = 0

func set_character(value:Character):
	if value is Character:
		character = value
		discard_pile = character.deck

func start():
	if not is_instance_valid(character):
		print("Error: No character.")
		return
	health = character.max_health
	randomize()
	start_turn()

func draw_cards(count:int = 1):
	for i in range(count):
		if draw_pile.size() < 1:
			reshuffle_discard_pile()
		var card_scene : PackedScene = draw_pile.pop_front()
		var card_instance = card_scene.instance()
		if card_instance is Card:
			card_instance.packed_scene = card_scene
			hand.append(card_instance)
	energy = character.max_energy

func reshuffle_discard_pile():
	while(discard_pile.size() > 0):
		var card_scene : PackedScene = discard_pile.pop_front()
		draw_pile.append(card_scene)
	draw_pile.shuffle()

func discard_hand():
	while(hand.size() > 0):
		var card : Card = hand.pop_front()
		discard_pile.append(card.packed_scene)

func pick_card():
	var random_index: int = randi() % hand.size()
	print("Opponent plays %s " % str(hand[random_index]))

func end_turn():
	pick_card()
	discard_hand()

func start_turn():
	draw_cards(character.hand_size)
	energy = character.max_energy
	print("Opponent hand %s " % str(hand))
