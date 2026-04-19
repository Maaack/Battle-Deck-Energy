@tool
extends Resource


class_name WeightedDataList

@export var starting_list : Array = []: set = set_starting_list
@export var weighted_list : Array
@export var weighted_map : Dictionary[Resource, float]
@export_tool_button("Set other vars") var set_other_vars_action = set_other_vars

var list : Array = []

func _init():
	set_other_vars()

func set_other_vars():
	weighted_list = starting_list.duplicate()
	for thing in weighted_list:
		if thing is WeightedData:
			weighted_map[thing.data] = thing.weight

func append_data(value):
	var weighted_data : WeightedData = WeightedData.new()
	weighted_data.data = value
	weighted_data.weight = 1
	list.append(weighted_data)
	return weighted_data

func set_starting_list(value:Array):
	starting_list = value
	list = starting_list

func get_total_weight():
	var total_weight : float = 0.0
	for data in weighted_map:
		total_weight += weighted_map[data]
	return total_weight

func get_data_by_weight(weight_target:float):
	var total_weight : float = 0.0
	var last_data : Resource
	for data in weighted_map:
		total_weight += weighted_map[data]
		if total_weight >= weight_target:
			return data
		last_data = data
	return last_data

func slice_data_by_weight(weight_target:float) -> Resource:
	var data = get_data_by_weight(weight_target)
	weighted_map.erase(data)
	return data

func get_random_weight():
	var total_weight : float = get_total_weight()
	return randf_range(0.0, total_weight)
	
func get_random_data():
	var random_weight = get_random_weight()
	return get_data_by_weight(random_weight)

func slice_random_data():
	var random_weight = get_random_weight()
	return slice_data_by_weight(random_weight)
	
func slice_random(count:int):
	var data_slices : Array = []
	for _i in range(count):
		data_slices.append(slice_random_data())
	return data_slices
