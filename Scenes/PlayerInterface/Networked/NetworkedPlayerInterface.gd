extends PlayerInterface

onready var battle_board = $BattleBoard

var _opponent_hand_manager_scene = preload("res://Managers/Cards/Puppet/PuppetCardManager.tscn")
var _opponent_hand_managers : Dictionary = {}

func _new_hand_manager(opponent : CharacterData, interface : OpponentActionsInterface):
	var opponent_hand_manager = _opponent_hand_manager_scene.instance()
	battle_board.add_child(opponent_hand_manager)
	opponent_hand_manager.position = interface.get_hand_position() - battle_board.rect_global_position
	opponent_hand_manager.scale = interface.get_hand_scale()
	_opponent_hand_managers[opponent] = opponent_hand_manager

func add_opponent(opponent:CharacterData):
	var interface : OpponentActionsInterface = .add_opponent(opponent)
	_new_hand_manager(opponent, interface)
	return interface

func _on_HandManager_card_updated(card_data:CardData, transform:TransformData):
	card_manager.move_card(card_data, transform, 0.1)
