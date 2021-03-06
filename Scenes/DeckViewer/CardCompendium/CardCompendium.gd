extends DeckViewer


export(String) var player_card_directory : String

func list_contents(path:String):
	var contents = []
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

func list_cards(source_path:String):
	var card_directories : Array = list_contents(source_path)
	for card_directory in card_directories:
		if card_directory is String:
			if card_directory.ends_with("/") :
				var directory_contents : Array = list_contents(source_path + card_directory)
				for content in directory_contents:
					if content.ends_with("/") :
						continue
					var full_path : String = source_path + card_directory + content
					var card_data : CardData = load(full_path)
					if not is_instance_valid(card_data):
						continue
					deck.append(card_data)
	_add_cards_from_deck()

func _ready():
	list_cards(player_card_directory)
	
