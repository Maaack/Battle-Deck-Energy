extends Control


onready var battle_screen = $HUDContainer/BattleScreen
onready var player_screen = $HUDContainer/PlayerScreen

var player : Character = preload("res://Resources/Characters/PlayerSettings/NewPlayerSettings.tres")
var enemy : Character = preload("res://Resources/Characters/Opponents/BasicEnemy.tres")

func _ready():
	var enemy1 : Character = enemy.duplicate()
	var enemy2 : Character = enemy.duplicate()
	var opponent1 : AIOpponent = AIOpponent.new()
	var opponent2 : AIOpponent = AIOpponent.new()
	opponent1.character = enemy1
	opponent2.character = enemy2
	player_screen.player = player
	battle_screen.player = player
	battle_screen.opponents = [opponent1, opponent2]
	battle_screen.start()

func _on_BattleScreen_player_updated():
	player_screen.update_meter()
