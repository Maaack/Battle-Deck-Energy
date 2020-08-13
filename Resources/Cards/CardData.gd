extends Resource


class_name CardData

export(String) var title : String = ''
export(String, MULTILINE) var description : String = ''
export(int, 0, 9) var energy_cost : int = 1
export(Array, Resource) var battle_effects : Array = []

var prs : PRSData
