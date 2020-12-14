extends Control


signal back_pressed
signal deck_selected(deck)

onready var view_button = $DeckSelectPanel/MarginContainer/VBoxContainer/HBoxContainer/ViewButton
onready var item_list = $DeckSelectPanel/MarginContainer/VBoxContainer/ItemList
onready var custom_deck_info_label = $DeckSelectPanel/MarginContainer/VBoxContainer/ItemList/CustomDeckInfoLabel

var deck_library : CommonData = preload("res://Resources/Common/DeckLibrary.tres")

var decks : Array
var selected_index : int

func _ready():
	decks = deck_library.data.values()
	var saved_decks : Array = PersistentData.load_decks()
	if saved_decks.size() > 0:
		custom_deck_info_label.hide()
	decks += saved_decks
	for deck in decks:
		if deck is DeckData:
			item_list.add_item(deck.title, deck.icon)

func _on_ItemList_item_selected(index : int):
	if item_list.is_item_disabled(index):
		return
	selected_index = index
	view_button.disabled = false

func _on_BackButton_pressed():
	emit_signal("back_pressed")

func _on_ViewButton_pressed():
	emit_signal("deck_selected", decks[selected_index])
