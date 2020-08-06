extends Control


onready var battle_screen = $HUDContainer/BattleScreen
onready var player_screen = $HUDContainer/PlayerScreen

var player : Character = preload("res://Resources/Characters/PlayerSettings/NewPlayerSettings.tres")
var enemy : Character = preload("res://Resources/Characters/Opponents/BasicEnemy.tres")

func _ready():
	player.start()
	enemy.start()
	player_screen.player = player
	player_screen.update_meter()
	battle_screen.player = player
	var opponent : AIOpponent = AIOpponent.new()
	opponent.character = enemy
	battle_screen.opponents = [opponent]
	battle_screen.start()

func _on_BattleScreen_player_updated():
	player_screen.update_meter()
