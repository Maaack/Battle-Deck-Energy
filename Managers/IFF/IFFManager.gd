extends Node

signal friends_updated
signal foes_updated

var friends : Dictionary = {}
var foes : Dictionary = {}

func get_friends_list():
	return friends.values()

func get_foes_list():
	return foes.values()

func is_friend(character : CharacterData):
	return character.get_instance_id() in friends

func is_foe(character : CharacterData):
	return character.get_instance_id() in foes

func add_friend(character : CharacterData):
	if is_friend(character):
		return
	friends[character.get_instance_id()] = character
	emit_signal("friends_updated")

func add_foe(character : CharacterData):
	if is_foe(character):
		return
	foes[character.get_instance_id()] = character
	emit_signal("foes_updated")

func remove_friend(character : CharacterData):
	if not is_friend(character):
		return
	friends.erase(character.get_instance_id())
	emit_signal("friends_updated")

func remove_foe(character : CharacterData):
	if not is_foe(character):
		return
	foes.erase(character.get_instance_id())
	emit_signal("foes_updated")

