extends Control


onready var battle_interface_container = $BattleInterfaceContainer
onready var dead_panel = $DeadPanel
onready var shadow_panel = $ShadowPanel
onready var level_manager = $LevelManager
onready var tooltip_manager = $TooltipManager
onready var mood_manager = $MoodManager
onready var campaign_interface_container = $CampaignInterfaceContainer
onready var deck_view_container = $DeckViewContainer

var starting_player_data : CharacterData = preload("res://Resources/Characters/Player/NewCampaignPlayerData.tres")
var battle_interface_scene : PackedScene = preload("res://Scenes/OldBattleInterface/BattleInterface.tscn")
var loot_interface_scene : PackedScene = preload("res://Scenes/LootPanel/LootPanel.tscn")
var shelter_interface_scene : PackedScene = preload("res://Scenes/ShelterPanel/ShelterPanel.tscn")
var deck_view_scene : PackedScene = preload("res://Scenes/DeckViewer/DeckViewer.tscn")
var story_panel_scene : PackedScene = preload("res://Scenes/ScrollingTextPanel/StoryPanel/StoryPanel.tscn")
var credits_panel_scene : PackedScene = preload("res://Scenes/Credits/Credits.tscn")
var battle_interface
var player_data

func _add_deck_view(deck_viewer:DeckViewer):
	deck_view_container.add_child(deck_viewer)
	deck_viewer.connect("card_inspected", self, "_on_Card_inspected")
	deck_viewer.connect("card_forgotten", self, "_on_Card_forgotten")
	deck_viewer.connect("tree_exited", tooltip_manager, "reset")

func start_battle(current_level:BattleLevelData):
	if is_instance_valid(battle_interface):
		print("Warning: Previous battle has not cleared.")
		battle_interface.queue_free()
		battle_interface = null
	battle_interface = battle_interface_scene.instance()
	battle_interface_container.add_child(battle_interface)
	battle_interface.connect("player_lost", self, "_on_BattleInterface_player_lost")
	battle_interface.connect("player_won", self, "_on_BattleInterface_player_won")
	battle_interface.connect("view_deck_pressed", self, "_on_ViewDeck_pressed")
	battle_interface.connect("card_inspected", self, "_on_Card_inspected")
	battle_interface.connect("card_forgotten", self, "_on_Card_forgotten")
	battle_interface.connect("status_inspected", self, "_on_StatusIcon_inspected")
	battle_interface.connect("status_forgotten", self, "_on_StatusIcon_forgotten")
	battle_interface.player_data = player_data
	battle_interface.opponents = current_level.opponents
	battle_interface.start_battle()

func start_shelter():
	shadow_panel.show()
	var shelter_interface = shelter_interface_scene.instance()
	campaign_interface_container.add_child(shelter_interface)
	shelter_interface.player_data = player_data
	shelter_interface.connect("shelter_left", self, "_start_next_level")
	shelter_interface.connect("bath_pressed", self, "_add_deck_view")

func start_story_level(current_level:StoryLevelData):
	shadow_panel.show()
	var story_interface = story_panel_scene.instance()
	campaign_interface_container.add_child(story_interface)
	story_interface.set_text(current_level.bbcode_text)
	story_interface.connect("continue_pressed", self, "_start_next_level")

func start_credits():
	shadow_panel.show()
	var credits_interface = credits_panel_scene.instance()
	campaign_interface_container.add_child(credits_interface)
	credits_interface.connect("continue_pressed", self, "_start_next_level")

func start_level():
	var current_level : LevelData = level_manager.get_current_level()
	if current_level is BattleLevelData:
		start_battle(current_level)
	elif current_level is ShelterLevelData:
		start_shelter()
	elif current_level is StoryLevelData:
		start_story_level(current_level)
	elif current_level is CreditsLevelData:
		start_credits()
	if current_level.mood_type != "":
		mood_manager.set_mood(current_level.mood_type)

func _start_next_level():
	tooltip_manager.reset()
	shadow_panel.hide()
	level_manager.advance()
	start_level()

func _ready():
	randomize()
	player_data = starting_player_data.duplicate()
	start_level()

func _on_DeadPanel_retry_pressed():
	shadow_panel.hide()
	dead_panel.hide()
	level_manager.reset()
	player_data = starting_player_data.duplicate()
	start_level()

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
	loot_interface.connect("tree_exiting", self, "_start_next_level")
	loot_interface.connect("view_deck_pressed", self, "_on_ViewDeck_pressed")
	loot_interface.connect("card_inspected", self, "_on_Card_inspected")
	loot_interface.connect("card_forgotten", self, "_on_Card_forgotten")
	var card_list : WeightedDataList = level.lootable_cards.duplicate()
	loot_interface.card_options = card_list.slice_random(3)
	loot_interface.player_data = player_data

func _on_LootPanel_card_collected(card:CardData):
	if player_data is CharacterData:
		player_data.deck.append(card)

func _on_ViewDeck_pressed(deck:Array):
	var deck_view = deck_view_scene.instance()
	_add_deck_view(deck_view)
	deck_view.deck = deck

func _on_Card_inspected(card_node):
	tooltip_manager.inspect_card(card_node)

func _on_Card_forgotten(_card_node):
	tooltip_manager.reset()

func _on_StatusIcon_inspected(status_icon):
	tooltip_manager.inspect_status(status_icon)

func _on_StatusIcon_forgotten(_status_icon):
	tooltip_manager.reset()
