extends Node

const VERSION = 'v0.1.1'
const PERSIST_PATH = 'user://'
const DECK_TITLE_KEY = 'deckTitle'
const DECK_CARDS_KEY = 'deckCards'
const DECK_ICON_KEY = 'deckIcon'
const CAMPAIGN_LEVEL_KEY = 'campaignLevel'
const CAMPAIGN_HEALTH_KEY = 'campaignHealth'
const CAMPAIGN_SEED_KEY = 'campaignSeed'
const SAVE_DECK_FILENAME_PREFIX = 'SaveDeck'
const SAVE_PROGRESS_FILENAME_PREFIX = 'SaveProgress'

onready var card_library : CommonData = preload("res://Resources/Common/CardLibrary.tres")

var progress_data : Dictionary

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
		dir.make_dir_recursive(local_path)

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
	"\\d{4}-\\d{2}-\\d{2}_\\d{2}:\\d{2}:\\d{2}\\.json"
	regex.compile(match_string)
	for content in contents:
		var regex_match = regex.search(content)
		if regex_match:
			print("Found progress file %s " % content)
			return (directory_path + content)

func has_progress():
	return bool(_get_progress_file_path())

func _delete_progress_files():
	var dir = Directory.new()
	var existing_file_path = _get_progress_file_path()
	while(existing_file_path):
		dir.remove(existing_file_path)
		existing_file_path = _get_progress_file_path()

func _new_progress_dictionary():
	return {
		DECK_CARDS_KEY : [],
		DECK_ICON_KEY : null,
		DECK_TITLE_KEY : '',
		CAMPAIGN_HEALTH_KEY : 0,
		CAMPAIGN_LEVEL_KEY : 0,
		CAMPAIGN_SEED_KEY : 0,
	}

func _new_progress_file():
	var file_handler = File.new()
	var directory_path : String = get_local_path()
	var date : Dictionary = OS.get_datetime()
	var date_string : String = "%4d-%02d-%02d_%02d:%02d:%02d" % [date['year'], date['month'], date['day'], date['hour'], date['minute'], date['second']]
	var file_path : String = "%s%s%s.json" % [directory_path, SAVE_PROGRESS_FILENAME_PREFIX, date_string]
	file_handler.open(file_path, File.WRITE)
	return file_handler

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
		print("contents of `%s` returned : %s " % [file_handler.get_path(), contents])
		if contents != '':
			print("parse_json: %s " % contents)
			saved_dict = parse_json(contents)
		else:
			saved_dict = _new_progress_dictionary()
		file_handler.close()
	else:
		saved_dict = _new_progress_dictionary()
	return saved_dict

func load_progress():
	progress_data = _load_or_start_progress()
	print(progress_data)

func get_last_level():
	if not progress_data:
		load_progress()
	return _load_level_from_data(progress_data)

func get_last_health():
	if not progress_data:
		load_progress()
	return _load_health_from_data(progress_data)

func get_last_seed():
	if not progress_data:
		load_progress()
	return _load_seed_from_data(progress_data)

func get_last_deck():
	if not progress_data:
		load_progress()
	return _load_deck_from_data(progress_data)

func save_deck(deck : Array, name : String, icon : Texture):
	make_local_directory()
	var file_handler = File.new()
	var date : Dictionary = OS.get_datetime()
	var date_string : String = "%4d-%02d-%02d_%02d:%02d:%02d" % [date['year'], date['month'], date['day'], date['hour'], date['minute'], date['second']]
	var directory_path : String = get_local_path()
	var file_path : String = "%s%s%s.json" % [directory_path, SAVE_DECK_FILENAME_PREFIX, date_string]
	file_handler.open(file_path, File.WRITE)
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
	"\\d{4}-\\d{2}-\\d{2}_\\d{2}:\\d{2}:\\d{2}\\.json"
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
