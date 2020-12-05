extends Node

const DECK_TITLE_KEY = 'deckTitle'
const DECK_CARDS_KEY = 'deckCards'
const DECK_ICON_KEY = 'deckIcon'
const SAVE_DECK_FILENAME_PREFIX = 'SaveDeck'

onready var card_library : CommonData = preload("res://Resources/Common/CardLibrary.tres")
var version = 'v0.1.1'
var persist_path = 'user://'

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
	return "%s%s/" % [persist_path, version]

func make_local_directory():
	var dir = Directory.new()
	var local_path : String = get_local_path()
	if not dir.dir_exists(local_path):
		dir.make_dir_recursive(local_path)

func save_deck(deck : Array, name : String, icon : Texture):
	make_local_directory()
	var file_handler = File.new()
	var date : Dictionary = OS.get_datetime()
	var date_string : String = "%4d-%02d-%02d_%02d:%02d:%02d" % [date['year'], date['month'], date['day'], date['hour'], date['minute'], date['second']]
	var directory_path : String = get_local_path()
	var file_path : String = "%s%s%s.json" % [directory_path, SAVE_DECK_FILENAME_PREFIX, date_string]
	file_handler.open(file_path, File.WRITE)
	var saved_dict : Dictionary = {}
	saved_dict[DECK_TITLE_KEY] = name
	if icon != null:
		saved_dict[DECK_ICON_KEY] = icon.resource_path
	var cards_array : Array = []
	for card in deck:
		if card is CardData:
			cards_array.append(card.title)
	saved_dict[DECK_CARDS_KEY] = cards_array
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
	var saved_deck : DeckData = DeckData.new()
	saved_deck.title = saved_dict[DECK_TITLE_KEY]
	var saved_cards : Array = saved_dict[DECK_CARDS_KEY]
	for saved_card_name in saved_cards:
		if not saved_card_name in card_library.data:
			print("Warning: Card `%s` not recognized." % saved_card_name)
			continue
		var card : CardData = card_library.data[saved_card_name]
		if card != null:
			saved_deck.cards.append(card)
	if DECK_ICON_KEY in saved_dict:
		saved_deck.icon = load(saved_dict[DECK_ICON_KEY])
	return saved_deck
