tool
extends Node2D


class_name Card2

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

func _to_string():
	if card_data is CardData:
		return "%s" % card_data.title
	else:
		return ._to_string()

func _update_card_front():
	if not is_instance_valid(card_data):
		return
	if card_data.title != "":
		$Body/CardFront/TitlePanel/TitleLabel.text = card_data.title
	if card_data.description != "":
		$Body/CardFront/DescriptionPanel/MarginContainer/DescriptionLabel.text = card_data.description
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

func _reset_card_data():
	if starting_card_data is CardData:
		card_data = starting_card_data.duplicate()
	_update_card_front()

func set_starting_card_data(value:CardData):
	starting_card_data = value
	_reset_card_data()

func tween_to(new_prs:PRSData, tween_time:float = 0.0, animation_type:int = -1):
	if card_data.prs.is_equal(new_prs):
		return
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
