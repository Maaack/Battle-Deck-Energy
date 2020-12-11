tool
extends EditorScript

func add_weight_to_list(target_list: Array, source_list: WeightedDataList, weight : float = 1.0):
	for weighted_card in source_list.list:
		if weighted_card is WeightedData:
			var new_weighted_card : WeightedData = weighted_card.duplicate()
			new_weighted_card.weight = weight
			target_list.append(new_weighted_card)

func _run():
	var cards_0_1 : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Cost0Rank1CardList.tres")
	var cards_0_2 : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Cost0Rank2CardList.tres")
	var cards_0_3 : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Cost0Rank3CardList.tres")
	var cards_1_1 : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Cost1Rank1CardList.tres")
	var cards_1_2 : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Cost1Rank2CardList.tres")
	var cards_1_3 : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Cost1Rank3CardList.tres")
	var cards_2_1 : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Cost2Rank1CardList.tres")
	var cards_2_2 : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Cost2Rank2CardList.tres")
	var cards_2_3 : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Cost2Rank3CardList.tres")
	var rank_1_list : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Rank1CardList.tres")
	var rank_2_list : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Rank2CardList.tres")
	var rank_3_list : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Rank3CardList.tres")
	var rank_4_list : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Rank4CardList.tres")
	var rank_5_list : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Rank5CardList.tres")
	var rank_6_list : WeightedDataList = load("res://Resources/Weighted/WeightedCardList/Rank6CardList.tres")
	
	var new_rank_list : Array
	new_rank_list.clear()
	add_weight_to_list(new_rank_list, cards_0_1, 4)
	add_weight_to_list(new_rank_list, cards_1_1, 2)
	add_weight_to_list(new_rank_list, cards_0_2, 1)
	rank_1_list.starting_list = new_rank_list.duplicate()

	new_rank_list.clear()
	add_weight_to_list(new_rank_list, cards_0_2, 4)
	add_weight_to_list(new_rank_list, cards_1_2, 2)
	add_weight_to_list(new_rank_list, cards_1_1, 1)
	rank_2_list.starting_list = new_rank_list.duplicate()

	new_rank_list.clear()
	add_weight_to_list(new_rank_list, cards_1_2, 4)
	add_weight_to_list(new_rank_list, cards_2_1, 2)
	add_weight_to_list(new_rank_list, cards_0_3, 1)
	rank_3_list.starting_list = new_rank_list.duplicate()

	new_rank_list.clear()
	add_weight_to_list(new_rank_list, cards_2_2, 4)
	add_weight_to_list(new_rank_list, cards_0_3, 2)
	add_weight_to_list(new_rank_list, cards_2_1, 2)
	add_weight_to_list(new_rank_list, cards_1_3, 1)
	rank_4_list.starting_list = new_rank_list.duplicate()

	new_rank_list.clear()
	add_weight_to_list(new_rank_list, cards_2_2, 4)
	add_weight_to_list(new_rank_list, cards_1_3, 2)
	add_weight_to_list(new_rank_list, cards_2_1, 1)
	rank_5_list.starting_list = new_rank_list.duplicate()

	new_rank_list.clear()
	add_weight_to_list(new_rank_list, cards_2_3, 4)
	add_weight_to_list(new_rank_list, cards_2_2, 2)
	add_weight_to_list(new_rank_list, cards_1_3, 1)
	rank_6_list.starting_list = new_rank_list.duplicate()
