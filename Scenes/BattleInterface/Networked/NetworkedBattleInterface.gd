extends BattleInterface


func _ready():
	battle_manager = $NetworkedBattleManager
	player_interface = $NetworkedPlayerInterface

func _advance_character_phase():
	battle_manager.rpc('advance_character_phase')

func _on_BattleManager_turn_started(character : CharacterData):
	if character == player_character:
		player_interface.start_turn()
		player_interface.start_timer(40)
