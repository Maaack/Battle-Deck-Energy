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
	var level_directories : Array = list_contents(source_path)
	for level_directory in level_directories:
		if level_directory is String:
			if level_directory.ends_with("/") :
				var weighted_level_list : WeightedDataList = WeightedDataList.new()
				var source_path_full : String = source_path + level_directory
				var destination_path_full : String = destination_path + level_directory
				var directory = Directory.new( )
				var starting_list : Array = []
				directory.make_dir(destination_path_full)
				var level_contents : Array = list_contents(source_path + level_directory)
				for content in level_contents:
					var full_path : String = source_path + level_directory + content
					var level : WeightedData = save_weighted_level(full_path, content, destination_path_full)
					starting_list.append(level)
				var new_filename : String = destination_path_full + level_directory.get_base_dir() + "List.tres"
				weighted_level_list.starting_list = starting_list
				print("Trying to save %s : %s " % [weighted_level_list.starting_list, weighted_level_list.list])
				ResourceSaver.save(new_filename, weighted_level_list)

func save_weighted_level(full_path:String, filename:String, destination_path:String):
	var weighted_level : WeightedData = WeightedData.new()
	weighted_level.data = load(full_path)
	var new_filename : String = destination_path + filename.get_basename() + "LevelChance.tres"
	print("Saving file %s " % new_filename)
	ResourceSaver.save(new_filename, weighted_level)
	var saved_weighted_level = load(new_filename)
	return saved_weighted_level

func run_main(source_path:String, destination_path:String):
	get_level_directories(source_path, destination_path)
