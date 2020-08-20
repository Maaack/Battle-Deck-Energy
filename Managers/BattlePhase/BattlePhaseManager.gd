extends Node


const INIT_PHASE = -1

var _battle_phase_iter : int = INIT_PHASE
var battle_phase

func get_battle_phase():
	if _battle_phase_iter == INIT_PHASE:
		return
	var child_count : int = get_child_count()
	if child_count > 0 and _battle_phase_iter <= child_count - 1:
		return get_children()[_battle_phase_iter]

func enter_battle_phase():
	battle_phase = get_battle_phase()
	if battle_phase is BattlePhase:
		battle_phase.enter()

func exit_battle_phase():
	battle_phase = get_battle_phase()
	if battle_phase is BattlePhase:
		battle_phase.exit()

func advance():
	exit_battle_phase()
	var next_battle_phase = _battle_phase_iter + 1
	var child_count = get_child_count()
	if child_count == 0:
		print("Error: Advancing battle phases without children.")
		return
	_battle_phase_iter = next_battle_phase % child_count
	enter_battle_phase()
	return _battle_phase_iter
