extends BattleManager


class_name CampaignBattleManager

const ENEMY_TEAM = "Enemy"

var enemy_ai_battle_manager_scene = load("res://Managers/CharacterBattle/EnemyAI/Slow/SlowEnemyAIBattleManager.tscn")

func _new_character_manager_instance(character_data : CharacterData, team : String):
	var character_battle_manager : CharacterBattleManager
	if team == ENEMY_TEAM:
		character_battle_manager = enemy_ai_battle_manager_scene.instance()
	else:
		character_battle_manager = character_battle_manager_scene.instance()
	_character_manager_map[character_data] = character_battle_manager
	return character_battle_manager

func _connect_character_battle_manager(character_battle_manager : CharacterBattleManager):
	._connect_character_battle_manager(character_battle_manager)
	if character_battle_manager is SlowEnemyAIBattleManager:
		character_battle_manager.connect("card_revealed", self, "_on_CharacterBattleManager_card_revealed")
		pass

func setup_battle():
	if not _skip_battle_setup:
		for character_manager in _character_manager_map.values():
			if character_manager is SlowEnemyAIBattleManager:
				var slow_team = team_manager.get_team(character_manager.character_data)
				team_phase_manager.move_phase(slow_team, 1)
				break
	.setup_battle()

func _active_character_draws():
	var character_manager = _character_manager_map[active_character]
	effects_manager.set_starting_energy(character_manager)
	var draw_size = effects_manager.get_starting_draw_card_count(character_manager)
	if character_manager.has_statuses():
		character_manager.update_early_start_of_turn_statuses()
		character_manager.update_late_start_of_turn_statuses()
		advance_action_timer.start()
		yield(advance_action_timer, "timeout")
	if character_manager is EnemyAIBattleManager:
		character_manager.draw_cards(draw_size)
		advance_character_phase()
	else:
		emit_signal("before_hand_drawn", active_character)
		character_manager.draw_cards(draw_size)

func _end_character_turn(character_data : CharacterData):
	var character_manager : CharacterBattleManager = _character_manager_map[character_data]
	character_manager.update_end_of_turn_statuses()
	if character_manager is EnemyAIBattleManager:
		character_manager.discard_hand()
		advance_action_timer.start()
		yield(advance_action_timer, "timeout")
		advance_character_phase()
	elif character_manager.has_discardable_cards_in_hand():
		emit_signal("before_hand_discarded", character_data)
		character_manager.discard_hand()
	else:
		character_phase_manager.advance()

