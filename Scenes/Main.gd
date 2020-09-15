extends Control


onready var battle_interface_container = $BattleInterfaceContainer
onready var battle_interface = $BattleInterfaceContainer/BattleInterface
onready var dead_panel = $DeadPanel
onready var shadow_panel = $ShadowPanel
onready var level_manager = $LevelManager
onready var campaign_interface_container = $CampaignInterfaceContainer

var starting_player_data : CharacterData = preload("res://Resources/Characters/Player/NewPlayerData.tres")
var battle_interface_scene : PackedScene = preload("res://Scenes/BattleInterface/BattleInterface.tscn")
var loot_interface_scene : PackedScene = preload("res://Scenes/LootPanel/LootPanel.tscn")
var player_data

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
	player_data = starting_player_data.duplicate()
	start_battle()

func _on_DeadPanel_retry_pressed():
	shadow_panel.hide()
	dead_panel.hide()
	player_data = starting_player_data.duplicate()
	start_battle()

func _on_BattleInterface_player_lost():
	battle_interface.queue_free()
	shadow_panel.show()
	dead_panel.show()

func _on_BattleInterface_player_won():
	battle_interface.queue_free()
	shadow_panel.show()
	var level : LevelData = level_manager.get_current_level()
	var loot_interface = loot_interface_scene.instance()
	campaign_interface_container.add_child(loot_interface)
	loot_interface.connect("collected_card", self, "_on_LootPanel_collected_card")
	loot_interface.connect("tree_exited", self, "_on_LootPanel_tree_exited")
	var card_options : Array = level.lootable_cards.duplicate()
	card_options.shuffle()
	card_options = card_options.slice(0,2)
	loot_interface.card_options = card_options

func _on_LootPanel_collected_card(card:CardData):
	if player_data is CharacterData:
		player_data.deck.append(card)

func _on_LootPanel_tree_exited():
	shadow_panel.hide()
	level_manager.advance()
	start_battle()
