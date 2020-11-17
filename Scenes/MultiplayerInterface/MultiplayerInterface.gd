extends Control


onready var battle_interface_container = $BattleInterfaceContainer
onready var dead_panel = $DeadPanel
onready var shadow_panel = $ShadowPanel
onready var tooltip_manager = $TooltipManager
onready var mood_manager = $MoodManager
onready var deck_view_container = $DeckViewContainer

var starting_player_data : CharacterData = preload("res://Resources/Characters/Player/MultiplayerPlayerData.tres")
var default_lame_deck : DeckData = preload("res://Resources/Decks/LamestStartingDeck.tres")
var battle_interface_scene : PackedScene = preload("res://Scenes/BattleInterface/Multiplayer/MultiplayerBattleInterface.tscn")
var deck_view_scene : PackedScene = preload("res://Scenes/DeckViewer/DeckViewer.tscn")
var battle_interface
var local_player_character : CharacterData
var local_player_deck : DeckData

func _add_deck_view(deck_viewer:DeckViewer):
	deck_view_container.add_child(deck_viewer)
	deck_viewer.connect("card_inspected", self, "_on_Card_inspected")
	deck_viewer.connect("card_forgotten", self, "_on_Card_forgotten")
	deck_viewer.connect("tree_exited", tooltip_manager, "reset")

remotesync func create_character_for_player(player_id : int):
	if not player_id in Network.players:
		print("Warning: player_id %d does not exist in network players." % player_id)
		return
	var player : PlayerData = Network.players[player_id]
	var player_character : CharacterData = starting_player_data.duplicate()
	player_character.nickname = player.name
	if player.name == Network.local_player.name:
		local_player_character = player_character
		player_character.deck = local_player_deck.cards
	else:
		player_character.deck = default_lame_deck.cards
	battle_interface.add_player(player_id, player_character, player.name)

remotesync func init_battle_scene():
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

remotesync func start_battle():
	battle_interface.player_character = local_player_character
	battle_interface.start_battle()

func all_ready():
	for player_id in Network.players:
		rpc('create_character_for_player', player_id)
	rpc('start_battle')

func _on_deck_selected():
	if Network.is_server():
		Network.connect('synced', self, 'all_ready')
	Network.sync_up()

func _ready():
	randomize()
	init_battle_scene()

func _on_DeckSelectorInterface_deck_selected(deck : DeckData):
	local_player_deck = deck
	_on_deck_selected()

func _on_DeadPanel_retry_pressed():
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")

func _on_BattleInterface_player_lost():
	battle_interface.queue_free()
	tooltip_manager.reset()
	shadow_panel.show()
	dead_panel.show()

func _on_BattleInterface_player_won():
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")

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
