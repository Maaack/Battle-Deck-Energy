extends Control


onready var player_name_line_edit = $MultiplayerPanel/OptionsMargin/OptionsVBox/PlayerNameContainer/PlayerNameLineEdit
onready var ip_line_edit = $MultiplayerPanel/OptionsMargin/OptionsVBox/OptionsHBox/ServerIPContainer/IPLineEdit
onready var port_line_edit = $MultiplayerPanel/OptionsMargin/OptionsVBox/OptionsHBox/ServerPortContainer/PortLineEdit

signal back_button_pressed

func _on_BackButton_pressed():
	emit_signal("back_button_pressed")
	get_tree().change_scene("res://Scenes/MainMenu/MainMenu.tscn")

func _on_HostButton_pressed():
	var port : int = port_line_edit.text.to_int()
	if port == 0:
		port = Network.DEFAULT_SERVER_PORT
	Network.host_server(port)
	$MultiplayerPanel.hide()
	$LobbyPanel.show()
	refresh_lobby()

func _on_JoinButton_pressed():
	var ip : String = ip_line_edit.text
	var port : int = port_line_edit.text.to_int()
	if ip == "":
		ip = Network.DEFAULT_SERVER_IP
	if port == 0:
		port = Network.DEFAULT_SERVER_PORT
	Network.join_server(ip, port)

func _on_connection_succeeded():
	$MultiplayerPanel.hide()
	$LobbyPanel.show()

func refresh_lobby():
	var players : Array = Network.players.values()
	$LobbyPanel/ItemList.clear()
	for player in players:
		if player is PlayerData:
			$LobbyPanel/ItemList.add_item(player.name)
	$LobbyPanel/ButtonsMargin/ButtonsHBox/StartButton.disabled = not get_tree().is_network_server()

func _ready():
	Network.connect("connection_failed", self, "_on_connection_failed")
	Network.connect("connection_succeeded", self, "_on_connection_succeeded")
	Network.connect("player_list_changed", self, "refresh_lobby")
	Network.connect("server_disconnected", self, "_on_server_disconnected")
	var new_player : PlayerData = PlayerData.new()
	if OS.has_environment("USERNAME"):
		new_player.name = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		new_player.name = desktop_path[desktop_path.size() - 2]
	Network.local_player = new_player
	player_name_line_edit.text = Network.local_player.name
	ip_line_edit.text = Network.server_ip
	port_line_edit.text = str(Network.server_port)

func _on_PlayerNameLineEdit_text_changed(new_text):
	Network.local_player.name = new_text

func _on_IPLineEdit_text_changed(new_text:String):
	$MultiplayerPanel/ButtonsMargin/ButtonsHBox/JoinButton.disabled = not new_text.is_valid_ip_address()

func open_multiplayer_menu():
	$LobbyPanel.hide()
	$MultiplayerPanel.show()

func _on_server_disconnected():
	open_multiplayer_menu()

func _on_LeaveButton_pressed():
	Network.leave_server()
	open_multiplayer_menu()
