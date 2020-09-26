extends Resource


class_name WeightedDataList

export(Array, Resource) var starting_list = [] setget set_starting_list

var list : Array

func set_starting_list(value:Array):
	starting_list = value
	list = starting_list

func get_total_weight():
	var total_weight : float = 0.0
	for data in list:
		if data is WeightedData:
			total_weight += data.weight
	return total_weight

func get_data_from_beginning(weight_target:float):
	var total_weight : float = 0.0
	for weighted_data in list:
		if weighted_data is WeightedData:
			total_weight += weighted_data.weight
			if total_weight >= weight_target:
				return weighted_data.data

func get_random_data():
	var total_weight : float = get_total_weight()
	var random_weight = rand_range(0.0, total_weight)
	return get_data_from_beginning(random_weight)
