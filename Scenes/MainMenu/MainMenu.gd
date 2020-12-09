extends Control


onready var window_container = $WindowContainer
onready var animation_player = $BackgroundControl/TextureRect2/AnimationPlayer
onready var init_options = $MarginContainer/MainControl/InitOptionsContainer
onready var play_options = $MarginContainer/MainControl/PlayOptionsContainer
onready var continue_campaign_button = $MarginContainer/MainControl/PlayOptionsContainer/ContinueCampaignButton

var credits_scene = preload("res://Scenes/Credits/Credits.tscn")

func _ready():
	animation_player.play("SlideInLeft")
	if PersistentData.has_progress():
		continue_campaign_button.show()

func _on_CampaignGameButton_pressed():
	get_tree().change_scene("res://Scenes/CampaignInterface/CampaignInterface.tscn")

func _on_CreditsButton_pressed():
	var credits_instance = credits_scene.instance()
	window_container.add_child(credits_instance)

func _on_ExitGameButton_pressed():
	get_tree().quit()

func _on_PlayButton_pressed():
	init_options.hide()
	play_options.show()

func _on_BackButton_pressed():
	play_options.hide()
	init_options.show()

func _on_OnlineArenaButton_pressed():
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")

func _on_ContinueCampaignButton_pressed():
	get_tree().change_scene("res://Scenes/CampaignInterface/CampaignInterface.tscn")

func _on_NewCampaignButton_pressed():
	PersistentData._delete_progress_files()
	get_tree().change_scene("res://Scenes/CampaignInterface/CampaignInterface.tscn")

