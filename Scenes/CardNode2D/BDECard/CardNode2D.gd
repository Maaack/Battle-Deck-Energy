tool
extends BaseCardNode2D


class_name CardNode2D

signal mouse_entered(card_node_2d)
signal mouse_exited(card_node_2d)
signal mouse_clicked(card_node_2d)
signal mouse_double_clicked(card_node_2d)
signal mouse_released(card_node_2d)
signal animation_completed(card_node_2d)

const CARD_EFFECT_TAG = 'card_effect'
const COST_LIMITED_COLOR = Color(0.835294, 0, 0)
const COST_AFFORDABLE_COLOR = Color(1, 1, 1)

enum MouseInputMode{NONE, GUI, PHYSICS}

onready var area_2d_node = $Area2D
onready var glow_node = $Card/GlowContainer/Control/GlowNode
onready var pulse_animation = $Card/PulseAnimation
onready var energy_panel = $Card/Body/BDEPanel
onready var energy_label = $Card/Body/BDEPanel/BDECostLabel
onready var title_panel = $Card/Body/CardFront/TitlePanel
onready var title_label = $Card/Body/CardFront/TitlePanel/TitleLabel
onready var description_label = $Card/Body/CardFront/DescriptionPanel/MarginContainer/DescriptionLabel
onready var type_panel = $Card/Body/CardFront/Control/TypePanel
onready var type_label = $Card/Body/CardFront/Control/TypePanel/TypeLabel
onready var effect_texture = $Card/Body/CardFront/EffectContainer/TextureRect
onready var left_tooltip_target = $Card/LeftTooltip2D
onready var right_tooltip_target = $Card/RightTooltip2D
onready var bottom_left_tooltip_target = $Card/BottomLeftTooltip2D
onready var bottom_right_tooltip_target = $Card/BottomRightTooltip2D
onready var draw_audio_player = $DrawAudioStreamPlayer2D
onready var drop_audio_player = $DropAudioStreamPlayer2D
onready var slide_audio_player = $SlideAudioStreamPlayer2D

export(Resource) var starting_card_data setget set_starting_card_data
export(StyleBox) var title_attack_style_box : StyleBox
export(StyleBox) var title_defend_style_box : StyleBox
export(StyleBox) var title_skill_style_box : StyleBox
export(StyleBox) var title_stress_style_box : StyleBox
export(StyleBox) var type_attack_style_box : StyleBox
export(StyleBox) var type_defend_style_box : StyleBox
export(StyleBox) var type_skill_style_box : StyleBox
export(StyleBox) var type_stress_style_box : StyleBox
export(Color) var unafforadable_color : Color


var card_data : CardData setget set_card_data
var base_values : Dictionary = {}
var mouse_input_mode : int = MouseInputMode.GUI setget set_mouse_input_mode
var locked_face : bool = false

func _to_string():
	if card_data is CardData:
		return "%s" % card_data.title
	else:
		return ._to_string()

func is_playable():
	return !(card_data.has_effect(EffectCalculator.UNPLAYABLE_EFFECT))

func _reset_card_type():
	match(card_data.type):
		CardData.CardType.ATTACK:
			title_panel.add_stylebox_override("panel", title_attack_style_box)
			type_panel.add_stylebox_override("panel", type_attack_style_box)
			type_label.text = 'ATTACK'
		CardData.CardType.DEFEND:
			title_panel.add_stylebox_override("panel", title_defend_style_box)
			type_panel.add_stylebox_override("panel", type_defend_style_box)
			type_label.text = 'DEFEND'
		CardData.CardType.SKILL:
			title_panel.add_stylebox_override("panel", title_skill_style_box)
			type_panel.add_stylebox_override("panel", type_skill_style_box)
			type_label.text = 'SKILL'
		CardData.CardType.STRESS:
			title_panel.add_stylebox_override("panel", title_stress_style_box)
			type_panel.add_stylebox_override("panel", type_stress_style_box)
			type_label.text = 'STRESS'

func _reset_card_front():
	if locked_face:
		return
	if not is_instance_valid(card_data):
		return
	title_label.text = card_data.title
	if not is_playable():
		energy_panel.hide()
	if card_data.energy_cost >= 0:
		energy_label.text = str(card_data.energy_cost)
	effect_texture.texture = card_data.icon
	_reset_card_type()
	update_card_effects(base_values)

func update_affordability(energy:int):
	if locked_face:
		return
	if energy >= card_data.energy_cost:
		energy_label.set("custom_colors/font_color", COST_AFFORDABLE_COLOR)
	else:
		energy_label.set("custom_colors/font_color", unafforadable_color)

func _get_effect_bbtag_string(base_value:int, total_value:int):
	var modifier_delta = total_value - base_value
	var bbtag_string = "[%s mod=%d][b]%d[/b][/%s]" % [CARD_EFFECT_TAG, modifier_delta, total_value, CARD_EFFECT_TAG]
	return bbtag_string

func _reset_base_values():
	base_values.clear()
	if card_data == null:
		return
	for effect in card_data.effects:
		if effect is EffectData:
			var effect_type = effect.type_tag
			if not effect_type in base_values:
				base_values[effect_type] = 0
			base_values[effect_type] += effect.amount

func _reset_card_data():
	if starting_card_data is CardData:
		card_data = starting_card_data.duplicate()

func _ready():
	_reset_card_data()
	_reset_base_values()
	_reset_card_front()

func _get_random_pitch():
	return rand_range(0.88775, 1.12246)

func play_draw_audio():
	draw_audio_player.pitch_scale = _get_random_pitch()
	draw_audio_player.play()

func play_drop_audio():
	drop_audio_player.pitch_scale = _get_random_pitch()
	drop_audio_player.play()

func play_slide_audio():
	slide_audio_player.pitch_scale = _get_random_pitch()
	slide_audio_player.play()

func update_card_effects(total_values:Dictionary):
	if card_data.description == "":
		return
	var description : String = card_data.description
	var regex = RegEx.new()
	regex.compile("%(?<tag>[A-Z_]+)")
	for result in regex.search_all(description):
		var type_tag : String = result.get_string("tag")
		if not type_tag in base_values or not type_tag in total_values:
			continue
		var tag_string = _get_effect_bbtag_string(base_values[type_tag], total_values[type_tag])
		description = description.replace('%'+type_tag, tag_string)
	description = "[center]%s[/center]" % description
	description_label.bbcode_text = description

func set_starting_card_data(value:CardData):
	starting_card_data = value
	_reset_card_data()

func set_mouse_input_mode(value:int):
	mouse_input_mode = value
	match(mouse_input_mode):
		MouseInputMode.GUI:
			body_node.mouse_filter = Control.MOUSE_FILTER_PASS
			area_2d_node.hide()
		MouseInputMode.PHYSICS:
			body_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
			area_2d_node.show()
		MouseInputMode.NONE:
			body_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
			area_2d_node.hide()

func tween_to(new_transform:TransformData, tween_time:float = 0.0, animation_type:int = -1):
	if is_instance_valid(tween_node):
		if pulse_animation.is_playing():
			yield(pulse_animation, "animation_finished")
		if tween_node.is_active():
			if _last_animation_type != animation_type:
				tween_time += tween_node.get_runtime()
			else:
				tween_time = tween_node.get_runtime()
			tween_node.remove_all()
		tween_node.interpolate_property(self, "position", position, new_transform.position, tween_time)
		tween_node.interpolate_property(self, "rotation", rotation, new_transform.rotation, tween_time)
		tween_node.interpolate_property(self, "scale", scale, new_transform.scale, tween_time)
		tween_node.start()
	card_data.transform_data = new_transform
	_last_animation_type = animation_type

func set_card_data(value:CardData):
	card_data = value
	if is_instance_valid(card_data):
		_force_card_transform(card_data.transform_data)

func glow_on():
		glow_node.glow_on()

func glow_not():
		glow_node.glow_not()

func glow_off():
		glow_node.glow_off()

func _animate_pulse():
	pulse_animation.play("CardPulse")
	yield(pulse_animation, "animation_finished")
	_force_card_transform(card_data.transform_data)

func play_card():
	set_mouse_input_mode(MouseInputMode.NONE)
	_finish_tween()
	_animate_pulse()

func _handle_input_event(event):
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				if event.doubleclick:
					emit_signal("mouse_double_clicked", self)
				elif event.pressed:
					emit_signal("mouse_clicked", self)
				if not event.pressed:
					emit_signal("mouse_released", self)

func _on_Area2D_mouse_entered():
	emit_signal("mouse_entered", self)

func _on_Area2D_mouse_exited():
	emit_signal("mouse_exited", self)

func _on_Area2D_input_event(viewport, event, shape_idx):
	_handle_input_event(event)

func _on_Body_mouse_entered():
	emit_signal("mouse_entered", self)

func _on_Body_mouse_exited():
	emit_signal("mouse_exited", self)

func _on_Body_gui_input(event):
	_handle_input_event(event)

func _on_PulseAnimation_animation_finished(anim_name):
	emit_signal("animation_completed", self)
