extends BattleInterface


func _ready():
	battle_manager = $MultiplayerBattleManager

func _advance_character_phase():
	battle_manager.rpc('advance_character_phase')

func _on_BattleManager_team_won(team):
	pass # Replace with function body.
