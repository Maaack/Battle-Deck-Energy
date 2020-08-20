extends Control


onready var player_interface = $PlayerInterface
onready var player_battle_manager = $CharacterBattleManager
onready var ai_opponents_manager = $AIOpponentsManager

var player_data : CharacterData = preload("res://Resources/Characters/Player/NewPlayerData.tres")
var enemy_data : CharacterData = preload("res://Resources/Characters/Opponents/EasyOpponentData.tres")
var battle_manager_scene : PackedScene = preload("res://Managers/CharacterBattle/CharacterBattleManager.tscn")

func _ready():
	player_interface.set_draw_pile_count(player_data.deck_size())
	player_battle_manager.character_data = player_data
	var enemy1 : CharacterData = enemy_data.duplicate()
	var enemy2 : CharacterData = enemy_data.duplicate()
	var enemy3 : CharacterData = enemy_data.duplicate()
	ai_opponents_manager.add_opponent(enemy1)
	ai_opponents_manager.add_opponent(enemy2)
	ai_opponents_manager.add_opponent(enemy3)
	player_interface.add_opponent_actions(enemy1)
	player_interface.add_opponent_actions(enemy2)
	player_interface.add_opponent_actions(enemy3)
	player_interface.add_openings()
	start_turn()

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
