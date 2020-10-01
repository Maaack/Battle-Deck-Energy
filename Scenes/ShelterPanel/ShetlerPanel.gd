extends Control


signal dine_pressed
signal bath_pressed(deck_cleaner_instance)
signal shelter_left

const DINE_DESCRIPTION = "Heal %d%% (%d) of your Max Health\n%d/%d --> %d/%d"
const BATH_DESCRIPTION = "Clean your Deck of %d Card"

onready var dine_label = $OptionsContainer/HBoxContainer/DineControl/Label
onready var bath_label = $OptionsContainer/HBoxContainer/BathControl/Label

var deck_cleaner_scene = preload("res://Scenes/DeckViewer/DeckCleaner/DeckCleaner.tscn")
var player_data : CharacterData setget set_player_data
var health_gain_ratio : float = 0.2

func get_raised_health():
	var max_health : int = player_data.max_health
	var health_increase : int = float(max_health) * health_gain_ratio
	return min(player_data.health + health_increase, max_health)

func _reset_dine_description():
	if player_data is CharacterData:
		var max_health : int = player_data.max_health
		var current_health : int = player_data.health
		var health_increase : int = float(max_health) * health_gain_ratio
		var raised_health : int = get_raised_health()
		dine_label.text = DINE_DESCRIPTION % [health_gain_ratio*100, health_increase, current_health, max_health, raised_health, max_health]

func get_clean_card_count():
	return 1

func _reset_bath_description():
	if player_data is CharacterData:
		var clean_card_count : int = get_clean_card_count()
		bath_label.text = BATH_DESCRIPTION % [clean_card_count]

func set_player_data(value:CharacterData):
	player_data = value
	_reset_dine_description()

func _heal_player():
	if player_data is CharacterData:
		player_data.health = get_raised_health()

func _on_DineButton_pressed():
	emit_signal("dine_pressed")
	_heal_player()
	emit_signal("shelter_left")
	queue_free()

func _on_BathButton_pressed():
	var deck_cleaner_instance = deck_cleaner_scene.instance()
	emit_signal("bath_pressed", deck_cleaner_instance)
	deck_cleaner_instance.deck = player_data.deck
	deck_cleaner_instance.connect("card_cleaned", self, "_on_Card_cleaned")

func _on_Card_cleaned(card_data):
	player_data.deck.erase(card_data)
	queue_free()
	emit_signal("shelter_left")
