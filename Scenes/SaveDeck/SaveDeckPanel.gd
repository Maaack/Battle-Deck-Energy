extends Control


signal save_pressed(cards, title, icon)
signal skip_pressed

onready var title_line_edit = $Panel/OptionsMargin/OptionsVBox/DeckTitleHBox/TitleLineEdit
onready var icon_item_list = $Panel/OptionsMargin/OptionsVBox/DeckIconHBox/IconItemList
onready var save_button = $Panel/ButtonsMargin/HBoxContainer/SaveButton

var icons : Array
var cards : Array setget set_cards
var selected_index = null

func set_cards(value : Array):
	cards = value
	icons.clear()
	icon_item_list.clear()
	for card in cards:
		if card is CardData and not card.icon in icons:
			icons.append(card.icon)
	for icon in icons:
		icon_item_list.add_icon_item(icon)

func _is_saveable():
	if title_line_edit.text == '':
		save_button.disabled = true
	elif selected_index == null:
		save_button.disabled = true
	else:
		save_button.disabled = false

func _on_TitleLineEdit_text_changed(new_text):
	_is_saveable()

func _on_IconItemList_item_selected(index):
	if icon_item_list.is_item_disabled(index):
		return
	selected_index = index
	_is_saveable()

func _on_SaveButton_pressed():
	var icon : Texture = icon_item_list.get_item_icon(selected_index)
	var title : String = title_line_edit.text
	emit_signal("save_pressed", cards, title, icon)
	queue_free()

func _on_SkipButton_pressed():
	emit_signal("skip_pressed")
	queue_free()


