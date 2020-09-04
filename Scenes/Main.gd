extends Control


onready var battle_interface_container = $BattleInterfaceContainer
onready var battle_interface = $BattleInterfaceContainer/BattleInterface
onready var dead_panel = $DeadPanel
onready var victory_panel = $VictoryPanel
onready var level_manager = $LevelManager

var player_data : CharacterData = preload("res://Resources/Characters/Player/NewPlayerData.tres")
var battle_interface_scene : PackedScene = preload("res://Scenes/BattleInterface/BattleInterface.tscn")

func start_battle():
	if not is_instance_valid(battle_interface):
		battle_interface = battle_interface_scene.instance()
		battle_interface_container.add_child(battle_interface)
		battle_interface.connect("player_lost", self, "_on_BattleInterface_player_lost")
		battle_interface.connect("player_won", self, "_on_BattleInterface_player_won")
	battle_interface.player_data = player_data
	battle_interface.opponents = level_manager.get_level_opponents()
	battle_interface.start_battle()

func _ready():
	start_battle()

func _on_DeadPanel_retry_pressed():
	dead_panel.hide()
	start_battle()

func _on_BattleInterface_player_lost():
	battle_interface.queue_free()
	dead_panel.show()

func _on_BattleInterface_player_won():
	battle_interface.queue_free()
	victory_panel.show()

func _on_VictoryPanel_continue_pressed():
	victory_panel.hide()
	level_manager.advance()
	start_battle()
