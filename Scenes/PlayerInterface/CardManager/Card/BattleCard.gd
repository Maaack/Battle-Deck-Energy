tool
extends Node2D


class_name BattleCard

const CARD_EFFECT_TAG = 'card_effect'

signal mouse_entered(card_data)
signal mouse_exited(card_data)
signal mouse_clicked(card_data)
signal mouse_released(card_data)
signal tween_completed(card_data)

onready var body_node = $Body
onready var glow_node = $GlowContainer/Control/GlowNode
onready var tween_node = $Tween

export(Resource) var starting_card_data setget set_starting_card_data

var card_data : CardData setget set_card_data
var _last_animation_type : int = 0
var effect_modifiers : Dictionary = {} setget set_effect_modifiers

func _to_string():
	if card_data is CardData:
		return "%s" % card_data.title
	else:
		return ._to_string()

func _get_card_attack_value():
	var attack : int = 0
	for effect in card_data.battle_effects:
		if effect is BattleEffect:
			match(effect.effect_type):
				'ATTACK', 'RICOCHET':
					attack += effect.effect_quantity
	return attack

func _get_effect_base_value(effect_type:String):
	var value : int = 0
	for effect in card_data.battle_effects:
		if effect is BattleEffect and effect.effect_type == effect_type:
			value += effect.effect_quantity
	return value

func _get_effect_mod_value(effect_type:String):
	if effect_type in effect_modifiers:
		return effect_modifiers[effect_type]
	return 0

func _get_effect_bbtag_string(effect_type:String):
	var base_value = _get_effect_base_value(effect_type)
	var mod_value = _get_effect_mod_value(effect_type)
	var full_value = base_value + mod_value
	var bbtag_string = "[%s mod=%d][b]%d[/b][/%s]" % [CARD_EFFECT_TAG, mod_value, full_value, CARD_EFFECT_TAG]
	return bbtag_string

func _update_card_description():
	if card_data.description == "":
		return
	var description : String = card_data.description
	var regex = RegEx.new()
	regex.compile("%(?<tag>[A-Z_]+)")
	for result in regex.search_all(description):
		var type_tag : String = result.get_string("tag")
		var tag_string = _get_effect_bbtag_string(type_tag)
		description = description.replace('%'+type_tag, tag_string)
	description = "[center]%s[/center]" % description
	$Body/CardFront/DescriptionPanel/MarginContainer/DescriptionLabel.bbcode_text = description

func _update_card_front():
	if not is_instance_valid(card_data):
		return
	if card_data.title != "":
		$Body/CardFront/TitlePanel/TitleLabel.text = card_data.title
	_update_card_description()
	if card_data.energy_cost >= 0:
		$Body/BDEPanel/BDECostLabel.text = str(card_data.energy_cost)
	if card_data.battle_effects.size() > 0:
		var battle_effect : BattleEffect = card_data.battle_effects[0]
		if battle_effect.effect_icon != null:
			$Body/CardFront/Control/TextureRect.texture = battle_effect.effect_icon
		if battle_effect.effect_quantity != 0:
			$Body/CardFront/Control/Label.text = str(battle_effect.effect_quantity)
		if battle_effect.effect_color != Color():
			$Body/CardFront/Control/Label.add_color_override("font_color", battle_effect.effect_color)

func set_effect_modifiers(value:Dictionary):
	effect_modifiers = value
	_update_card_description()

func _reset_card_data():
	if starting_card_data is CardData:
		card_data = starting_card_data.duplicate()
	_update_card_front()

func set_starting_card_data(value:CardData):
	starting_card_data = value
	_reset_card_data()

func tween_to(new_prs:PRSData, tween_time:float = 0.0, animation_type:int = -1):
	if is_instance_valid(tween_node):
		if tween_node.is_active():
			if _last_animation_type != animation_type:
				tween_time += tween_node.get_runtime()
			else:
				tween_time = tween_node.get_runtime()
			tween_node.remove_all()
		tween_node.interpolate_property(self, "position", position, new_prs.position, tween_time)
		tween_node.interpolate_property(self, "rotation", rotation, new_prs.rotation, tween_time)
		tween_node.interpolate_property(self, "scale", scale, new_prs.scale, tween_time)
		tween_node.start()
	card_data.prs = new_prs
	_last_animation_type = animation_type

func set_card_data(value:CardData):
	card_data = value
	if is_instance_valid(card_data):
		position = card_data.prs.position
		rotation = card_data.prs.rotation
		scale = card_data.prs.scale

func _ready():
	_reset_card_data()

func glow_on():
		glow_node.glow_on()

func glow_not():
		glow_node.glow_not()

func glow_off():
		glow_node.glow_off()

func _on_Body_mouse_entered():
	emit_signal("mouse_entered", card_data)

func _on_Body_mouse_exited():
	emit_signal("mouse_exited", card_data)
	
func _on_Body_gui_input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_LEFT:
				if event.pressed:
					emit_signal("mouse_clicked", card_data)
				if not event.pressed:
					emit_signal("mouse_released", card_data)

func _on_Tween_tween_all_completed():
	emit_signal("tween_completed", card_data)
