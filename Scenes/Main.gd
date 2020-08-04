extends Control


onready var battle_screen = $HUDContainer/BattleScreen

var player : Character = preload("res://Resources/Characters/PlayerSettings/NewPlayerSettings.tres")

func _ready():
	player.start()
	battle_screen.start(player)
	
