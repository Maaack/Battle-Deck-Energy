tool
extends Control


onready var count_label = $TextureRect/Panel/CountLabel

var deck_settings : DeckSettings setget set_deck_settings


func set_deck_settings(value:DeckSettings):
	if not is_instance_valid(value):
		return
	deck_settings = value.duplicate()
	_update_deck_count()

func _ready():
	_update_deck_count()

func _update_deck_count():
	if not is_instance_valid(deck_settings):
		return
	if not is_instance_valid(count_label):
		return
	count_label.text = str(deck_settings.size())
	
func shuffle():
	if not is_instance_valid(deck_settings):
		return
	deck_settings.shuffle()

func draw_hand(count:int = 1):
	var hand : Array = []
	if not is_instance_valid(deck_settings):
		return hand
	hand = deck_settings.draw_hand(count)
	_update_deck_count()
	return hand
