extends Control


signal ending_turn
signal animation_queue_empty
signal drawing_completed
signal discard_completed

enum AnimationType{NONE, DRAWING, SHIFTING, DISCARDING, EXHAUSTING, RESHUFFLING, DRAGGING}

onready var card_manager : Node2D = $HandContainer/Control/CardManager
onready var animation_queue : Node = $AnimationQueue
onready var hand_manager : Node2D = $HandContainer/Control/HandManager
onready var player_board : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard
onready var actions_board : Control = $BattleBoard/MarginContainer/VBoxContainer/ActionsBoard
onready var draw_pile : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard/DrawPile
onready var discard_pile : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard/DiscardPile

var _drawing_cards_count : int = 0
var _discarding_cards_count : int = 0

func set_draw_pile_count(count:int):
		player_board.set_draw_pile_size(count)

func draw_card(card_data:CardData):
	card_data = card_data
	var draw_pile_offset : Vector2 = draw_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var hand_offset : Vector2 = hand_manager.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	card_data.prs.position = draw_pile_offset
	card_data.prs.scale = Vector2(0.1, 0.1)
	var new_prs : PRSData = PRSData.new()
	new_prs.position = hand_offset
	animation_queue.animate_move(card_data, new_prs, 0.4, 0.2, AnimationType.DRAWING)

func draw_cards(cards:Array):
	for card in cards:
		draw_card(card)

func discard_card(card_data:CardData):
	var discard_pile_offset : Vector2 = discard_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var new_prs : PRSData = PRSData.new()
	new_prs.position = discard_pile_offset
	new_prs.scale = Vector2(0.1, 0.1)
	animation_queue.animate_move(card_data, new_prs, 0.4, 0.2, AnimationType.DISCARDING)

func reshuffle_card(card_data:CardData):
	var draw_pile_offset : Vector2 = draw_pile.get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
	var new_prs : PRSData = PRSData.new()
	new_prs.position = draw_pile_offset
	new_prs.scale = Vector2(0.1, 0.1)
	animation_queue.animate_move(card_data, new_prs, 0.2, 0.1, AnimationType.RESHUFFLING)

func reset_end_turn():
	player_board.reset_end_turn()

func _ready():
	animation_queue.delay_timer()

func _on_HandManager_card_updated(card_data:CardData, prs:PRSData):
	card_manager.move_card(card_data, prs, 0.1, AnimationType.SHIFTING)

func _on_AnimationQueue_animation_started(animation_data):
	if animation_data is AnimationData:
		var card_data : CardData = animation_data.card_data
		match(animation_data.animation_type):
			AnimationType.DRAWING:
				player_board.draw_card()
				var card_instance = card_manager.add_card(card_data)
				card_instance.connect("tween_completed", self, "_on_draw_card_completed")
				card_manager.move_card(card_data, animation_data.prs, animation_data.tween_time, AnimationType.DRAWING)
				hand_manager.add_card(card_data)
				_drawing_cards_count += 1
			AnimationType.DISCARDING:
				var card_instance : Card2 = card_manager.get_card_instance(card_data)
				card_instance.connect("tween_completed", self, "_on_discard_card_completed")
				card_manager.move_card(card_data, animation_data.prs, animation_data.tween_time)
				_discarding_cards_count += 1
			AnimationType.RESHUFFLING:
				player_board.reshuffle_card()
			_:
				card_manager.move_card(card_data, animation_data.prs, animation_data.tween_time)

func _on_PlayerBoard_ending_turn():
	emit_signal("ending_turn")
	hand_manager.spread_from_mouse_flag = false

func _on_AnimationQueue_queue_empty():
	emit_signal("animation_queue_empty")

func _on_discard_card_completed(card_data:CardData):
	hand_manager.queue_card(card_data)
	card_manager.remove_card(card_data)
	player_board.discard_card()
	_discarding_cards_count -= 1
	if _discarding_cards_count == 0:
		if _discarding_cards_count < 0:
			_discarding_cards_count = 0
			return
		hand_manager.discard_queue()
		emit_signal("discard_completed")

func _on_draw_card_completed(card_data:CardData):
	var card_instance : Card2 = card_manager.get_card_instance(card_data)
	card_instance.disconnect("tween_completed", self, "_on_draw_card_completed")
	_drawing_cards_count -= 1
	if _drawing_cards_count == 0:
		if _drawing_cards_count < 0:
			_drawing_cards_count = 0
			return
		emit_signal("drawing_completed")

func start_turn():
	hand_manager.spread_from_mouse_flag = true
	player_board.advance_round_count()
	reset_end_turn()

func add_opponent_actions(opponent_data:CharacterData):
	actions_board.add_opponent_actions(opponent_data)

func _on_PlayerInterface_gui_input(event):
	if event is InputEventMouseMotion:
		if card_manager.dragged_card != null:
			var card_manager_offset : Vector2 = get_global_transform().get_origin() - card_manager.get_global_transform().get_origin()
			var prs_data = PRSData.new()
			prs_data.position = event.position + card_manager_offset
			prs_data.scale = Vector2(1.25, 1.25)
			card_manager.move_card(card_manager.dragged_card, prs_data, 0.1, AnimationType.DRAGGING)

func _on_CardManager_dragging_card(card_data):
	hand_manager.spread_from_mouse_flag = false

func _on_CardManager_dropping_card(card_data):
	hand_manager.spread_from_mouse_flag = true
	hand_manager.update_hand()
