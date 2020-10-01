extends LevelData


class_name BattleLevelData

export(Array, Resource) var opponents : Array = []
export(Resource) var lootable_cards : Resource = preload("res://Resources/Weighted/LevelLootList/Rank1/Rank1LootList.tres") setget set_lootable_cards

func set_lootable_cards(value:WeightedDataList):
	lootable_cards = value
