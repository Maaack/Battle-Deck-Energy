extends Control

@onready var level_manager = $LevelManager
@onready var loot_manager = $LootManager

@export var primary_class : BattleLevelData.LootType
@export var secondary_class : BattleLevelData.LootType
@export var starting_deck : DeckData

var campaign_seed : int
var current_level
var type_cards_map : Dictionary[String, Array]
var deck_saved : bool = false
var decks : Array[DeckData]
var type_decks_map : Dictionary[String, Array]
var runs : int = 0

func _start_run():
	runs += 1
	campaign_seed = randi()
	type_cards_map.clear()
	decks.clear()
	level_manager.current_level = 0
	deck_saved = false
	while (not deck_saved):
		start_level()
		level_manager.advance()

func _print_decks_aggregate(print_decks:Array) -> void:
	var cost_count_map : Dictionary[int, int] = {0:0, 1:0, 2:0, 3:0}
	var type_count_map : Dictionary[CardData.CardType, int]
	var total_cards : int = 0
	for print_deck in print_decks:
		for card in print_deck.cards:
			if card.energy_cost not in cost_count_map:
				cost_count_map[card.energy_cost] = 0
			cost_count_map[card.energy_cost] += 1
			if card.type not in type_count_map:
				type_count_map[card.type] = 0
			type_count_map[card.type] += 1
			total_cards += 1
	print("size, %d" % (total_cards / print_decks.size()))
	for cost in cost_count_map:
		var average : float = float(cost_count_map[cost]) / print_decks.size()
		print("%d cost card/deck,%2.3f" % [cost, average])
	for type in type_count_map:
		var card_type_string := CardData.get_card_type_string(type)
		var average : float = float(type_count_map[type]) / print_decks.size()
		print("%s card/deck,%2.3f" % [card_type_string, average])

func print_aggregates():
	for type in type_decks_map:
		print(type)
		_print_decks_aggregate(type_decks_map[type])

func _process(delta):
	_start_run()
	if runs % 100 == 0:
		print("runs,%d" % runs)
		print_aggregates()

func save_deck(deck_type:String, save_deck:Array[CardData]) -> void:
	var deck_data := DeckData.new()
	deck_data.cards = save_deck.duplicate()
	deck_data.title = "%s %d" % [deck_type, campaign_seed]
	decks.append(deck_data)
	if deck_type not in type_decks_map:
		type_decks_map[deck_type] = []
	type_decks_map[deck_type].append(deck_data)

func save_decks():
	# print(deck)
	for type in type_cards_map:
		save_deck(type, type_cards_map[type])
	deck_saved = true

func get_lootable_cards(battle_level:BattleLevelData) -> WeightedDataList:
	loot_manager.battle_level = battle_level
	return loot_manager.get_lootable_cards()

func _append_type_to_cards_map(deck_type:String, card:CardData) -> void:
	if deck_type not in type_cards_map:
		type_cards_map[deck_type] = starting_deck.cards.duplicate()
	type_cards_map[deck_type].append(card)

func collect_loot(battle_level:BattleLevelData):
	var lootable_cards := get_lootable_cards(battle_level)
	var random_cards = lootable_cards.slice_random(3)
	var highest_energy_cost_card : CardData = random_cards[0]
	var lowest_energy_cost_card : CardData = random_cards[0]
	var attack_card : CardData = random_cards[0]
	var defend_card : CardData = random_cards[0]
	var skill_card : CardData = random_cards[0]
	for card in random_cards:
		if card is CardData:
			if card.energy_cost > highest_energy_cost_card.energy_cost:
				highest_energy_cost_card = card
			if card.energy_cost < lowest_energy_cost_card.energy_cost:
				lowest_energy_cost_card = card
			match(card.type):
				CardData.CardType.ATTACK:
					attack_card = card
				CardData.CardType.DEFEND:
					defend_card = card
				CardData.CardType.SKILL:
					skill_card = card
	_append_type_to_cards_map("High", highest_energy_cost_card)
	_append_type_to_cards_map("Low", lowest_energy_cost_card)
	_append_type_to_cards_map("Attack", attack_card)
	_append_type_to_cards_map("Defend", defend_card)
	_append_type_to_cards_map("Skill", skill_card)

func clean_deck(clean_deck:Array[CardData]) -> void:
	var remove_priority : Dictionary[String, int]
	var _remove_cards : Array[String] = ["Slash", "Shield"]
	var highest_priority_title : String
	var highest_priority_value : int = -1
	for card in clean_deck:
		if card.title not in remove_priority:
			remove_priority[card.title] = 0
		if card.title == "Diffident":
			remove_priority[card.title] += 10
		elif card.title in _remove_cards:
			remove_priority[card.title] += 1
		if remove_priority[card.title] > highest_priority_value:
			highest_priority_value = remove_priority[card.title]
			highest_priority_title = card.title
	for card in clean_deck:
		if card.title == highest_priority_title:
			clean_deck.erase(card)
			break

func start_shelter():
	for deck_type in type_cards_map:
		clean_deck(type_cards_map[deck_type])

func start_fork(left_level:BattleLevelData, right_level:BattleLevelData):
	if left_level.loot_type == primary_class:
		collect_loot(left_level)
	elif right_level.loot_type == primary_class:
		collect_loot(right_level)
	elif left_level.loot_type == secondary_class:
		collect_loot(left_level)
	elif right_level.loot_type == secondary_class:
		collect_loot(right_level)
	else:
		collect_loot(left_level)

func start_level():
	seed(campaign_seed + level_manager.current_level)
	var _current_level = level_manager.get_current_level()
	if _current_level is WeightedDataList:
		_current_level = _current_level.duplicate(true)
		var level_left : BattleLevelData = _current_level.slice_random_data()
		var level_right : BattleLevelData = _current_level.slice_random_data()
		if level_left != null and level_right != null:
			start_fork(level_left, level_right)
			return
		_current_level = level_left
	if _current_level is not LevelData: return
	current_level = _current_level
	if current_level is BattleLevelData:
		collect_loot(current_level)
	elif current_level is ShelterLevelData:
		start_shelter()
	elif current_level is SaveDeckLevelData:
		save_decks()
