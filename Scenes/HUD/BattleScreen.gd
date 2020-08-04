extends Control


onready var draw_pile = $DrawPile
onready var discard_pile = $DiscardPile
onready var hand_manager = $Hand/HandManager
onready var hand = $Hand
onready var draw_hand_timer = $DrawHandTimer
onready var draw_card_timer = $DrawCardTimer
onready var reshuffle_card_timer = $ReshuffleCardTimer
onready var resize_timer = $ResizeTimer
onready var health_meter = $HealthMeter
onready var energy_meter = $BattleDeckEnergy
onready var end_turn_button = $EndTurnButton/Button

var _drawing_cards : int = 0
var _reshuffling_cards : int = 0
var player : Character
var hand_size : int = 0

func start(player_ref:Character):
	player = player_ref
	randomize()
	energy_meter.max_energy = player.max_energy
	energy_meter.reset_energy()
	hand_size = player.hand_size
	draw_pile.set_deck(player.deck)
	draw_pile.shuffle()
	draw_hand_timer.start()

func draw_cards(count:int = 1):
	_drawing_cards = count
	if _drawing_cards > 0:
		draw_pile.draw_card()

func _drawing_cards_completed():
	end_turn_button.disabled = false
	energy_meter.reset_energy()


func reshuffle_discard_pile():
	_reshuffling_cards = discard_pile.size()
	if _reshuffling_cards > 0:
		discard_pile.draw_card()

func _reshuffling_cards_completed():
	_shuffle_and_draw()

func _on_EndTurnButton_pressed():
	hand_manager.discard_hand()
	draw_hand_timer.start()

func _on_DrawHandTimer_timeout():
	draw_cards(hand_size)

func _on_DrawPile_drew_card(card_scene:PackedScene):
	var card_instance : Card = card_scene.instance()
	if not is_instance_valid(card_instance):
		return
	card_instance.packed_scene = card_scene
	card_instance.position = draw_pile.rect_position - hand.rect_position
	hand.add_child(card_instance)
	hand_manager.add_card(card_instance)
	_drawing_cards -= 1
	if _drawing_cards > 0:
		draw_card_timer.start()
	else:
		_drawing_cards_completed()
	
func _on_DrawPile_empty():
	if discard_pile.size() > 0:
		reshuffle_discard_pile()
	else:
		_drawing_cards_completed()

func _on_DiscardPile_drew_card(card:PackedScene):
	draw_pile.add_card(card)
	_reshuffling_cards -= 1
	if _reshuffling_cards > 0:
		reshuffle_card_timer.start()
	else:
		_reshuffling_cards_completed()

func _on_DiscardPile_empty():
	_reshuffling_cards_completed()
	_drawing_cards_completed()

func _shuffle_and_draw():
	draw_pile.shuffle()
	if _drawing_cards > 0:
		draw_card_timer.start()

func _on_DrawCardTimer_timeout():
	draw_pile.draw_card()

func _on_ReshuffleCardTimer_timeout():
	discard_pile.draw_card()

func _on_Card_position_reached(moving_card:Card):
	if moving_card.discarding:
		discard_pile.add_card(moving_card.packed_scene)
		moving_card.queue_free()

func _on_HandManager_discarding_card(discarding_card:Card):
	energy_meter.spend(1)
	discarding_card.connect("position_reached", self, "_on_Card_position_reached")
	discarding_card.tween_to_position(discard_pile.rect_position - hand.rect_position)
