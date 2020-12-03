extends Resource


class_name EffectData

enum ApplyMode{NONE, PLAY, DRAW, DISCARD, EXHAUST}
enum AimMode{TARGET, SOURCE}
enum TeamAimMode{SINGLE, TEAMMATES, ALL, ALL_ENEMIES}

export(String) var type_tag : String = ''
export(int) var amount : int = 0
export(ApplyMode) var apply_mode : int = ApplyMode.PLAY
export(AimMode) var aim_mode : int = AimMode.TARGET
export(TeamAimMode) var team_aim_mode : int = TeamAimMode.SINGLE

func _to_string():
	return "EffectData:%d,%s" % [get_instance_id(), type_tag]

func applies_on_play():
	return apply_mode == ApplyMode.PLAY

func applies_on_draw():
	return apply_mode == ApplyMode.DRAW

func applies_on_discard():
	return apply_mode == ApplyMode.DISCARD

func applies_on_exhaust():
	return apply_mode == ApplyMode.EXHAUST

func is_aimed_at_target():
	return aim_mode == AimMode.TARGET

func is_aimed_at_teammates():
	return team_aim_mode == TeamAimMode.TEAMMATES

func is_aimed_at_entire_team():
	return team_aim_mode == TeamAimMode.ALL

func is_aimed_at_enemies():
	return team_aim_mode == TeamAimMode.ALL_ENEMIES
