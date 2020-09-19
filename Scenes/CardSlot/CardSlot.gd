extends Control


const ATTACK_TYPE = 'ATTACK'
const DEFEND_TYPE = 'DEFEND'
const SKILL_TYPE = 'SKILL'

onready var label_node = $Panel/Label

var type : int = CardData.CardType.ATTACK setget set_type

func _update_label():
	var new_label : String = ""
	match(type):
		(CardData.CardType.ATTACK):
			label_node.text = ATTACK_TYPE
		(CardData.CardType.DEFEND):
			label_node.text = DEFEND_TYPE
		(CardData.CardType.SKILL):
			label_node.text = SKILL_TYPE

func set_type(value:int):
	type = value
	_update_label()
