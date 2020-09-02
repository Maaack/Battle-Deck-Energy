extends Control


onready var sprite_node = $MarginContainer/CenterContainer/Control/Sprite
onready var label_node = $MarginContainer/Control/Label

var icon : Texture setget set_icon
var integer : int setget set_integer

func update():
	sprite_node.texture = icon
	label_node.text = str(integer)

func set_icon(value:Texture):
	icon = value
	update()

func set_integer(value:int):
	integer = value
	update()
