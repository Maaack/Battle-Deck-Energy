extends Control


signal dine_pressed
signal bath_pressed(deck_cleaner_instance)
signal shelter_left

const DINE_DESCRIPTION = "Heal %d%% (%d) of your Max Health\n%d/%d --> %d/%d"
const BATH_DESCRIPTION = "Clean your Deck of %d Card"

onready var dine_label = $OptionsContainer/HBoxContainer/DineControl/Label
onready var bath_label = $OptionsContainer/HBoxContainer/BathControl/Label
onready var dine_button = $OptionsContainer/HBoxContainer/DineControl/DineButton
onready var bath_button = $OptionsContainer/HBoxContainer/BathControl/BathButton
onready var card_manager = $CentralControl/CardManager
onready var central_control = $CentralControl
onready var continue_delay_timer = $ContinueDelayTimer
onready var particle_generator = $CentralControl/Particles2D

var deck_cleaner_scene = preload("res://Scenes/DeckViewer/DeckCleaner/DeckCleaner.tscn")
var status_text_animation = preload("res://Scenes/PlayerInterface/BattleBoard/ActionsBoard/StatusTextAnimation/StatusTextAnimation.tscn")
var health_status_base = preload("res://Resources/Statuses/Health.tres")
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

func disable_buttons():
	dine_button.disabled = true
	bath_button.disabled = true

func _on_DineButton_pressed():
	disable_buttons()
	emit_signal("dine_pressed")
	continue_delay_timer.start()
	yield(continue_delay_timer, "timeout")
	var raised_health : int = get_raised_health()
	var delta : int = raised_health - player_data.health
	var status_update_instance = status_text_animation.instance()
	particle_generator.emitting = true
	_heal_player()
	central_control.add_child(status_update_instance)
	status_update_instance.set_status_update(health_status_base, delta)
	yield(status_update_instance, "tree_exited")
	particle_generator.emitting = false
	continue_delay_timer.start()
	yield(continue_delay_timer, "timeout")
	emit_signal("shelter_left")
	queue_free()

func _on_BathButton_pressed():
	var deck_cleaner_instance = deck_cleaner_scene.instance()
	emit_signal("bath_pressed", deck_cleaner_instance)
	deck_cleaner_instance.deck = player_data.deck
	deck_cleaner_instance.connect("card_cleaned", self, "_on_Card_cleaned")

func _on_Card_cleaned(card_data:CardData):
	disable_buttons()
	card_data.transform_data.position = Vector2(0, 0)
	card_manager.add_card(card_data)
	continue_delay_timer.start()
	yield(continue_delay_timer, "timeout")
	var new_transform = card_data.transform_data.duplicate()
	new_transform.scale = Vector2(0.05, 0.05)
	card_manager.move_card(card_data, new_transform)
	yield(card_manager, "tween_completed")
	particle_generator.emitting = true
	card_manager.remove_card(card_data)
	player_data.deck.erase(card_data)
	continue_delay_timer.start()
	yield(continue_delay_timer, "timeout")
	particle_generator.emitting = false
	continue_delay_timer.start()
	yield(continue_delay_timer, "timeout")
	emit_signal("shelter_left")
	queue_free()
