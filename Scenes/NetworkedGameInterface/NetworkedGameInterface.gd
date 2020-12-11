extends Control


onready var battle_interface_container = $BattleInterfaceContainer
onready var lose_panel = $LosePanel
onready var win_panel = $WinPanel
onready var shadow_panel = $ShadowPanel
onready var tooltip_manager = $TooltipManager
onready var mood_manager = $MoodManager
onready var deck_view_container = $DeckViewContainer
onready var waiting_label = $WaitingLabel
onready var game_menu = $NetworkedGameMenu
onready var disconnect_delay_timer = $DisconnectDelayTimer

var starting_player_data : CharacterData = preload("res://Resources/Characters/Player/NetworkedPlayerData.tres")
var default_lame_deck : DeckData = preload("res://Resources/Decks/LamestStartingDeck.tres")
var battle_interface_scene : PackedScene = preload("res://Scenes/BattleInterface/Networked/NetworkedBattleInterface.tscn")
var deck_view_scene : PackedScene = preload("res://Scenes/DeckViewer/DeckViewer.tscn")
var battle_interface
var local_player_character : CharacterData
var local_player_deck : DeckData
var ignore_player_disconnects : Array = []

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
	player.character_data = player_character
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
	shadow_panel.hide()
	waiting_label.hide()
	battle_interface.player_character = local_player_character
	battle_interface.start_battle()
	mood_manager.set_mood(mood_manager.HARD_BATLE_MOOD)

remote func _ignore_player_disconnect(player_id : int):
	var character = Network.get_player_character(player_id)
	battle_interface.kill_character(character)
	ignore_player_disconnects.append(player_id)

func _ignore_all_disconnects():
	Network.disconnect("player_disconnected", self, "_on_player_disconnected")
	Network.disconnect("server_disconnected", self, "_on_server_disconnected")

func all_ready():
	for player_id in Network.players:
		rpc('create_character_for_player', player_id)
	rpc('start_battle')

func _on_deck_selected():
	shadow_panel.show()
	waiting_label.show()
	if Network.is_server():
		Network.connect('synced', self, 'all_ready')
	Network.sync_up()

func _on_player_disconnected(player : PlayerData):
	if player.unique_id in ignore_player_disconnects:
		return
	DialogWindows.report_error('Player `%s` Disconnected!' % player.name)
	Network.leave_server()
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")

func _on_server_disconnected():
	DialogWindows.report_error('Server Disconnected!')
	Network.leave_server()
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")

func _ready():
	Network.connect("player_disconnected", self, "_on_player_disconnected")
	Network.connect("server_disconnected", self, "_on_server_disconnected")
	randomize()
	init_battle_scene()

func _on_DeckSelectorInterface_deck_selected(deck : DeckData):
	local_player_deck = deck
	_on_deck_selected()

func _on_DeadPanel_retry_pressed():
	Network.leave_server()
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")

func _on_WinPanel_return_pressed():
	Network.leave_server()
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")

func _on_BattleInterface_player_lost():
	rpc('_ignore_player_disconnect', Network.local_player.unique_id)
	_ignore_all_disconnects()
	battle_interface.queue_free()
	tooltip_manager.reset()
	shadow_panel.show()
	lose_panel.show()

func _on_BattleInterface_player_won():
	rpc('_ignore_player_disconnect', Network.local_player.unique_id)
	_ignore_all_disconnects()
	battle_interface.queue_free()
	tooltip_manager.reset()
	shadow_panel.show()
	win_panel.show()

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

func _close_menu():
	game_menu.hide()
	game_menu.reset()
	shadow_panel.hide()

func _open_menu():
	shadow_panel.show()
	game_menu.show()
	
func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not game_menu.visible:
			_open_menu()
		else:
			_close_menu()

func _on_NetworkedGameMenu_return_button_pressed():
	_close_menu()

func _on_NetworkedGameMenu_forfeit_and_exit_button_pressed():
	_close_menu()
	rpc('_ignore_player_disconnect', Network.local_player.unique_id)
	disconnect_delay_timer.start()
	yield(disconnect_delay_timer, "timeout")
	Network.leave_server()
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")

func _on_LosePanel_exit_pressed():
	Network.leave_server()
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")
