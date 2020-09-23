extends Resource


class_name LevelData

export(Array, String) var tags : Array = []
export(Array, Resource) var opponents : Array = []
export(Array, Resource) var lootable_cards : Array = [
	preload("res://Resources/Cards/ZeroEnergy/OpeningJab.tres"),
	preload("res://Resources/Cards/ZeroEnergy/Ricochet.tres"),
	preload("res://Resources/Cards/OneEnergy/AttackFocused.tres"),
	preload("res://Resources/Cards/OneEnergy/AttackStance.tres"),
	preload("res://Resources/Cards/OneEnergy/CripplingSlash.tres"),
	preload("res://Resources/Cards/OneEnergy/DefenseFocused.tres"),
	preload("res://Resources/Cards/OneEnergy/DefenseStance.tres"),
	preload("res://Resources/Cards/OneEnergy/DirtyNeedle.tres"),
	preload("res://Resources/Cards/OneEnergy/EnGardeGrande.tres"),
	preload("res://Resources/Cards/OneEnergy/HeavySlashCard.tres"),
	preload("res://Resources/Cards/OneEnergy/IronShield.tres"),
	preload("res://Resources/Cards/OneEnergy/NastySlash.tres"),
	preload("res://Resources/Cards/OneEnergy/OpeningStance.tres"),
	preload("res://Resources/Cards/OneEnergy/OpeningStrike.tres"),
	preload("res://Resources/Cards/OneEnergy/PoisonBlades.tres"),
	preload("res://Resources/Cards/OneEnergy/SharpenBlades.tres"),
	preload("res://Resources/Cards/OneEnergy/ShieldBashCard.tres"),
	preload("res://Resources/Cards/OneEnergy/SmoothShields.tres"),
	preload("res://Resources/Cards/TwoEnergy/Biohazard.tres"),
	preload("res://Resources/Cards/TwoEnergy/CriticalHit.tres"),
	preload("res://Resources/Cards/TwoEnergy/EnGardeMaximale.tres"),
	preload("res://Resources/Cards/TwoEnergy/SerpentsBlade.tres"),
	preload("res://Resources/Cards/TwoEnergy/StabToDeath.tres"),
	preload("res://Resources/Cards/TwoEnergy/TheWall.tres"),
	preload("res://Resources/Cards/TwoEnergy/TripleCritical.tres"),
]

func _to_string():
	return str(tags)
