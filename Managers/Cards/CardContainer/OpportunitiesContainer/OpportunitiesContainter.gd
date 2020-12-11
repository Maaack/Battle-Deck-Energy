extends CardContainer


class_name OpportunitiesContainer

signal update_opportunity(opportunity, container)

const ATTACK_TYPE = 'ATTACK'
const DEFEND_TYPE = 'DEFEND'
const SKILL_TYPE = 'SKILL'

onready var label_node = $CenterContainer/Control/Slot1/MarginContainer/Label
onready var glow_nodes = $CenterContainer/Control/LayeredGlowNodes
onready var slot_3_node = $CenterContainer/Control/Slot1/Slot3
onready var slot_2_node = $CenterContainer/Control/Slot1/Slot2
onready var slot_1_node = $CenterContainer/Control/Slot1

var type_map : Dictionary = {}
var opportunities_map : Dictionary = {}

func _update_label():
	var final_label : String = ""
	var separator : String = ""
	for type in type_map:
		var count : int = type_map[type]
		var label : String
		if count == 0:
			continue
		match(type):
			(CardData.CardType.ATTACK):
				label = ATTACK_TYPE
			(CardData.CardType.DEFEND):
				label = DEFEND_TYPE
			(CardData.CardType.SKILL):
				label = SKILL_TYPE
		final_label += "%s%d %s" % [separator, count, label]
		separator = "\n-\n"
	label_node.text = final_label

func _update_slots():
	var full_count : int = 0
	slot_1_node.hide()
	slot_2_node.hide()
	slot_3_node.hide()
	for type in type_map:
		full_count += type_map[type]
	if full_count >= 1:
		slot_1_node.show()
	if full_count >= 2:
		slot_2_node.show()
	if full_count >= 3:
		slot_3_node.show()

func add_opportunity(opportunity:OpportunityData):
	if not opportunity in opportunities_map:
		opportunities_map[opportunity] = true
	var type : int = opportunity.type
	if not type in type_map:
		type_map[type] = 0
	type_map[type] += 1
	opportunity.transform_data.scale = get_transform().get_scale()
	emit_signal("update_opportunity", opportunity, self)
	_update_label()
	_update_slots()

func remove_opportunity(opportunity:OpportunityData):
	if not opportunity in opportunities_map:
		return
	var type : int = opportunity.type
	if type in type_map:
		type_map[type] -= 1
	opportunities_map.erase(opportunity)
	_update_label()
	_update_slots()

func glow_on():
	glow_nodes.glow_on()

func glow_off():
	glow_nodes.glow_off()

func glow_special():
	glow_nodes.glow_special()
