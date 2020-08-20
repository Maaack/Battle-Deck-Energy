extends Control


onready var battle_interface = $BattleInterface

var player_data : CharacterData = preload("res://Resources/Characters/Player/NewPlayerData.tres")
var enemy_data : CharacterData = preload("res://Resources/Characters/Opponents/EasyOpponentData.tres")

func _ready():
	battle_interface.player_data = player_data
	battle_interface.opponents = [enemy_data,enemy_data]
	battle_interface.start_battle()
