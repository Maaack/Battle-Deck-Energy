extends Resource


class_name EffectData

enum ApplyMode{RESOLUTION, IMMEDIATE}
enum AimMode{TARGET, SOURCE}

export(String) var type_tag : String = ''
export(Texture) var icon : Texture
export(int) var amount : int = 0
export(Color) var base_color : Color = Color()
export(ApplyMode) var apply_mode : int = ApplyMode.IMMEDIATE
export(AimMode) var aim_mode : int = AimMode.TARGET

func _to_string():
	return "EffectData:%d,%s" % [get_instance_id(), type_tag]

func is_immediate():
	return apply_mode == ApplyMode.IMMEDIATE

func is_aimed_at_target():
	return aim_mode == AimMode.TARGET
