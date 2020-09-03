extends Node


signal modify_character(character, modifier, value)

const ATTACK = 'ATTACK'
const DEFEND = 'DEFEND'
const STRENGTH = 'STRENGTH'
const WEAKNESS = 'WEAKNESS'
const FORTITUDE = 'FORTITUDE'
const FRAILTY = 'FRAILTY'

var character_modifier_map : Dictionary = {}

func reset():
	character_modifier_map.clear()

func _map_status_to_modifier_tag(status:StatusData):
	match(status.type_tag):
		STRENGTH, WEAKNESS:
			return ATTACK
		FORTITUDE, FRAILTY:
			return DEFEND
	return ''

func _map_status_to_modifier_intensity(status:StatusData):
	match(status.type_tag):
		STRENGTH, FORTITUDE:
			return status.intensity
		WEAKNESS, FRAILTY:
			return -(status.intensity)
	return 0

func resolve_status(character:CharacterData, status:StatusData):
	if not character in character_modifier_map:
		character_modifier_map[character] = {}
	var modifier : String = _map_status_to_modifier_tag(status)
	var intensity : int = _map_status_to_modifier_intensity(status)
	if modifier != '' and intensity != 0:
		if not modifier in character_modifier_map[character]:
			character_modifier_map[character][modifier] = 0
		character_modifier_map[character][modifier] += intensity
		emit_signal("modify_character", character, modifier, character_modifier_map[character][modifier])

func get_character_modifiers(character:CharacterData):
	if character in character_modifier_map:
		return character_modifier_map[character]
	return {}

func get_character_modifier(character:CharacterData, modifier:String):
	var character_modifiers : Dictionary = get_character_modifiers(character)
	if modifier in character_modifiers:
		return character_modifiers[modifier]
	return 0
