extends Control


signal ending_turn
signal draw_pile_pressed
signal discard_pile_pressed
signal exhaust_pile_pressed

onready var draw_pile = $DrawPile
onready var discard_pile = $DiscardPile
onready var exhaust_pile = $ExhaustPile
onready var end_turn_button = $EndTurnButton
onready var energy_meter = $BattleDeckEnergy
onready var turn_timer = $TurnTimer

func set_draw_pile_size(value:int):
	draw_pile.count = value

func set_player_energy(energy:int, max_energy:int):
	energy_meter.set_energy_values(energy, max_energy)

func gain_energy(amount:int):
	energy_meter.energy += amount

func lose_energy(amount:int):
	energy_meter.energy -= amount

func draw_card():
	draw_pile.remove_card()

func draw_discarded_card():
	discard_pile.remove_card()

func reshuffle_card():
	draw_pile.add_card()

func discard_card():
	discard_pile.add_card()

func exhaust_card():
	exhaust_pile.add_card()

func signal_ending_turn():
	emit_signal("ending_turn")

func start_timer(time : int):
	turn_timer.show()
	turn_timer.time = time

func _on_EndTurnButton_pressed():
	turn_timer.stop_timer()
	signal_ending_turn()

func reset_end_turn():
	end_turn_button.reset()

func _on_DrawPile_button_pressed():
	emit_signal("draw_pile_pressed")

func _on_DiscardPile_button_pressed():
	emit_signal("discard_pile_pressed")

func _on_ExhaustPile_button_pressed():
	emit_signal("exhaust_pile_pressed")

func _on_TurnTimer_timeout():
	end_turn_button.disable()
	signal_ending_turn()
