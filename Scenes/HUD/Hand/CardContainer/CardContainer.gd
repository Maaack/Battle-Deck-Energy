extends Control


onready var card_container = $CenteredControl
onready var tween_node = $Tween

var card_scene : PackedScene setget set_card, get_card
var card_instance : Card = null
var last_size : Vector2

func _ready():
	last_size = rect_size

func set_card(value:PackedScene):
	if not is_instance_valid(card_container):
		return
	_clear_children()
	card_scene = value
	if not is_instance_valid(card_scene):
		return
	card_instance = card_scene.instance()
	card_container.add_child(card_instance)
	card_instance.connect("discard", self, "_on_Card_discard")

func get_card():
	return card_scene

func _clear_children():
	if card_container.get_child_count() > 0:
		for child in card_container.get_children():
			child.queue_free()

func _get_tween_time():
	return 0.5

func _on_Card_discard():
	queue_free()

func _on_CardContainer_item_rect_changed():
	_update_card_motion()

func _on_Parent_resized():
	_update_card_motion()

func _update_card_motion():
	if last_size != Vector2(0,0) and is_instance_valid(tween_node):
		var center_diff : Vector2 = (last_size - rect_size) / 2
		var original_position : Vector2 = Vector2(0,0)
		tween_node.interpolate_property(card_instance, "position", card_instance.position + center_diff, original_position, _get_tween_time())
		tween_node.start()
	last_size = rect_size
