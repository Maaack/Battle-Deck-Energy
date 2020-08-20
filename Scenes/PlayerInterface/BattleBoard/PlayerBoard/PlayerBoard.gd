extends Control


signal ending_turn

onready var draw_pile = $DrawPile
onready var discard_pile = $DiscardPile
onready var exhaust_pile = $ExhaustPile
onready var end_turn_button = $EndTurnButton
onready var round_counter = $RoundCounter
onready var energy_meter = $BattleDeckEnergy

func set_draw_pile_size(value:int):
	draw_pile.count = value

func set_player_energy(max_energy:int, energy:int=-1):
	energy_meter.max_energy = max_energy
	if energy > 0:
		energy_meter.energy = energy
	else:
		energy_meter.energy = max_energy

func draw_card():
	draw_pile.remove_card()

func draw_discarded_card():
	discard_pile.remove_card()

func reshuffle_card():
	discard_pile.remove_card()
	draw_pile.add_card()

func discard_card():
	discard_pile.add_card()

func exhaust_card():
	exhaust_pile.add_card()

func signal_ending_turn():
	emit_signal("ending_turn")

func _on_EndTurnButton_pressed():
	signal_ending_turn()

func reset_end_turn():
	end_turn_button.reset()

func advance_round_count():
	round_counter.advance_round()

func spend_energy(amount:int = 1):
	energy_meter.energy -= amount

func gain_energy(amount:int = 1):
	energy_meter.energy += amount
