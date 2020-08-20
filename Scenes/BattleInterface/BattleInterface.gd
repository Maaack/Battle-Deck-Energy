extends Control


onready var player_interface = $PlayerInterface
onready var player_battle_manager = $CharacterBattleManager
onready var ai_opponents_manager = $AIOpponentsManager

var player_data : CharacterData setget set_player_data
var opponents : Array = [] setget set_opponents

func set_player_data(value:CharacterData):
	player_data = value
	if is_instance_valid(player_data):
		player_interface.player_data = player_data
		player_battle_manager.character_data = player_data

func new_opponent(opponent_data:CharacterData):
	opponent_data = opponent_data.duplicate()
	ai_opponents_manager.add_opponent(opponent_data)
	player_interface.add_opponent_actions(opponent_data)

func set_opponents(values:Array):
	for value in values:
		if value is CharacterData:
			new_opponent(value)
	player_interface.add_openings()

func start_turn():
	if player_interface.is_connected("discard_completed", self, "start_turn"):
		player_interface.disconnect("discard_completed", self, "start_turn")
	player_interface.connect("drawing_completed", self, "_on_hand_drawn")
	ai_opponents_manager.opponents_take_turn()
	player_battle_manager.draw_hand()

func end_turn():
	player_interface.connect("discard_completed",  self, "start_turn")
	player_battle_manager.discard_hand()

func _on_hand_drawn():
	if player_interface.is_connected("drawing_completed", self, "_on_hand_drawn"):
		player_interface.disconnect("drawing_completed", self, "_on_hand_drawn")
	player_interface.start_turn()

func _on_CharacterBattleManager_drew_card(card):
	player_interface.draw_card(card)

func _on_PlayerInterface_ending_turn():
	end_turn()

func _on_CharacterBattleManager_discarded_card(card):
	player_interface.discard_card(card)

func _on_CharacterBattleManager_reshuffled_card(card):
	player_interface.reshuffle_card(card)
