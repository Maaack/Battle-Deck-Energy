extends LevelData

class_name BattleLevelData

enum LootType{
	UNKNOWN,
	GRAPPLE,
	ROGUE,
	TOXIC
}

@export var opponents : Array[CharacterData] : set = set_opponents
@export_range(0, 8) var difficulty_mod := 0
var loot_type : LootType
var rank : int = 1

func _set_rank_from_difficulty(difficulty:int):
	var _rank = (difficulty + difficulty_mod) - 1
	if _rank < 1:
		_rank = 1
	if _rank > 6:
		_rank = 6
	rank = _rank
	
func set_opponents(value):
	opponents = value
	if opponents == null:
		return
	var highest_type_count := 0
	var highest_type := OpponentCharacterData.OpponentType.UNKNOWN
	var total_difficulty := 0
	var type_count_map : Dictionary[OpponentCharacterData.OpponentType, int] = {
		OpponentCharacterData.OpponentType.GRAPPLE : 0,
		OpponentCharacterData.OpponentType.ROGUE : 0,
		OpponentCharacterData.OpponentType.TOXIC : 0,
	}
	for opponent in opponents:
		if opponent is OpponentCharacterData:
			total_difficulty += opponent.difficulty
			type_count_map[opponent.type] += 1
			if highest_type != opponent.type and type_count_map[opponent.type] > highest_type_count:
				highest_type = opponent.type
	loot_type = (highest_type as BattleLevelData.LootType)
	_set_rank_from_difficulty(total_difficulty)
