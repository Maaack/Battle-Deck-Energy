extends Control


onready var window_container = $WindowContainer
onready var animation_player = $BackgroundControl/TextureRect2/AnimationPlayer
onready var init_options = $MarginContainer/MainControl/InitOptionsContainer
onready var play_options = $MarginContainer/MainControl/PlayOptionsContainer
onready var extras_options = $MarginContainer/MainControl/ExtrasOptionsContainer
onready var continue_campaign_button = $MarginContainer/MainControl/PlayOptionsContainer/ContinueCampaignButton
onready var audio_menu = $MarginContainer/MainControl/AudioMenu
onready var deck_list_menu = $MarginContainer/MainControl/DeckListInterface
onready var tooltip_manager = $TooltipManager

var credits_scene : PackedScene = preload("res://Scenes/Credits/Credits.tscn")
var deck_view_scene : PackedScene = preload("res://Scenes/DeckViewer/DeckViewer.tscn")

func _ready():
	animation_player.play("SlideInLeft")
	if PersistentData.has_progress():
		continue_campaign_button.show()

func _on_Card_inspected(card_node):
	tooltip_manager.inspect_card(card_node)

func _on_Card_forgotten(_card_node):
	tooltip_manager.reset()

func _remove_deck_view(deck_viewer:Node):
	window_container.get_child(0).queue_free()
	tooltip_manager.reset()

func _attach_deck_view(deck_viewer:DeckViewer):
	window_container.add_child(deck_viewer)
	deck_viewer.connect("card_inspected", self, "_on_Card_inspected")
	deck_viewer.connect("card_forgotten", self, "_on_Card_forgotten")
	deck_viewer.connect("back_pressed", self, "_remove_deck_view", [deck_viewer])

func _on_ViewDeck_pressed(deck:Array):
	var deck_view = deck_view_scene.instance()
	get_tree().paused = true
	_attach_deck_view(deck_view)
	deck_view.deck = deck

func _on_CreditsButton_pressed():
	var credits_instance = credits_scene.instance()
	window_container.add_child(credits_instance)

func _on_ExitGameButton_pressed():
	get_tree().quit()

func _on_PlayButton_pressed():
	init_options.hide()
	play_options.show()

func _on_ExtrasButton_pressed():
	init_options.hide()
	extras_options.show()

func _on_BackButton_pressed():
	play_options.hide()
	extras_options.hide()
	audio_menu.hide()
	init_options.show()

func _on_OnlineArenaButton_pressed():
	get_tree().change_scene("res://Scenes/MainMenu/NetworkMenu/NetworkMenu.tscn")

func _on_ContinueCampaignButton_pressed():
	get_tree().change_scene("res://Scenes/CampaignInterface/CampaignInterface.tscn")

func _on_NewCampaignButton_pressed():
	PersistentData.reset_progress()
	get_tree().change_scene("res://Scenes/CampaignInterface/CampaignInterface.tscn")

func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_AudioMenu_return_button_pressed():
	play_options.hide()
	audio_menu.hide()
	init_options.show()

func _on_OptionsButton_pressed():
	init_options.hide()
	audio_menu.show()

func _on_ViewDecksButton_pressed():
	extras_options.hide()
	deck_list_menu.show()

func _on_DeckListInterface_back_pressed():
	deck_list_menu.hide()
	extras_options.show()

func _on_DeckListInterface_deck_selected(deck : DeckData):
	var cards : Array = []
	for card in deck.cards:
		cards.append(card.duplicate())
	var deck_view = deck_view_scene.instance()
	_attach_deck_view(deck_view)
	deck_view.deck = cards
	deck_view.title = deck.title
