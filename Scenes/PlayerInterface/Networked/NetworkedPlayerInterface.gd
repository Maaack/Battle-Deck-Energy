extends PlayerInterface

onready var battle_board = $BattleBoard

var _opponent_hand_manager_scene = preload("res://Managers/Cards/Puppet/PuppetCardManager.tscn")
var _opponent_hand_managers : Dictionary = {}
var _opponent_interfaces : Dictionary = {}
var _remote_opponent_card_map : Dictionary = {}

func _new_hand_manager(opponent : CharacterData, interface : OpponentActionsInterface):
	var opponent_hand_manager = _opponent_hand_manager_scene.instance()
	interface.opponent_hand_container.add_child(opponent_hand_manager)
	opponent_hand_manager.scale = interface.get_hand_scale()
	_opponent_hand_managers[opponent] = opponent_hand_manager

func _on_remote_opponent_draw_card(opponent : CharacterData, card : CardData):
	var opponent_hand_manager : CardManager = _opponent_hand_managers[opponent]
	opponent_hand_manager.add_card(card)
	opponent_hand_manager.force_move_card(card, TransformData.new(), 0.1)

remote func _remote_opponent_draw_card(opponent_nickname : String, card_key : String):
	for opponent in _opponent_hand_managers:
		if opponent is CharacterData and opponent.nickname == opponent_nickname:
			var draw_card : CardData = CardData.new()
			draw_card.title = card_key
			if not opponent_nickname in _remote_opponent_card_map:
				_remote_opponent_card_map[opponent_nickname] = {}
			_remote_opponent_card_map[opponent_nickname][card_key] = draw_card
			_on_remote_opponent_draw_card(opponent, draw_card)
			break

func remote_opponent_draw_card(opponent : CharacterData, card : CardData):
	rpc('_remote_opponent_draw_card', opponent.nickname, str(card.get_instance_id()))

func draw_card(card_data:CardData):
	.draw_card(card_data)
	remote_opponent_draw_card(player_data, card_data)

func _on_remote_opponent_discard_card(opponent : CharacterData, card : CardData):
	var opponent_hand_manager : CardManager = _opponent_hand_managers[opponent]
	opponent_hand_manager.remove_card(card)

remote func _remote_opponent_discard_card(opponent_nickname : String, card_key : String):
	for opponent in _opponent_hand_managers:
		if opponent is CharacterData and opponent.nickname == opponent_nickname:
			if not card_key in _remote_opponent_card_map[opponent_nickname]:
				print("Error! remote opponent discarding unknown card `%s` `%s`" % [opponent_nickname, card_key])
				return
			var discard_card : CardData = _remote_opponent_card_map[opponent_nickname][card_key]
			_on_remote_opponent_discard_card(opponent, discard_card)
			break

func remote_opponent_discard_card(opponent : CharacterData, card : CardData):
	rpc('_remote_opponent_discard_card', opponent.nickname, str(card.get_instance_id()))

func discard_card(card_data:CardData):
	.discard_card(card_data)
	remote_opponent_discard_card(player_data, card_data)

func exhaust_card(card_data:CardData):
	.exhaust_card(card_data)
	remote_opponent_discard_card(player_data, card_data)

func _on_remote_opponent_move_card(opponent : CharacterData, card : CardData, transform : TransformData, tween_time : float):
	var opponent_hand_manager : CardManager = _opponent_hand_managers[opponent]
	opponent_hand_manager.move_card(card, transform, tween_time)

remote func _remote_opponent_move_card(opponent_nickname : String, card_key : String, position_x : float, position_y : float, rotation : float, scale_x : float, scale_y : float, tween_time : float):
	for opponent in _opponent_hand_managers:
		if opponent is CharacterData and opponent.nickname == opponent_nickname:
			var move_card : CardData = _remote_opponent_card_map[opponent_nickname][card_key]
			var new_transform : TransformData = TransformData.new()
			move_card.title = card_key
			new_transform.position = Vector2(position_x, position_y)
			new_transform.rotation = rotation
			new_transform.scale = Vector2(scale_x, scale_y)
			_on_remote_opponent_move_card(opponent, move_card, new_transform, tween_time)
			break

func add_opponent(opponent:CharacterData):
	var interface : OpponentActionsInterface = .add_opponent(opponent)
	_opponent_interfaces[opponent] = interface
	_new_hand_manager(opponent, interface)
	return interface

func _on_HandManager_card_updated(card_data:CardData, transform:TransformData):
	card_manager.move_card(card_data, transform, 0.1)
	rpc('_remote_opponent_move_card', player_data.nickname, str(card_data.get_instance_id()), transform.position.x, transform.position.y, transform.rotation, transform.scale.x, transform.scale.y, 0.1)
