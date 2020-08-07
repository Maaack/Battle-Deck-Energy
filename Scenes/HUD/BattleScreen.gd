extends Control


signal player_updated

onready var draw_pile = $DrawPile
onready var discard_pile = $DiscardPile
onready var hand_manager = $Hand/HandManager
onready var hand = $Hand
onready var enemy_phase_timer = $EnemyPhaseTimer
onready var player_phase_timer = $PlayerPhaseTimer
onready var resolution_phase_timer = $ResolutionPhaseTimer
onready var draw_card_timer = $DrawCardTimer
onready var reshuffle_card_timer = $ReshuffleCardTimer
onready var energy_meter = $BattleDeckEnergy
onready var end_turn_button = $EndTurnButton/Button
onready var round_counter = $RoundCounter

enum BattleRoundPhase {STARTING_PHASE, ENEMY_PHASE, PLAYER_PHASE, RESOLUTION_PHASE, INIT_PHASE = -1}
var _current_battle_phase : int = BattleRoundPhase.INIT_PHASE
var _drawing_cards : int = 0
var _reshuffling_cards : int = 0

var player : Character
var opponents : Array = []
var opponents_picked_cards : Array = []

func start():
	if not is_instance_valid(player):
		print("Error: No player.")
		return
	if opponents.size() < 1:
		print("Error: No opponents.")
		return
	randomize()
	player.start()
	opponents_start()
	energy_meter.max_energy = player.max_energy
	draw_pile.deck = player.deck
	draw_pile.shuffle()
	advance_battle_phase()

func hit_player(damage:int):
	player.health -= damage
	on_player_updated()

func draw_cards(count:int = 1):
	_drawing_cards = count
	if _drawing_cards > 0:
		draw_pile.draw_card()

func _drawing_cards_completed():
	end_turn_button.disabled = false
	reset_player_energy()

func on_player_updated():
	energy_meter.energy = player.energy
	hand_manager.energy_available = player.energy
	emit_signal("player_updated")

func reset_player_energy():
	player.energy = player.max_energy
	on_player_updated()

func reshuffle_discard_pile():
	_reshuffling_cards = discard_pile.size()
	if _reshuffling_cards > 0:
		discard_pile.draw_card()

func _reshuffling_cards_completed():
	_shuffle_and_draw()

func get_opponents_picked_cards():
	var picked_cards : Array = []
	for opponent in opponents:
		if opponent is AIOpponent:
			var card : Card = opponent.pick_card()
			picked_cards.append(card)
	return picked_cards

func get_hand_size():
	return player.hand_size

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
	if hand_manager.is_discarding_card(moving_card):
		discard_pile.add_card(moving_card.packed_scene)
		moving_card.queue_free()

func _on_HandManager_discarding_card(discarding_card:Card):
	player.energy -= discarding_card.get_energy_cost()
	on_player_updated()
	discarding_card.connect("position_reached", self, "_on_Card_position_reached")
	discarding_card.tween_to_position(discard_pile.rect_position - hand.rect_position)

func opponents_start():
	for opponent in opponents:
		if opponent is AIOpponent:
			opponent.start()

func opponents_draw_hands():
	for opponent in opponents:
		if opponent is AIOpponent:
			opponent.draw_hand()

func opponents_end_turns():
	for opponent in opponents:
		if opponent is AIOpponent:
			opponent.end_turn()

func resolve_opponent_cards():
	for card in opponents_picked_cards:
		if card.card_settings.title == 'Attack':
			hit_player(3)

func _on_EnemyPhaseTimer_timeout():
	opponents_draw_hands()
	opponents_picked_cards = get_opponents_picked_cards()
	opponents_end_turns()
	advance_battle_phase()

func _on_PlayerPhaseTimer_timeout():
	draw_cards(get_hand_size())

func _on_EndTurnButton_pressed():
	advance_battle_phase()

func _on_ResolutionPhaseTimer_timeout():
	hand_manager.discard_hand()
	resolve_opponent_cards()
	advance_battle_phase()

func advance_battle_phase():
	var next_battle_phase = _current_battle_phase + 1
	var phases_modulo = BattleRoundPhase.size() - 1
	_current_battle_phase = next_battle_phase % phases_modulo
	match(_current_battle_phase):
		BattleRoundPhase.STARTING_PHASE:
			print("Starting Phase")
			round_counter.advance_round()
			advance_battle_phase()
		BattleRoundPhase.ENEMY_PHASE:
			print("Enemy Phase")
			enemy_phase_timer.start()
		BattleRoundPhase.PLAYER_PHASE:
			print("Player Phase")
			player_phase_timer.start()
		BattleRoundPhase.RESOLUTION_PHASE:
			print("Resolution Phase")
			resolution_phase_timer.start()
