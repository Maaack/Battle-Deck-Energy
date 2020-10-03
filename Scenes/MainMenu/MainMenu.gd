extends Control


onready var window_container = $WindowContainer

var credits_scene = preload("res://Scenes/Credits/Credits.tscn")

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://Scenes/CampaignInterface/CampaignInterface.tscn")

func _on_CreditsButton_pressed():
	var credits_instance = credits_scene.instance()
	window_container.add_child(credits_instance)

func _on_ExitGameButton_pressed():
	get_tree().quit()
