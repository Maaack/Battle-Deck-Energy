tool
extends Node2D


export(Resource) var card_settings setget set_card_settings


func set_card_settings(value:CardSettings):
	card_settings = value
	_update_card_front()

func _ready():
	_update_card_front()

func _update_card_front():
	if not is_instance_valid(card_settings):
		return
	if card_settings.title != "":
		$Control/TitlePanel/TitleLabel.text = card_settings.title
	if card_settings.description != "":
		$Control/DescriptionPanel/MarginContainer/DescriptionLabel.text = card_settings.description
	if card_settings.bde_cost >= 0:
		$Control/BDEPanel/BDECostLabel.text = str(card_settings.bde_cost)
