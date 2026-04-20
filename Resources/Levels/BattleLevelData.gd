extends LevelData


class_name BattleLevelData

@export var opponents : Array = [] # (Array, Resource)
@export var lootable_cards: Resource : set = set_lootable_cards

func set_lootable_cards(value:WeightedDataList):
	lootable_cards = value
