extends Control


onready var battle_interface_container = $BattleInterfaceContainer
onready var battle_interface = $BattleInterfaceContainer/BattleInterface
onready var dead_panel = $DeadPanel
onready var shadow_panel = $ShadowPanel
onready var level_manager = $LevelManager
onready var tooltip_manager = $TooltipManager
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
		battle_interface.connect("card_inspected", self, "_on_Card_inspected")
		battle_interface.connect("card_forgotten", self, "_on_Card_forgotten")
		battle_interface.connect("status_inspected", self, "_on_StatusIcon_forgotten")
		battle_interface.connect("status_forgotten", self, "_on_StatusIcon_forgotten")
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
	tooltip_manager.reset()
	shadow_panel.show()
	dead_panel.show()

func _on_BattleInterface_player_won():
	battle_interface.queue_free()
	tooltip_manager.reset()
	shadow_panel.show()
	var level : LevelData = level_manager.get_current_level()
	var loot_interface = loot_interface_scene.instance()
	campaign_interface_container.add_child(loot_interface)
	loot_interface.connect("card_collected", self, "_on_LootPanel_card_collected")
	loot_interface.connect("skip_loot_pressed", self, "_on_LootPanel_skip_loot_pressed")
	loot_interface.connect("view_deck_pressed", self, "_on_ViewDeck_pressed")
	loot_interface.connect("card_inspected", self, "_on_Card_inspected")
	loot_interface.connect("card_forgotten", self, "_on_Card_forgotten")
	var card_list : WeightedDataList = level.lootable_cards.duplicate()
	loot_interface.card_options = card_list.slice_random(3)
	loot_interface.player_data = player_data

func _on_LootPanel_card_collected(card:CardData):
	if player_data is CharacterData:
		player_data.deck.append(card)
	_on_LootPanel_closed()

func _on_LootPanel_closed():
	tooltip_manager.reset()
	shadow_panel.hide()
	level_manager.advance()
	start_battle()

func _on_LootPanel_skip_loot_pressed():
	_on_LootPanel_closed()

func _on_ViewDeck_pressed(deck:Array):
	var deck_view = deck_view_scene.instance()
	deck_view_container.add_child(deck_view)
	deck_view.connect("card_inspected", self, "_on_Card_inspected")
	deck_view.connect("card_forgotten", self, "_on_Card_forgotten")
	deck_view.deck = deck

func _on_Card_inspected(card_node):
	tooltip_manager.inspect_card(card_node)

func _on_Card_forgotten(_card_node):
	tooltip_manager.reset()

func _on_StatusIcon_inspected(status_icon):
	tooltip_manager.inspect_status(status_icon)

func _on_StatusIcon_forgotten(status_icon):
	tooltip_manager.reset()
