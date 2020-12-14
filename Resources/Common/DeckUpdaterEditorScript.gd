tool
extends EditorScript


var deck_library = preload("res://Resources/Common/DeckLibrary.tres")

static func list_contents(path:String):
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

func append_decks(source_path:String):
	var directory_contents : Array = list_contents(source_path)
	for content in directory_contents:
		if not content.ends_with(".tres") :
			continue
		var full_path : String = source_path + content
		var deck_data : DeckData = load(full_path)
		if not is_instance_valid(deck_data):
			continue
		deck_library.data[deck_data.title] = deck_data

func _run():
	deck_library.data.clear()
	append_decks("res://Resources/Decks/")
