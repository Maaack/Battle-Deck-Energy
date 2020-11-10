extends Control


signal player_won
signal player_lost
signal view_deck_pressed(deck)
signal card_inspected(card_node)
signal card_forgotten(card_node)
signal status_inspected(status_icon)
signal status_forgotten(status_icon)

onready var battle_end_timer = $BattleEndDelayTimer
onready var player_interface = $PlayerInterface
onready var battle_manager = $MultiplayerBattleManager

var _battle_ended : bool = false
var player_character setget set_player_character

remotesync func _advance_character_phase():
	battle_manager.advance_character_phase()

func add_player(player_id : int, character, team):
	battle_manager.add_character(character, team)

func add_character(character : CharacterData, team : String):
	battle_manager.add_character(character, team)

func set_player_character(value : CharacterData):
	player_character = value
	player_interface.player_data = value
	for character_data in battle_manager.get_all_characters():
		if character_data is CharacterData:
			if character_data == value:
				continue
			player_interface.add_opponent(character_data)

func start_battle():
	battle_manager.start_battle()

func _on_hand_drawn(character : CharacterData):
	if player_interface.is_connected("drawing_completed", self, "_on_hand_drawn"):
		player_interface.disconnect("drawing_completed", self, "_on_hand_drawn")
	player_interface.mark_character_inactive(character)
	_advance_character_phase()

func _on_hand_discarded(character :  CharacterData):
	if player_interface.is_connected("discard_completed", self, "_on_hand_discarded"):
		player_interface.disconnect("discard_completed", self, "_on_hand_discarded")
	_advance_character_phase()

func _on_BattleManager_active_character_updated(character : CharacterData):
	player_interface.connect("drawing_completed", self, "_on_hand_drawn")
	player_interface.mark_character_active(character)

func _on_MultiplayerBattleManager_turn_started(character : CharacterData):
	if character == player_character:
		player_interface.start_turn()

func _on_MultiplayerBattleManager_before_hand_discarded(character : CharacterData):
	if character == player_character:
		player_interface.connect("discard_completed", self, "_on_hand_discarded", [character])

func _on_MultiplayerBattleManager_before_hand_drawn(character : CharacterData):
	if character == player_character:
		player_interface.connect("drawing_completed", self, "_on_hand_drawn", [character])

func _on_MultiplayerBattleManager_card_drawn(character : CharacterData, card : CardData):
	if character == player_character:
		player_interface.draw_card_from_draw_pile(card)

func _on_MultiplayerBattleManager_card_added_to_hand(character : CharacterData, card : CardData):
	if character == player_character:
		player_interface.draw_card(card)

func _on_PlayerInterface_card_played_on_opportunity(card:CardData, opportunity:OpportunityData):
	battle_manager.on_card_played(player_character, card, opportunity)

func _on_PlayerInterface_ending_turn():
	_advance_character_phase()

func _on_MultiplayerBattleManager_card_discarded(character : CharacterData, card : CardData):
	if character == player_character:
		player_interface.discard_card(card)
	
func _on_MultiplayerBattleManager_card_exhausted(character : CharacterData, card : CardData):
	if character == player_character:
		player_interface.exhaust_card(card)

func _on_MultiplayerBattleManager_card_reshuffled(character : CharacterData, card : CardData):
	if character == player_character:
		player_interface.reshuffle_card(card)

func _on_MultiplayerBattleManager_card_played(character : CharacterData, card : CardData, opportunity : OpportunityData):
	if character == player_character:
		player_interface.play_card(character, card, opportunity)

func _on_MultiplayerBattleManager_opportunity_added(opportunity : OpportunityData):
	player_interface.add_opportunity(opportunity)

func _on_MultiplayerBattleManager_opportunity_removed(opportunity : OpportunityData):
	player_interface.remove_opportunity(opportunity)

func _on_MultiplayerBattleManager_status_updated(character : CharacterData, status : StatusData, delta : int):
	player_interface.update_status(character, status, delta)

func _duplicate_array_contents(values:Array):
	var new_values : Array = []
	for value in values:
		new_values.append(value.duplicate())
	return new_values

func _on_PlayerInterface_draw_pile_pressed():
	var character_manager : NewCharacterBattleManager = battle_manager.get_character_manager(player_character)
	var deck : Array = character_manager.draw_pile.cards.duplicate()
	if deck.size() == 0:
		return
	deck = _duplicate_array_contents(deck)
	deck.sort()
	emit_signal("view_deck_pressed", deck)

func _on_PlayerInterface_discard_pile_pressed():
	var character_manager : NewCharacterBattleManager = battle_manager.get_character_manager(player_character)
	var deck : Array = character_manager.discard_pile.cards.duplicate()
	if deck.size() == 0:
		return
	deck = _duplicate_array_contents(deck)
	emit_signal("view_deck_pressed", deck)

func _on_PlayerInterface_exhaust_pile_pressed():
	var character_manager : NewCharacterBattleManager = battle_manager.get_character_manager(player_character)
	var deck : Array = character_manager.exhaust_pile.cards.duplicate()
	if deck.size() == 0:
		return
	deck = _duplicate_array_contents(deck)
	emit_signal("view_deck_pressed", deck)

func _on_PlayerInterface_card_inspected(card):
	emit_signal("card_inspected", card)

func _on_PlayerInterface_card_forgotten(card):
	emit_signal("card_forgotten", card)

func _on_PlayerInterface_status_inspected(status_icon):
	emit_signal("status_inspected", status_icon)

func _on_PlayerInterface_status_forgotten(status_icon):
	emit_signal("status_forgotten", status_icon)
