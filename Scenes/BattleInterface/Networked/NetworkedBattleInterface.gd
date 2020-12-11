extends BattleInterface


func _ready():
	battle_manager = $NetworkedBattleManager
	player_interface = $NetworkedPlayerInterface

func _advance_character_phase():
	battle_manager.rpc('advance_character_phase')

func _on_BattleManager_turn_started(character : CharacterData):
	if character == player_character:
		player_interface.start_turn()
		player_interface.start_timer(40)

func _on_BattleManager_card_discarded(character : CharacterData, card : CardData):
	if character == player_character:
		player_interface.discard_card(card)
	
func _on_BattleManager_card_exhausted(character : CharacterData, card : CardData):
	if character == player_character:
		player_interface.exhaust_card(card)

func _on_BattleManager_card_spawned(character, card):
	player_interface.new_character_card(character, card)
	player_interface.animate_playing_card(card)
	if character != player_character:
		player_interface.discard_card(card)
