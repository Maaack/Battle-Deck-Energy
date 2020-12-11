extends Node


class_name NetworkManager

const DEFAULT_SERVER_IP = '127.0.0.1'
const DEFAULT_SERVER_PORT = 36663
const DEFAULT_MAX_PLAYERS = 2

onready var server_ip : String = DEFAULT_SERVER_IP
onready var server_port : int = DEFAULT_SERVER_PORT

var players : Dictionary = {}
var players_synced : Array = []
var local_player : PlayerData

signal player_list_changed
signal player_disconnected(player)
signal player_connected(player)
signal connection_succeeded
signal connection_failed
signal server_disconnected
signal synced

func is_server():
	return get_tree().get_network_unique_id() == 1

remotesync func _register_player(player_id : int, player_name : String):
	var connected_player : PlayerData = PlayerData.new()
	connected_player.name = player_name
	connected_player.unique_id = player_id
	players[player_id] = connected_player
	if player_id == get_tree().get_network_unique_id():
		local_player = connected_player
	emit_signal("player_connected", connected_player)
	emit_signal("player_list_changed")

func _unregister_player(player_id : int):
	var disconnected_player = players[player_id]
	players.erase(player_id)
	emit_signal("player_disconnected", disconnected_player)
	emit_signal("player_list_changed")

remotesync func _sync_player(player_id : int):
	if not player_id in players_synced:
		players_synced.append(player_id)
	if players_synced.size() == players.size():
		players_synced.clear()
		emit_signal('synced')

func sync_up():
	rpc('_sync_player', get_tree().get_network_unique_id())

func register_local_player():
	var local_player_id : int = get_tree().get_network_unique_id()
	rpc('_register_player', local_player_id, local_player.name)

func _on_player_disconnected(disconnected_player_id : int):
	_unregister_player(disconnected_player_id)

func _on_player_connected(connected_player_id : int):
	var local_player_id : int = get_tree().get_network_unique_id()
	rpc_id(connected_player_id, '_register_player', local_player_id, local_player.name)

func _on_connected_to_server():
	register_local_player()
	emit_signal("connection_succeeded")

func _on_connection_failed():
	get_tree().set_network_peer(null)
	emit_signal("connection_failed")

func _on_server_disconnected():
	players.clear()
	emit_signal("server_disconnected")

func host_server(port : int = DEFAULT_SERVER_PORT, max_players : int = DEFAULT_MAX_PLAYERS):
	server_port = port
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, max_players)
	get_tree().set_network_peer(peer)
	register_local_player()

func join_server(ip : String = DEFAULT_SERVER_IP, port : int = DEFAULT_SERVER_PORT):
	server_ip = ip
	server_port = port
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)

func leave_server():
	players.clear()
	get_tree().set_network_peer(null)

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected', [], CONNECT_DEFERRED)
	get_tree().connect('network_peer_connected', self, '_on_player_connected', [], CONNECT_DEFERRED)
	get_tree().connect("connected_to_server", self, "_on_connected_to_server", [], CONNECT_DEFERRED)
	get_tree().connect("connection_failed", self, "_on_connection_failed", [], CONNECT_DEFERRED)
	get_tree().connect("server_disconnected", self, "_on_server_disconnected", [], CONNECT_DEFERRED)

func get_player_character(player_id : int):
	var player : PlayerData = players[player_id]
	return player.character_data

func get_character_player_id(character):
	for player_id in players:
		var player : PlayerData = players[player_id]
		if player.character_data == character:
			return player_id
