extends BattleManager


class_name MultiplayerBattleManager

func add_player(player_id : int, character_data : CharacterData, team : String):
	var battle_manager = add_character(character_data, team)
	battle_manager.set_network_master(player_id)
