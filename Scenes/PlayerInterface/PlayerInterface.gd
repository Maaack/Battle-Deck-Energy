extends Control


signal ending_turn
signal animation_queue_empty

enum AnimationType{NONE, DRAWING, SHIFTING, DISCARDING, EXHAUSTING}

onready var card_manager : Node2D = $HandContainer/Control/CardManager
onready var animation_queue : Node = $AnimationQueue
onready var hand_manager : Node2D = $HandContainer/Control/HandManager
onready var player_board : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard
onready var draw_pile : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard/DrawPile
onready var discard_pile : Control = $BattleBoard/MarginContainer/VBoxContainer/PlayerBoard/DiscardPile

var discarding_cards_count : int = 0

func set_draw_pile_count(count:int):
		player_board.set_draw_pile_size(count)

func draw_card(card_data:CardData):
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

func discard_cards(cards:Array):
	var cards_shuffled : Array = cards.duplicate()
	cards_shuffled.shuffle()
	for card in cards_shuffled:
		discard_card(card)

func _ready():
	animation_queue.delay_timer()

func update_player_board():
	pass

func update_opponents_board():
	pass

func _on_HandManager_card_updated(card_data:CardData, prs:PRSData):
	card_manager.move_card(card_data, prs, 0.1, AnimationType.SHIFTING)

func _on_AnimationQueue_animation_started(animation_data):
	if animation_data is AnimationData:
		var card_data : CardData = animation_data.card_data
		match(animation_data.animation_type):
			AnimationType.DRAWING:
				player_board.draw_card()
				card_manager.add_card(card_data)
				card_manager.move_card(card_data, animation_data.prs, animation_data.tween_time, AnimationType.DRAWING)
				hand_manager.add_card(card_data)
			AnimationType.DISCARDING:
				var card_instance : Card2 = card_manager.get_card_instance(card_data)
				discarding_cards_count += 1
				card_instance.connect("tween_completed", self, "_on_discard_card_complete", [card_data])
				card_manager.move_card(card_data, animation_data.prs, animation_data.tween_time)
			_:
				card_manager.move_card(card_data, animation_data.prs, animation_data.tween_time)

func _on_PlayerBoard_ending_turn():
	emit_signal("ending_turn")
	discard_cards(hand_manager.cards.keys())

func _on_AnimationQueue_queue_empty():
	emit_signal("animation_queue_empty")

func _on_discard_card_complete(card_data:CardData):
	hand_manager.queue_card(card_data)
	card_manager.remove_card(card_data)
	player_board.discard_card()
	discarding_cards_count -= 1
	if discarding_cards_count != 0:
		return
	hand_manager.discard_queue()
