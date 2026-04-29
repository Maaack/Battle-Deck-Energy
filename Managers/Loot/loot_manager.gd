extends Node


const CARD_RANK_COST_MAP : Dictionary[int, Array] = {
	1: [0],
	2: [0, 1],
	3: [0, 1],
	4: [1, 2],
	5: [2, 3],
	6: [3, 4]
}
const RANK_SKILL_DECREASED : Array = [2, 4, 5, 6]

@export var battle_level : BattleLevelData :
	set(value):
		battle_level = value
		if battle_level != null:
			loot_type = battle_level.loot_type
			rank = battle_level.rank
@export var loot_type : BattleLevelData.LootType
@export_range(1, 15) var rank : int = 1

func append_cards(append_list : WeightedDataList, deck: DeckData, cost: int = 0, card_type : CardData.CardType = CardData.CardType.NONE):
	for card in deck.cards:
		if card.energy_cost != cost:
			continue
		if card_type != CardData.CardType.NONE and card.type != card_type:
			continue
		append_list.append_data(card)

func append_all_card_types(append_list : WeightedDataList, deck: DeckData, cost: int = 0):
	append_cards(append_list, deck, cost, CardData.CardType.ATTACK)
	append_cards(append_list, deck, cost, CardData.CardType.DEFEND)
	if rank in RANK_SKILL_DECREASED:
		var max_cost : int = CARD_RANK_COST_MAP[rank].max()
		if cost > max_cost - 1:
			return
	append_cards(append_list, deck, cost, CardData.CardType.SKILL)

func get_lootable_cards() -> WeightedDataList:
	var all_cards := load("res://Resources/Decks/AllCardsDeck.tres")
	var grapple_cards := load("res://Resources/Decks/GrappleCardsDeck.tres")
	var rogue_cards := load("res://Resources/Decks/RogueCardsDeck.tres")
	var toxic_cards := load("res://Resources/Decks/ToxicCardsDeck.tres")
	var loot_card_list : WeightedDataList = WeightedDataList.new()
	for cost in CARD_RANK_COST_MAP[rank]:
		match(loot_type):
			BattleLevelData.LootType.UNKNOWN:
				append_all_card_types(loot_card_list, all_cards, cost)
			BattleLevelData.LootType.GRAPPLE:
				append_all_card_types(loot_card_list, grapple_cards, cost)
			BattleLevelData.LootType.ROGUE:
				append_all_card_types(loot_card_list, rogue_cards, cost)
			BattleLevelData.LootType.TOXIC:
				append_all_card_types(loot_card_list, toxic_cards, cost)
	return loot_card_list
