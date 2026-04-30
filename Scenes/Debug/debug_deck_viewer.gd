extends DeckViewer

@onready var file_lister = $FileLister

func _ready():
	var load_deck : Array[CardData]
	for file in file_lister.files:
		var card = load(file)
		load_deck.append(card)
	deck = load_deck
