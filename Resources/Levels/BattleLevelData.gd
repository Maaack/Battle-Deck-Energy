extends LevelData

class_name BattleLevelData

enum LootType{
	UNKNOWN,
	GRAPPLE,
	ROGUE,
	TOXIC
}

@export var opponents : Array[CharacterData] = [] # (Array, Resource)
@export var loot_type : LootType
@export_range(1, 15) var rank : int = 1
