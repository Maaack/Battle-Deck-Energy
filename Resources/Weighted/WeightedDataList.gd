@tool
extends Resource


class_name WeightedDataList

@export var weighted_map : Dictionary[Resource, float]
@export var drop_in_list : Array[Resource] = [] :
	set(values):
		drop_in_list = []
		if values is Array:
			for value in values:
				append_data(value)

func append_data(value:Resource):
	if value != null and value in weighted_map: return
	weighted_map[value] = 1.0
	return value

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
