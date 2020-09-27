tool
extends Node


export(GDScript) var script_to_run : GDScript
export(String) var source_path : String
export(String) var destination_path : String
export(bool) var run_toggle : bool = false setget set_run_toggle

func _run_script():
	if not script_to_run:
		print("Error: Script not set.")
		return
	var script_object = script_to_run.new()
	if not script_object.has_method("run_main"):
		print("Error: Script `%s` does not have run_main()." % [script_object])
		return
	if source_path == "":
		print("Error: Source path not set.")
		return
	if destination_path == "":
		print("Error: Source path not set.")
		return
	script_object.run_main(source_path, destination_path)

func set_run_toggle(value:bool):
	run_toggle = value
	if value:
		_run_script()
		run_toggle = false
