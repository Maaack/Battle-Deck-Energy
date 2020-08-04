extends Control


onready var battle_screen = $HUDContainer/BattleScreen
onready var player_screen = $HUDContainer/PlayerScreen

var player : Character = preload("res://Resources/Characters/PlayerSettings/NewPlayerSettings.tres")

func _ready():
	player.start()
	player_screen.player = player
	player_screen.update_meter()
	battle_screen.start(player)
	
