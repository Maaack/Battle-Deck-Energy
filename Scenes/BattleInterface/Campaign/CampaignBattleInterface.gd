extends BattleInterface


func _ready():
	battle_manager = $CampaignBattleManager

func _on_BattleManager_team_won(team):
	var player_team = battle_manager.get_team(player_character)
	if team == player_team:
		emit_signal("player_won")
	else:
		emit_signal("player_lost")
	
