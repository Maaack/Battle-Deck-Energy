extends Control


onready var player_interface = $PlayerInterface
onready var player_battle_manager = $CharacterBattleManager

var player_data : CharacterData = preload("res://Resources/Characters/Player/NewPlayer.tres")
var enemy : Character = preload("res://Resources/Characters/Opponents/BasicEnemy.tres")

func _ready():
	player_interface.set_draw_pile_count(player_data.deck_size())
	player_battle_manager.character_data = player_data
	start_turn()

func start_turn():
	if player_interface.is_connected("discard_completed", self, "start_turn"):
		player_interface.disconnect("discard_completed", self, "start_turn")
	player_interface.connect("drawing_completed", self, "_on_hand_drawn")
	player_battle_manager.draw_hand()

func _on_hand_drawn():
	if player_interface.is_connected("drawing_completed", self, "_on_hand_drawn"):
		player_interface.disconnect("drawing_completed", self, "_on_hand_drawn")
	player_interface.start_turn()

func _on_CharacterBattleManager_drew_card(card):
	player_interface.draw_card(card)

func _on_PlayerInterface_ending_turn():
	player_interface.connect("discard_completed",  self, "start_turn")
	player_battle_manager.discard_hand()

func _on_CharacterBattleManager_discarded_card(card):
	player_interface.discard_card(card)
