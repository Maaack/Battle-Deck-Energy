extends Resource


class_name LevelData

export(Array, String) var tags : Array = []
export(Array, Resource) var opponents : Array = []
export(Array, Resource) var lootable_cards : Array = [
	preload("res://Resources/Cards/OneEnergy/HeavySlashCard.tres"),
	preload("res://Resources/Cards/OneEnergy/IronShield.tres"),
	preload("res://Resources/Cards/OneEnergy/CriticalHit.tres"),
	preload("res://Resources/Cards/OneEnergy/CripplingBlow.tres"),
	preload("res://Resources/Cards/OneEnergy/ShieldBashCard.tres"),
	preload("res://Resources/Cards/ZeroEnergy/Ricochet.tres"),
	preload("res://Resources/Cards/ZeroEnergy/OpeningStrike.tres"),
	preload("res://Resources/Cards/ZeroEnergy/ImproveStance.tres"),
]

func _to_string():
	return str(tags)
