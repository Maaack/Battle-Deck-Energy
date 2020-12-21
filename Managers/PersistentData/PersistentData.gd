extends Node

const VERSION = 'v0.2.0'
const PERSIST_PATH = 'user://'
const BATTLE_TITLE_KEY = 'title'
const BATTLE_DATA_KEY = 'data'
const BATTLE_LOG_KEY = 'log'
const BATTLE_LOG_DATE_KEY = 'logDate'
const BATTLE_LOG_TEXT_KEY = 'logText'
const DECK_TITLE_KEY = 'deckTitle'
const DECK_CARDS_KEY = 'deckCards'
const DECK_ICON_KEY = 'deckIcon'
const CAMPAIGN_LEVEL_KEY = 'campaignLevel'
const CAMPAIGN_HEALTH_KEY = 'campaignHealth'
const CAMPAIGN_SEED_KEY = 'campaignSeed'
const SAVE_DECK_FILENAME_PREFIX = 'Deck'
const SAVE_PROGRESS_FILENAME_PREFIX = 'Progress'
const SAVE_BATTLE_FILENAME_PREFIX = 'BattleLog'

onready var card_library : CommonData = preload("res://Resources/Common/CardLibrary.tres")

var progress_data : Dictionary = {}
var battle_data : Dictionary = {}
var battle_file : File

static func list_contents(path:String):
	var contents : Array = []
	var directory = Directory.new()
	var err = directory.open(path)
	if err:
		print("Error code %d opening directory: %s" % [err, path])
		return
	directory.list_dir_begin()
		
	while true:
		var filename = directory.get_next()
		if filename == "":
			break
		if filename.begins_with("."):
			continue
		if directory.current_is_dir():
			contents.append(filename + "/")
		else:
			contents.append(filename)
	directory.list_dir_end()
	return contents

func get_local_path():
	return "%s%s/" % [PERSIST_PATH, VERSION]

func make_local_directory():
	var dir = Directory.new()
	var local_path : String = get_local_path()
	if not dir.dir_exists(local_path):
		var err = dir.make_dir(local_path)
		if err:
			print("Error code %d making directory: %s" % [err, local_path])
			err = OS.execute("CMD.exe", ["/C", "mkdir %s" % local_path])
			if err:
				print("Error code %d OS executing mkdir: %s" % [err, local_path])

func _load_deck_from_data(saved_dict : Dictionary):
	var loaded_deck : DeckData = DeckData.new()
	loaded_deck.title = saved_dict[DECK_TITLE_KEY]
	var deck_array : Array = saved_dict[DECK_CARDS_KEY]
	if DECK_ICON_KEY in saved_dict and saved_dict[DECK_ICON_KEY]:
		loaded_deck.icon = load(saved_dict[DECK_ICON_KEY])
	for card_name in deck_array:
		if not card_name in card_library.data:
			print("Warning: Card `%s` not recognized." % card_name)
			continue
		var card : CardData = card_library.data[card_name]
		if card != null:
			loaded_deck.cards.append(card)
	return loaded_deck

func _save_deck_to_data(deck : Array, name : String, icon : Texture):
	var saved_dict : Dictionary = {}
	saved_dict[DECK_TITLE_KEY] = name
	if icon != null:
		saved_dict[DECK_ICON_KEY] = icon.resource_path
	var cards_array : Array = []
	for card in deck:
		if card is CardData:
			cards_array.append(card.title)
	saved_dict[DECK_CARDS_KEY] = cards_array
	return saved_dict

func _load_level_from_data(saved_dict : Dictionary):
	return saved_dict[CAMPAIGN_LEVEL_KEY]

func _load_health_from_data(saved_dict : Dictionary):
	return saved_dict[CAMPAIGN_HEALTH_KEY]

func _load_seed_from_data(saved_dict : Dictionary):
	return saved_dict[CAMPAIGN_SEED_KEY]

func _get_progress_file_path():
	var regex = RegEx.new()
	var directory_path : String = get_local_path()
	var contents : Array = list_contents(directory_path)
	var match_string : String = SAVE_PROGRESS_FILENAME_PREFIX + \
	"\\d{4}-\\d{2}-\\d{2}_\\d{2}-\\d{2}-\\d{2}\\.json"
	regex.compile(match_string)
	for content in contents:
		var regex_match = regex.search(content)
		if regex_match:
			return (directory_path + content)
	return ''

func has_progress():
	return bool(_get_progress_file_path())

func _delete_progress_files():
	var dir = Directory.new()
	var existing_file_path = _get_progress_file_path()
	while(existing_file_path):
		dir.remove(existing_file_path)
		existing_file_path = _get_progress_file_path()

func reset_progress():
	_delete_progress_files()
	load_progress()

func _new_battle_dictionary():
	return {
		BATTLE_TITLE_KEY : '',
		BATTLE_DATA_KEY : [],
		BATTLE_LOG_KEY : [],
	}

func _new_progress_dictionary():
	return {
		DECK_CARDS_KEY : [],
		DECK_ICON_KEY : null,
		DECK_TITLE_KEY : '',
		CAMPAIGN_HEALTH_KEY : 0,
		CAMPAIGN_LEVEL_KEY : 0,
		CAMPAIGN_SEED_KEY : 0,
	}

func _get_datetime_string():
	var date : Dictionary = OS.get_datetime()
	return "%4d-%02d-%02d_%02d-%02d-%02d" % [date['year'], date['month'], date['day'], date['hour'], date['minute'], date['second']]

func _new_file(filename_prefix : String):
	make_local_directory()
	var file_handler = File.new()
	var directory_path : String = get_local_path()
	var date_string : String = _get_datetime_string()
	var file_path : String = "%s%s%s.json" % [directory_path, filename_prefix, date_string]
	var err = file_handler.open(file_path, File.WRITE)
	if err:
		print("Error code %d opening file for writing: %s" % [err, file_path])
	return file_handler

func _new_progress_file():
	return _new_file(SAVE_PROGRESS_FILENAME_PREFIX)

func _new_battle_file():
	return _new_file(SAVE_BATTLE_FILENAME_PREFIX)

func _new_deck_file():
	return _new_file(SAVE_DECK_FILENAME_PREFIX)

func _open_progress_file():
	var file_handler = File.new()
	var existing_file_path = _get_progress_file_path()
	if existing_file_path:
		file_handler.open(existing_file_path, File.READ)
	return file_handler

func save_progress(campaign_seed : int, character : CharacterData, level : int):
	var new_progress_data : Dictionary = _save_deck_to_data(character.deck, '', null)
	new_progress_data[CAMPAIGN_HEALTH_KEY] = character.health
	new_progress_data[CAMPAIGN_LEVEL_KEY] = level
	new_progress_data[CAMPAIGN_SEED_KEY] = campaign_seed
	progress_data = new_progress_data
	_delete_progress_files()
	var file_handler : File = _new_progress_file()
	file_handler.store_line(to_json(progress_data))
	file_handler.close()

func _load_or_start_progress():
	var file_handler : File = _open_progress_file()
	var saved_dict : Dictionary
	if file_handler.is_open():
		var contents : String = file_handler.get_line()
		if contents != '':
			saved_dict = parse_json(contents)
		else:
			saved_dict = _new_progress_dictionary()
		file_handler.close()
	else:
		saved_dict = _new_progress_dictionary()
	return saved_dict

func load_progress():
	progress_data = _load_or_start_progress()

func get_last_level():
	if progress_data.empty():
		load_progress()
	return _load_level_from_data(progress_data)

func get_last_health():
	if progress_data.empty():
		load_progress()
	return _load_health_from_data(progress_data)

func get_last_seed():
	if progress_data.empty():
		load_progress()
	return _load_seed_from_data(progress_data)

func get_last_deck():
	if progress_data.empty():
		load_progress()
	return _load_deck_from_data(progress_data)

func start_battle(title : String, extra_data : Array = []):
	finish_battle()
	battle_file = _new_battle_file()
	battle_data = _new_battle_dictionary()
	battle_data[BATTLE_TITLE_KEY] = title
	battle_data[BATTLE_DATA_KEY] = extra_data

func log_battle_action(log_text : String):
	if not BATTLE_LOG_KEY in battle_data:
		print('Warning: Attempting to log battle action `%s` without `log` key in dict' % log_text)
		return
	var battle_log_dict = {
		BATTLE_LOG_DATE_KEY : _get_datetime_string(),
		BATTLE_LOG_TEXT_KEY : log_text
	}
	battle_data[BATTLE_LOG_KEY].append(battle_log_dict)

func save_deck(deck : Array, name : String, icon : Texture):
	var file_handler = _new_deck_file()
	var saved_dict : Dictionary = _save_deck_to_data(deck, name, icon)
	file_handler.store_line(to_json(saved_dict))
	file_handler.close()

func load_decks():
	make_local_directory()
	var decks : Array = []
	var directory_path : String = get_local_path()
	var contents : Array = list_contents(directory_path)
	var regex = RegEx.new()
	var match_string : String = SAVE_DECK_FILENAME_PREFIX + \
	"\\d{4}-\\d{2}-\\d{2}_\\d{2}-\\d{2}-\\d{2}\\.json"
	regex.compile(match_string)
	for content in contents:
		var regex_match = regex.search(content)
		if regex_match:
			var deck : DeckData = load_deck_file(directory_path + content)
			if deck != null:
				decks.append(deck)
	return decks

func load_deck_file(filepath : String):
	var file_handler = File.new()
	if not file_handler.file_exists(filepath):
		return
	file_handler.open(filepath, File.READ)
	var saved_dict : Dictionary = parse_json(file_handler.get_line())
	file_handler.close()
	var saved_deck : DeckData = _load_deck_from_data(saved_dict)
	return saved_deck

func finish_battle():
	if battle_file is File and battle_file.is_open():
		log_battle_action("Battle Finished")
		battle_file.store_line(to_json(battle_data))
		battle_file.close()

func _exit_tree():
	finish_battle()
		
