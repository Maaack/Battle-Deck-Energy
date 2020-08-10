extends Resource


class_name AIOpponent

var character : Character
var draw_pile : Array = []
var hand : Array = []
var discard_pile : Array = []

func start():
	if not is_instance_valid(character):
		print("Error: No character.")
		return
	randomize()
	character.start()
	discard_pile = character.deck

func get_hand_size():
	return character.hand_size

func draw_cards(count:int = get_hand_size()):
	for _i in range(count):
		if draw_pile.size() < 1:
			reshuffle_discard_pile()
		var card_scene : PackedScene = draw_pile.pop_front()
		var card_instance = card_scene.instance()
		if card_instance is Card:
			card_instance.packed_scene = card_scene
			hand.append(card_instance)

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
	return hand[random_index]

func end_turn():
	discard_hand()

func draw_hand():
	draw_cards()
	character.energy = character.max_energy
	print("Opponent hand %s " % str(hand))

func get_health():
	return character.health

func get_max_health():
	return character.max_health

func get_energy():
	return character.energy

func get_max_energy():
	return character.max_energy

func get_deck_size():
	return character.deck_size()
