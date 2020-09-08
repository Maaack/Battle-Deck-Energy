extends Node2D


const EFFECT_BB_CODE : String = "[center][color=#%s]%s[/color][/center]"
const EFFECT_TEXT : String = "%+d %s"
const TEXT_FADE_ANIMATION : String = "TextFade"
const RAISE_HEIGHT : float = -150.0
const RANGE : float = PI/4.0

onready var text_container = $TextContainer
onready var rich_text_label = $TextContainer/RichTextLabel
onready var animation_player = $AnimationPlayer
onready var tween_node = $Tween

func _get_tween_time():
	return animation_player.current_animation_length
	
func _ready():
	animation_player.play(TEXT_FADE_ANIMATION)
	var new_position : Vector2 = Vector2(0, RAISE_HEIGHT)
	var random_rotation : float = rand_range(-RANGE, RANGE)
	new_position = new_position.rotated(random_rotation)
	tween_node.interpolate_property(text_container, "position", text_container.position, new_position, _get_tween_time())
	tween_node.start()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == TEXT_FADE_ANIMATION:
		queue_free()

func set_status_update(status:StatusData, delta:int):
	var text = EFFECT_TEXT % [delta, status.title]
	rich_text_label.bbcode_text = EFFECT_BB_CODE % [str(status.color.to_html()), text]
