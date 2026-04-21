extends LevelData

class_name BattleLevelData

enum LootType{
	UNKNOWN,
	GRAPPLE,
	ROGUE,
	TOXIC
}
const CARD_RANK_COST_MAP : Dictionary[int, Array] = {
	1: [0],
	2: [0, 1],
	3: [0, 1, 2],
	4: [0, 1, 2],
	5: [1, 2, 3],
	6: [2, 3]
}
const RANK_SKILL_DECREASED : Array = [1, 2, 3, 5]

@export var opponents : Array[CharacterData] = [] # (Array, Resource)
@export var loot_type : LootType
@export_range(1, 7) var rank : int = 1

var lootable_cards : WeightedDataList : get = get_lootable_cards

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
	var grapple_cards := load("res://Resources/Decks/GrappleDeck.tres")
	var rogue_cards := load("res://Resources/Decks/RogueDeck.tres")
	var toxic_cards := load("res://Resources/Decks/ToxicDeck.tres")
	var loot_card_list : WeightedDataList = WeightedDataList.new()
	for cost in CARD_RANK_COST_MAP[rank]:
		match(loot_type):
			LootType.UNKNOWN:
				append_all_card_types(loot_card_list, all_cards, cost)
			LootType.GRAPPLE:
				append_all_card_types(loot_card_list, grapple_cards, cost)
			LootType.ROGUE:
				append_all_card_types(loot_card_list, rogue_cards, cost)
			LootType.TOXIC:
				append_all_card_types(loot_card_list, toxic_cards, cost)
	return loot_card_list
