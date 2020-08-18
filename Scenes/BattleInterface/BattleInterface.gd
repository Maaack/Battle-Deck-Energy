extends Control


onready var player_interface = $PlayerInterface

var player : Character = preload("res://Resources/Characters/PlayerSettings/NewPlayerSettings.tres")
var enemy : Character = preload("res://Resources/Characters/Opponents/BasicEnemy.tres")

func _ready():
	var enemy1 : Character = enemy.duplicate()
	var enemy2 : Character = enemy.duplicate()
	var opponent1 : AIOpponent = AIOpponent.new()
	var opponent2 : AIOpponent = AIOpponent.new()
	opponent1.character = enemy1
	opponent2.character = enemy2
	player.start()
	player_interface.set_draw_pile_count(player.deck_size())
	var cards = []
	var attack_card = load("res://Resources/Cards/AttackCard.tres")
	cards.append(attack_card.duplicate())
	cards.append(attack_card.duplicate())
	cards.append(attack_card.duplicate())
	cards.append(attack_card.duplicate())
	cards.append(attack_card.duplicate())
	player_interface.draw_cards(cards)
