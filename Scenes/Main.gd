extends Control


onready var battle_interface_container = $BattleInterfaceContainer
onready var battle_interface = $BattleInterfaceContainer/BattleInterface
onready var dead_panel = $DeadPanel

var player_data : CharacterData = preload("res://Resources/Characters/Player/NewPlayerData.tres")
var enemy_data : CharacterData = preload("res://Resources/Characters/Opponents/EasyOpponentData.tres")
var battle_interface_scene : PackedScene = preload("res://Scenes/BattleInterface/BattleInterface.tscn")

func start_battle():
	if not is_instance_valid(battle_interface):
		battle_interface = battle_interface_scene.instance()
		battle_interface_container.add_child(battle_interface)
	battle_interface.player_data = player_data.duplicate()
	battle_interface.opponents = [enemy_data,enemy_data]
	battle_interface.start_battle()

func _ready():
	start_battle()


func _on_DeadPanel_retry_pressed():
	dead_panel.hide()
	start_battle()

func _on_BattleInterface_player_lost():
	battle_interface.queue_free()
	dead_panel.show()
