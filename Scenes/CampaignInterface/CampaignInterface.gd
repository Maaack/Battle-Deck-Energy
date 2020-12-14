extends Control


const PLAYER_TEAM = "Player"
const ENEMY_TEAM = "Enemy"

onready var battle_interface_container = $BattleInterfaceContainer
onready var dead_panel = $DeadPanel
onready var battle_shadow_panel = $BattleShadowPanel
onready var master_shadow_panel = $MasterShadowPanel
onready var level_manager = $LevelManager
onready var tooltip_manager = $TooltipManager
onready var mood_manager = $MoodManager
onready var campaign_interface_container = $CampaignInterfaceContainer
onready var deck_view_container = $DeckViewContainer
onready var level_delay_timer = $LevelDelayTimer
onready var game_menu = $CampaignGameMenu

export(Resource) var starting_player_data : Resource = preload("res://Resources/Characters/Player/NewCampaignPlayerData.tres")
export(Resource) var starting_deck_data : Resource = preload("res://Resources/Decks/LamestStartingDeck.tres")

var battle_interface_scene : PackedScene = preload("res://Scenes/BattleInterface/Campaign/CampaignBattleInterface.tscn")
var loot_interface_scene : PackedScene = preload("res://Scenes/LootPanel/LootPanel.tscn")
var shelter_interface_scene : PackedScene = preload("res://Scenes/ShelterPanel/ShelterPanel.tscn")
var deck_view_scene : PackedScene = preload("res://Scenes/DeckViewer/DeckViewer.tscn")
var story_panel_scene : PackedScene = preload("res://Scenes/ScrollingTextPanel/StoryPanel/StoryPanel.tscn")
var credits_panel_scene : PackedScene = preload("res://Scenes/Credits/Credits.tscn")
var save_deck_panel_scene : PackedScene = preload("res://Scenes/SaveDeck/SaveDeckPanel.tscn")
var player_data : CharacterData
var battle_interface : BattleInterface
var campaign_seed : int

func _attach_deck_view(deck_viewer:DeckViewer):
	deck_view_container.add_child(deck_viewer)
	deck_viewer.connect("card_inspected", self, "_on_Card_inspected")
	deck_viewer.connect("card_forgotten", self, "_on_Card_forgotten")
	deck_viewer.connect("back_pressed", self, "_remove_deck_view", [deck_viewer])

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
	battle_interface.add_character(player_data, PLAYER_TEAM)
	for opponent in current_level.opponents:
		battle_interface.add_character(opponent.duplicate(), ENEMY_TEAM)
	battle_interface.player_character = player_data
	battle_shadow_panel.hide()
	battle_interface.start_battle()

func start_shelter():
	battle_shadow_panel.show()
	var shelter_interface = shelter_interface_scene.instance()
	campaign_interface_container.add_child(shelter_interface)
	shelter_interface.player_data = player_data
	shelter_interface.connect("level_completed", self, "_unload_levels_and_continue")
	shelter_interface.connect("bath_pressed", self, "_attach_deck_view")

func start_story_level(current_level:StoryLevelData):
	battle_shadow_panel.show()
	var story_interface = story_panel_scene.instance()
	campaign_interface_container.add_child(story_interface)
	story_interface.set_text(current_level.bbcode_text)
	story_interface.connect("continue_pressed", self, "_start_next_level")

func start_credits():
	battle_shadow_panel.show()
	var credits_interface = credits_panel_scene.instance()
	campaign_interface_container.add_child(credits_interface)
	credits_interface.connect("continue_pressed", self, "_start_next_level")

func _on_save_deck(cards : Array, title : String, icon : Texture):
	PersistentData.save_deck(cards, title, icon)
	_start_next_level()

func save_deck():
	battle_shadow_panel.show()
	var save_deck_interface = save_deck_panel_scene.instance()
	campaign_interface_container.add_child(save_deck_interface)
	save_deck_interface.cards = player_data.deck
	save_deck_interface.connect("save_pressed", self, "_on_save_deck")
	save_deck_interface.connect("skip_pressed", self, "_start_next_level")

func start_level():
	PersistentData.save_progress(campaign_seed, player_data, level_manager.current_level)
	seed(campaign_seed + level_manager.current_level)
	var current_level : LevelData = level_manager.get_current_level()
	if current_level is BattleLevelData:
		start_battle(current_level)
	elif current_level is ShelterLevelData:
		start_shelter()
	elif current_level is StoryLevelData:
		start_story_level(current_level)
	elif current_level is CreditsLevelData:
		start_credits()
	elif current_level is SaveDeckLevelData:
		save_deck()
	if current_level.mood_type != "":
		mood_manager.set_mood(current_level.mood_type)

func _start_next_level():
	master_shadow_panel.show()
	level_delay_timer.start()
	yield(level_delay_timer, "timeout")
	tooltip_manager.reset()
	master_shadow_panel.hide()
	level_manager.advance()
	start_level()

func _clear_all_levels():
	if is_instance_valid(battle_interface):
		battle_interface.queue_free()
		battle_interface = null
	for child in campaign_interface_container.get_children():
		child.queue_free()

func _restart_level():
	_clear_all_levels()
	player_data = starting_player_data.duplicate()
	var last_seed = PersistentData.get_last_seed()
	if last_seed != 0:
		campaign_seed = last_seed
		var last_deck : DeckData = PersistentData.get_last_deck()
		for card in last_deck.cards:
			player_data.deck.append(card.duplicate())
		player_data.health = PersistentData.get_last_health()
		level_manager.current_level = PersistentData.get_last_level()
	start_level()

func _ready():
	player_data = starting_player_data.duplicate()
	var last_seed : int = PersistentData.get_last_seed()
	var last_cards : Array = []
	if last_seed != 0:
		campaign_seed = last_seed
		var last_deck : DeckData = PersistentData.get_last_deck()
		last_cards = last_deck.cards
		player_data.health = PersistentData.get_last_health()
		level_manager.current_level = PersistentData.get_last_level()
	else:
		randomize()
		campaign_seed = randi()
		last_cards = starting_deck_data.cards
	for card in last_cards:
		player_data.deck.append(card.duplicate())
	start_level()

func _on_DeadPanel_retry_pressed():
	battle_shadow_panel.hide()
	dead_panel.hide()
	_restart_level()

func _on_DeadPanel_forfeit_pressed():
	battle_shadow_panel.hide()
	dead_panel.hide()
	PersistentData.reset_progress()
	get_tree().change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func _on_DeadPanel_exit_pressed():
	battle_shadow_panel.hide()
	dead_panel.hide()
	get_tree().change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func _on_BattleInterface_player_lost():
	battle_interface.queue_free()
	tooltip_manager.reset()
	battle_shadow_panel.show()
	dead_panel.show()

func _unload_levels_and_continue():
	battle_shadow_panel.hide()
	_clear_all_levels()
	_start_next_level()

func _on_BattleInterface_player_won():
	battle_interface.queue_free()
	tooltip_manager.reset()
	battle_shadow_panel.show()
	var level : LevelData = level_manager.get_current_level()
	var loot_interface = loot_interface_scene.instance()
	campaign_interface_container.add_child(loot_interface)
	loot_interface.connect("card_collected", self, "_on_LootPanel_card_collected")
	loot_interface.connect("level_completed", self, "_unload_levels_and_continue")
	loot_interface.connect("view_deck_pressed", self, "_on_ViewDeck_pressed")
	loot_interface.connect("card_inspected", self, "_on_Card_inspected")
	loot_interface.connect("card_forgotten", self, "_on_Card_forgotten")
	var card_list : WeightedDataList = level.lootable_cards.duplicate()
	loot_interface.card_options = card_list.slice_random(3)
	loot_interface.player_data = player_data

func _on_LootPanel_card_collected(card:CardData):
	if player_data is CharacterData:
		player_data.deck.append(card)

func _remove_deck_view(deck_viewer:Node):
	deck_viewer.queue_free()
	get_tree().paused = false
	tooltip_manager.reset()

func _on_ViewDeck_pressed(deck:Array):
	var deck_view = deck_view_scene.instance()
	get_tree().paused = true
	_attach_deck_view(deck_view)
	deck_view.deck = deck

func _on_Card_inspected(card_node):
	tooltip_manager.inspect_card(card_node)

func _on_Card_forgotten(_card_node):
	tooltip_manager.reset()

func _on_StatusIcon_inspected(status_icon):
	tooltip_manager.inspect_status(status_icon)

func _on_StatusIcon_forgotten(_status_icon):
	tooltip_manager.reset()

func _close_menu():
	game_menu.hide()
	game_menu.reset()
	master_shadow_panel.hide()
	get_tree().paused = false

func _open_menu():
	get_tree().paused = true
	master_shadow_panel.show()
	game_menu.show()
	
func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not game_menu.visible:
			_open_menu()
		else:
			_close_menu()

func _on_CampaignGameMenu_restart_button_pressed():
	_close_menu()
	_restart_level()

func _on_CampaignGameMenu_return_button_pressed():
	_close_menu()

func _on_CampaignGameMenu_save_and_exit_button_pressed():
	_close_menu()
	if not PersistentData.has_progress():
		print("Error: Progress recreated during level")
		PersistentData.save_progress(campaign_seed, player_data, level_manager.current_level)
	get_tree().change_scene("res://Scenes/MainMenu/MainMenu.tscn")
