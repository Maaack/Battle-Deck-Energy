tool
extends EditorScript


var definition_library = preload("res://Resources/Common/DefinitionLibrary.tres")

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

func append_definitions(source_path:String):
	var directory_contents : Array = list_contents(source_path)
	for content in directory_contents:
		if not content.ends_with(".tres") :
			continue
		var full_path : String = source_path + content
		var definition_data : DefinitionData = load(full_path)
		if not is_instance_valid(definition_data):
			continue
		definition_library.data[definition_data.key] = definition_data

func _run():
	definition_library.data.clear()
	append_definitions("res://Resources/Definitions/")
