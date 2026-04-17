extends Node


signal card_drawn(character, card)
signal card_added_to_hand(character, card)
signal card_removed_from_hand(character, card)
signal card_discarded(character, card)
signal card_exhausted(character, card)
signal card_reshuffled(character, card)
signal card_revealed(character, card)
signal card_played(character, card, opportunity)
signal card_spawned(character, card)
signal status_updated(character, status, delta)
signal character_died(character)
signal active_character_updated(character)
signal active_team_updated(team)
signal before_hand_discarded(character)
signal before_hand_drawn(character)
signal turn_started(character)
signal turn_ended(character)
signal team_lost(team)
signal team_won(team)
signal opportunity_added(opportunity)
signal opportunity_removed(opportunity)
signal opportunities_reset
signal draw_pile_pressed
signal discard_pile_pressed
signal exhaust_pile_pressed
