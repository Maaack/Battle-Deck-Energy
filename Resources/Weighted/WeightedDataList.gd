extends Resource


class_name WeightedDataList

export(Array, Resource) var starting_list : Array = [] setget set_starting_list

var list : Array = []

func reset_list():
	list = starting_list

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
	for data in list:
		if data is WeightedData:
			total_weight += data.weight
	return total_weight

func get_data_by_weight(weight_target:float):
	var total_weight : float = 0.0
	for weighted_data in list:
		if weighted_data is WeightedData:
			total_weight += weighted_data.weight
			if total_weight >= weight_target:
				return weighted_data.data

func slice_data_by_weight(weight_target:float):
	var total_weight : float = 0.0
	for weighted_data in list:
		if weighted_data is WeightedData:
			total_weight += weighted_data.weight
			if total_weight >= weight_target:
				list.erase(weighted_data)
				return weighted_data.data

func get_random_weight():
	var total_weight : float = get_total_weight()
	return rand_range(0.0, total_weight)
	
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
