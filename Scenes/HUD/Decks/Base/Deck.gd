tool
extends Control


export(Resource) var deck_settings setget set_deck_settings

onready var count_label = $TextureRect/Panel/CountLabel

func set_deck_settings(value:DeckSettings):
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
	
