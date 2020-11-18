extends BattleInterface


func _ready():
	battle_manager = $CampaignBattleManager

func _on_BattleManager_team_won(team):
	var player_team = battle_manager.get_team(player_character)
	if team == player_team:
		emit_signal("player_won")
	else:
		emit_signal("player_lost")

func _on_BattleManager_turn_started(character : CharacterData):
	if character == player_character:
		player_interface.start_turn()
	else:
		var character_battle_manager : CharacterBattleManager = battle_manager.get_character_manager(character)
		if character_battle_manager is EnemyAIBattleManager:
			var opportunities : Array = battle_manager.get_opportunities()
			character_battle_manager.take_turn(opportunities)
