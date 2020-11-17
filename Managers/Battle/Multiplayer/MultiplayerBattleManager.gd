extends BattleManager


class_name MultiplayerBattleManager

func add_player(player_id : int, character_data : CharacterData, team : String):
	var battle_manager = add_character(character_data, team)
	battle_manager.set_network_master(player_id)

remotesync func _remote_on_card_played(card_key : String, opportunity_source : String, opportunity_target : String , opportunity_type : int):
	var opportunity = opportunities_manager.get_matching_opportunity(opportunity_source, opportunity_target, opportunity_type)
	var card = card_library.data[card_key]
	effects_manager.resolve_on_play_opportunity(card, opportunity, _character_manager_map)

func on_card_played(character : CharacterData, card:CardData, opportunity:OpportunityData):
	var character_battle_manager : NewCharacterBattleManager = _character_manager_map[character]
	character_battle_manager.play_card_on_opportunity(card, opportunity)
	rpc('_remote_on_card_played', card.title, opportunity.source.nickname, opportunity.target.nickname, opportunity.type)
	opportunities_manager.remove_opportunity(opportunity)
	_discard_or_exhaust_card(character, card)

