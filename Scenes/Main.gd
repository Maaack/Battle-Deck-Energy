extends Control


onready var battle_interface_container = $BattleInterfaceContainer
onready var battle_interface = $BattleInterfaceContainer/BattleInterface
onready var dead_panel = $DeadPanel
onready var shadow_panel = $ShadowPanel
onready var level_manager = $LevelManager
onready var campaign_interface_container = $CampaignInterfaceContainer
onready var deck_view_container = $DeckViewContainer

var starting_player_data : CharacterData = preload("res://Resources/Characters/Player/NewPlayerData.tres")
var battle_interface_scene : PackedScene = preload("res://Scenes/BattleInterface/BattleInterface.tscn")
var loot_interface_scene : PackedScene = preload("res://Scenes/LootPanel/LootPanel.tscn")
var deck_view_scene : PackedScene = preload("res://Scenes/DeckViewer/DeckViewer.tscn")
var player_data

func start_battle():
	if not is_instance_valid(battle_interface):
		battle_interface = battle_interface_scene.instance()
		battle_interface_container.add_child(battle_interface)
		battle_interface.connect("player_lost", self, "_on_BattleInterface_player_lost")
		battle_interface.connect("player_won", self, "_on_BattleInterface_player_won")
		battle_interface.connect("view_deck_pressed", self, "_on_ViewDeck_pressed")
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
	loot_interface.connect("skip_loot_pressed", self, "_on_LootPanel_skip_loot_pressed")
	loot_interface.connect("view_deck_pressed", self, "_on_ViewDeck_pressed")
	var card_options : Array = level.lootable_cards.duplicate()
	card_options.shuffle()
	card_options = card_options.slice(0,2)
	loot_interface.card_options = card_options
	loot_interface.player_data = player_data

func _on_LootPanel_collected_card(card:CardData):
	if player_data is CharacterData:
		player_data.deck.append(card)
	_on_LootPanel_closed()

func _on_LootPanel_closed():
	shadow_panel.hide()
	level_manager.advance()
	start_battle()

func _on_LootPanel_skip_loot_pressed():
	_on_LootPanel_closed()

func _on_ViewDeck_pressed(deck:Array):
	var deck_view = deck_view_scene.instance()
	deck_view_container.add_child(deck_view)
	deck_view.deck = deck

func _on_BattleInterface_view_deck_pressed(deck):
	_on_ViewDeck_pressed(deck)
