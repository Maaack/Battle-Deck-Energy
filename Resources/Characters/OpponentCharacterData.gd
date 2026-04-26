extends CharacterData


class_name OpponentCharacterData

@export_range(1, 32) var difficulty : int = 1
@export_range(0, 20) var starting_health_range : int = 0

func reset_health() -> void:
	super()
	if starting_health_range > 0:
		max_health += randi() % (starting_health_range + 1)
		health = max_health
