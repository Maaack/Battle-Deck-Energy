extends BattleInterface


func _on_turn_started(character : CharacterData):
	if character == player_character:
		player_interface.start_turn()
	else:
		var character_battle_manager : CharacterBattleManager = battle_manager.get_character_manager(character)
		if character_battle_manager is EnemyAIBattleManager:
			var opportunities : Array = battle_manager.get_opportunities()
			character_battle_manager.take_turn(opportunities)

func _on_CampaignBattleManager_card_revealed(character : CharacterData, card : CardData, opportunity: OpportunityData):
	player_interface.reveal_card(character, card, opportunity)

func _ready():
	super._ready()
	EventBus.turn_started.connect(_on_turn_started)
	battle_manager = $CampaignBattleManager
	player_interface = $PlayerInterface
