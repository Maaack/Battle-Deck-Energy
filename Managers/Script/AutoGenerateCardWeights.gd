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

func get_level_directories(source_path:String, destination_path:String):
	var card_directories : Array = list_contents(source_path)
	for card_directory in card_directories:
		if card_directory is String:
			if card_directory.ends_with("/") :
				var weighted_data_list : WeightedDataList = WeightedDataList.new()
				var source_path_full : String = source_path + card_directory
				var destination_path_full : String = destination_path + card_directory
				var directory = Directory.new( )
				var starting_list : Array = []
				directory.make_dir(destination_path_full)
				var directory_contents : Array = list_contents(source_path + card_directory)
				for file_path in directory_contents:
					if file_path.ends_with("/") :
						continue
					var full_path : String = source_path + card_directory + file_path
					var weighted_card : WeightedData = save_weighted_data(full_path, 1, file_path, destination_path_full)
					save_weighted_data(full_path, 2, file_path, destination_path_full)
					save_weighted_data(full_path, 4, file_path, destination_path_full)
					starting_list.append(weighted_card)
				var new_filename : String = destination_path + card_directory.get_base_dir() + "CardList.tres"
				weighted_data_list.starting_list = starting_list
				print("Trying to save %s : %s " % [weighted_data_list.starting_list, weighted_data_list.list])
				ResourceSaver.save(new_filename, weighted_data_list)

func save_weighted_data(full_path:String, weight:float,  filename:String, destination_path:String):
	var weighted_data : WeightedData = WeightedData.new()
	weighted_data.data = load(full_path)
	weighted_data.weight = weight
	var new_filename : String = destination_path + filename.get_basename() + ("Weight%1.f.tres" % weight)
	print("Saving file %s " % new_filename)
	ResourceSaver.save(new_filename, weighted_data)
	var saved_weighted_level = load(new_filename)
	return saved_weighted_level

func run_main(source_path:String, destination_path:String):
	get_level_directories(source_path, destination_path)
