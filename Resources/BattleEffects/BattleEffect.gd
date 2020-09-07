extends Resource


class_name BattleEffect

enum ApplyMode{RESOLUTION, IMMEDIATE}
enum AimMode{TARGET, SOURCE}

export(String) var effect_type : String = ''
export(Texture) var effect_icon : Texture
export(int) var effect_quantity : int = 0
export(Color) var effect_color : Color = Color()
export(ApplyMode) var apply_mode : int = ApplyMode.IMMEDIATE
export(AimMode) var aim_mode : int = AimMode.TARGET

func _to_string():
	return "BattleEffect:%d,%s" % [get_instance_id(), effect_type]

func is_immediate():
	return apply_mode == ApplyMode.IMMEDIATE

func is_aimed_at_target():
	return aim_mode == AimMode.TARGET
