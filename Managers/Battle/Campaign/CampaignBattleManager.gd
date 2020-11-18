extends BattleManager


class_name CampaignBattleManager

var enemy_ai_battle_manager_scene = load("res://Managers/CharacterBattle/EnemyAI/EnemyAIBattleManager.tscn")

func _new_character_manager_instance(character_data : CharacterData, team : String):
	var character_battle_manager : CharacterBattleManager
	if team == 'Enemy':
		character_battle_manager = enemy_ai_battle_manager_scene.instance()
	else:
		character_battle_manager = character_battle_manager_scene.instance()
	_character_manager_map[character_data] = character_battle_manager
	return character_battle_manager
	
func _active_character_draws():
	var character_manager = _character_manager_map[active_character]
	character_manager.update_early_start_of_turn_statuses()
	character_manager.update_late_start_of_turn_statuses()
	advance_action_timer.start()
	yield(advance_action_timer, "timeout")
	character_manager.reset_energy()
	if character_manager is EnemyAIBattleManager:
		character_manager.draw_hand()
		advance_action_timer.start()
		yield(advance_action_timer, "timeout")
		advance_character_phase()
	else:
		emit_signal("before_hand_drawn", active_character)
		character_manager.draw_hand()
