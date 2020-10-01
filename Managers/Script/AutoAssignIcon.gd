extends Object


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

func update_card_icons(source_path:String):
	var card_directories : Array = list_contents(source_path)
	for card_directory in card_directories:
		if card_directory is String:
			if card_directory.ends_with("/") :
				var directory_contents : Array = list_contents(source_path + card_directory)
				for content in directory_contents:
					var full_path : String = source_path + card_directory + content
					var card_data : CardData = load(full_path)
					if not is_instance_valid(card_data):
						continue
					var battle_effect : EffectData =  card_data.effects[0]
					if not is_instance_valid(card_data.icon):
						card_data.icon = battle_effect.icon
					if card_data.base_color == Color():
						card_data.base_color = battle_effect.base_color
					ResourceSaver.save(full_path, card_data)



func run_main(source_path:String, destination_path:String):
	update_card_icons(source_path)
