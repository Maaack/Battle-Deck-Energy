extends Control

@onready var draw_pile = $DrawPile
@onready var discard_pile = $DiscardPile
@onready var exhaust_pile = $ExhaustPile
@onready var end_turn_button = $EndTurnButton
@onready var energy_meter = $BattleDeckEnergy
@onready var turn_timer = $TurnTimer

var player_data : CharacterData

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

func start_timer(time : int):
	turn_timer.show()
	turn_timer.time = time

func end_turn():
	end_turn_button.disable()
	turn_timer.stop_timer()
	EventBus.turn_ended.emit(player_data)

func _on_EndTurnButton_pressed():
	end_turn()

func reset_end_turn():
	end_turn_button.reset()

func _on_DrawPile_button_pressed():
	EventBus.draw_pile_pressed.emit()

func _on_DiscardPile_button_pressed():
	EventBus.discard_pile_pressed.emit()

func _on_ExhaustPile_button_pressed():
	EventBus.exhaust_pile_pressed.emit()

func _on_TurnTimer_timeout():
	end_turn()
