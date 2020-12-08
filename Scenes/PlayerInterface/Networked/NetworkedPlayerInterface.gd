extends PlayerInterface

onready var battle_board = $BattleBoard

var _opponent_hand_manager_scene = preload("res://Managers/Cards/Puppet/PuppetCardManager.tscn")
var card_library : CommonData = preload("res://Resources/Common/CardLibrary.tres")
var _opponent_hand_managers : Dictionary = {}
var _opponent_interfaces : Dictionary = {}
var _remote_opponent_card_map : Dictionary = {}

func _new_hand_manager(opponent : CharacterData, interface : OpponentActionsInterface):
	var opponent_hand_manager = _opponent_hand_manager_scene.instance()
	interface.opponent_hand_container.add_child(opponent_hand_manager)
	opponent_hand_manager.scale = interface.get_hand_scale()
	_opponent_hand_managers[opponent] = opponent_hand_manager

func add_opponent(opponent:CharacterData):
	var interface : OpponentActionsInterface = .add_opponent(opponent)
	_opponent_interfaces[opponent] = interface
	_new_hand_manager(opponent, interface)
	return interface

func _on_remote_opponent_draw_card(opponent : CharacterData, card : CardData):
	var opponent_hand_manager : CardManager = _opponent_hand_managers[opponent]
	opponent_hand_manager.add_card(card)
	opponent_hand_manager.force_move_card(card, TransformData.new(), 0.1)

remote func _remote_opponent_draw_card(player_id, card_key : String):
	var opponent : CharacterData = Network.get_player_character(player_id)
	var draw_card : CardData = CardData.new()
	draw_card.title = card_key
	if not opponent in _remote_opponent_card_map:
		_remote_opponent_card_map[opponent] = {}
	_remote_opponent_card_map[opponent][card_key] = draw_card
	_on_remote_opponent_draw_card(opponent, draw_card)

func remote_opponent_draw_card(card : CardData):
	rpc('_remote_opponent_draw_card', Network.local_player.unique_id, str(card.get_instance_id()))

func draw_card(card_data:CardData):
	.draw_card(card_data)
	remote_opponent_draw_card(card_data)

func _on_remote_opponent_discard_card(opponent : CharacterData, card : CardData):
	var opponent_hand_manager : CardManager = _opponent_hand_managers[opponent]
	opponent_hand_manager.remove_card(card)

remote func _remote_opponent_discard_card(player_id : int, card_key : String):
	var opponent : CharacterData = Network.get_player_character(player_id)
	if not card_key in _remote_opponent_card_map[opponent]:
		print("Error! remote opponent discarding unknown card `%s` `%s`" % [opponent, card_key])
		return
	var discard_card : CardData = _remote_opponent_card_map[opponent][card_key]
	_on_remote_opponent_discard_card(opponent, discard_card)

func remote_opponent_discard_card(card : CardData):
	rpc('_remote_opponent_discard_card', Network.local_player.unique_id, str(card.get_instance_id()))

func discard_card(card_data:CardData):
	.discard_card(card_data)
	remote_opponent_discard_card(card_data)

func exhaust_card(card_data:CardData):
	.exhaust_card(card_data)
	remote_opponent_discard_card(card_data)

func _on_remote_opponent_move_card(opponent : CharacterData, card : CardData, transform : TransformData, tween_time : float):
	var opponent_hand_manager : CardManager = _opponent_hand_managers[opponent]
	opponent_hand_manager.move_card(card, transform, tween_time)

remote func _remote_opponent_move_card(player_id : int, card_key : String, position_x : float, position_y : float, rotation : float, scale_x : float, scale_y : float, tween_time : float):
	var opponent : CharacterData = Network.get_player_character(player_id)
	var move_card : CardData = _remote_opponent_card_map[opponent][card_key]
	var new_transform : TransformData = TransformData.new()
	move_card.title = card_key
	new_transform.position = Vector2(position_x, position_y)
	new_transform.rotation = rotation
	new_transform.scale = Vector2(scale_x, scale_y)
	_on_remote_opponent_move_card(opponent, move_card, new_transform, tween_time)

func _on_HandManager_card_updated(card_data:CardData, transform:TransformData):
	card_manager.move_card(card_data, transform, 0.1)
	rpc('_remote_opponent_move_card', Network.local_player.unique_id, str(card_data.get_instance_id()), transform.position.x, transform.position.y, transform.rotation, transform.scale.x, transform.scale.y, 0.1)

remote func _remote_opponent_play_card(player_id : int, card_key : String):
	var opponent : CharacterData = Network.get_player_character(player_id)
	var opponent_interface : OpponentActionsInterface = _opponent_interfaces[opponent]
	var manager_offset : Vector2 = opponent_card_manager.get_global_transform().get_origin()
	var card : CardData = card_library.data[card_key]
	card = card.duplicate()
	card.transform_data = opponent_interface.get_reveal_transform()
	card.transform_data.position -= manager_offset
	_new_character_card(opponent, card)
	var card_instance : CardNode2D = _new_character_card(opponent, card)
	card_instance.play_card()
	.discard_card(card)

func _on_play_card_on_opportunity(card:CardData, opportunity: OpportunityData):
	._on_play_card_on_opportunity(card, opportunity)
	rpc('_remote_opponent_play_card', Network.local_player.unique_id, card.title)
