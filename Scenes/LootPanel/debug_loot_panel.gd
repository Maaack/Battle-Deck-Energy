extends "res://Scenes/LootPanel/LootPanel.gd"

const MAX_GENERATIONS : int = 1000
const MAX_TICK_GENERATIONS : int = 30

var card_count_map : Dictionary[String, int]
var generations : int = 0
var tick_generations : int = 0

@export var all_levels : Array[BattleLevelData]

var current_level_iter : int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	while tick_generations < MAX_TICK_GENERATIONS:
		if current_level_iter >= all_levels.size():
			print("finished")
			set_process(false)
			return
		battle_level = all_levels[current_level_iter]
		_generate_card_options()
		for card in card_options:
			if card.title not in card_count_map:
				card_count_map[card.title] = 1
				continue
			card_count_map[card.title] += 1
		generations += 1
		if generations >= MAX_GENERATIONS:
			print(battle_level.resource_path.get_file().get_basename(), " : ", card_count_map)
			print("")
			card_count_map.clear()
			generations = 0
			current_level_iter += 1
		tick_generations += 1
	tick_generations = 0
