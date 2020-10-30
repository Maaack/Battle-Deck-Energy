extends Node


class_name NetworkManager

const DEFAULT_SERVER_IP = '127.0.0.1'
const DEFAULT_SERVER_PORT = 36663
const DEFAULT_MAX_PLAYERS = 2

onready var server_ip : String = DEFAULT_SERVER_IP
onready var server_port : int = DEFAULT_SERVER_PORT

var players : Dictionary = {}
var local_player : PlayerData

signal player_list_changed
signal connection_succeeded
signal connection_failed
signal server_disconnected

sync func register_player(player_id : int, player_name : String):
	var new_player : PlayerData = PlayerData.new()
	new_player.name = player_name
	players[player_id] = new_player
	emit_signal("player_list_changed")

func register_local_player():
	var local_player_id : int = get_tree().get_network_unique_id()
	rpc('register_player', local_player_id, local_player.name)

func unregister_player(player_id : int):
	players.erase(player_id)
	emit_signal("player_list_changed")

func _on_player_disconnected(disconnected_player_id : int):
	unregister_player(disconnected_player_id)

func _on_player_connected(connected_player_id : int):
	var local_player_id : int = get_tree().get_network_unique_id()
	rpc_id(connected_player_id, 'register_player', local_player_id, local_player.name)

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
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')
	get_tree().connect("connected_to_server", self, "_on_connected_to_server")
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	get_tree().connect("server_disconnected", self, "_on_server_disconnected")
