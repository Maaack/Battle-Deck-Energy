extends Control


enum CardInstanceState{DRAWING, HELD, PLACED, DISCARDING, INIT_STATE = -1}

onready var card_manager : Node2D = $CardManager
onready var hand_manager : Node2D = $HandContainer/Control/HandManager
onready var player_board : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard

var card_states : Dictionary = {}
var player_cards : Array = [] setget set_player_cards

func set_player_cards(value:Array):
	player_cards = value

func _ready():
	pass # Replace with function body.

func draw_card(card_data:CardData):
	pass

func discard_card(card_data:CardData):
	pass

func update_player_board():
	pass

func update_opponents_board():
	pass
