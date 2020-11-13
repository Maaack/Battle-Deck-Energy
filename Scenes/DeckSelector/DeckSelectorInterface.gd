extends Control


onready var confirm_button = $DeckSelectPanel/MarginContainer/VBoxContainer/HBoxContainer/MarginContainer/ConfirmButton
onready var item_list = $DeckSelectPanel/MarginContainer/VBoxContainer/ItemList

export(Array, Resource) var decks : Array = []

var selected_index : int

func _ready():
	for deck in decks:
		if deck is DeckData:
			item_list.add_item(deck.title, deck.icon)

func _on_ItemList_item_selected(index : int):
	if item_list.is_item_disabled(index):
		return
	selected_index = index
	confirm_button.disabled = false

func _on_ConfirmButton_pressed():
	print("Confirming %s for battle!" % [item_list.get_item_text(selected_index)])
