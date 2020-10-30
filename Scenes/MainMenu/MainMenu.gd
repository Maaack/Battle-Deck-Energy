extends Control


onready var window_container = $WindowContainer
onready var animation_player = $BackgroundControl/TextureRect2/AnimationPlayer

var credits_scene = preload("res://Scenes/Credits/Credits.tscn")

func _ready():
	animation_player.play("SlideInLeft")

func _on_CampaignGameButton_pressed():
	get_tree().change_scene("res://Scenes/CampaignInterface/CampaignInterface.tscn")

func _on_CreditsButton_pressed():
	var credits_instance = credits_scene.instance()
	window_container.add_child(credits_instance)

func _on_ExitGameButton_pressed():
	get_tree().quit()

func _on_MultiplayerButton_pressed():
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")
