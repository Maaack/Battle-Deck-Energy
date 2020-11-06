extends Object


class_name EffectCardFilter

static func include_innate_cards(cards:Array):
	var innate_cards : Array = []
	for card in cards:
		if card is CardData and card.has_effect(EffectCalculator.INNATE_EFFECT):
			innate_cards.append(card)
	return innate_cards

static func exclude_retained_cards(cards:Array):
	var not_retained_cards : Array = []
	for card in cards:
		if card is CardData and not card.has_effect(EffectCalculator.RETAIN_EFFECT):
			not_retained_cards.append(card)
	return not_retained_cards

static func include_discardable_cards(cards:Array):
	var discardable_cards : Array = []
	for card in cards:
		if card is CardData:
			if card.has_effect(EffectCalculator.RETAIN_EFFECT):
				continue
			if card.has_effect(EffectCalculator.MOMENTARY_EFFECT):
				continue
			discardable_cards.append(card)
	return discardable_cards

static func include_exhaustable_cards(cards:Array):
	var exhaustable_cards : Array = []
	for card in cards:
		if card is CardData:
			if not card.has_effect(EffectCalculator.MOMENTARY_EFFECT):
				continue
			exhaustable_cards.append(card)
	return exhaustable_cards
