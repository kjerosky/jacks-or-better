class_name Deck
extends Node

var cards : Array[Dictionary] = []


func initialize():
	for suit in 4:
		for rank in 13:
			cards.push_back({
				"suit": suit,
				"rank": rank,
			})
	
	shuffle()


func shuffle():
	cards.shuffle()


func draw_card() -> Dictionary:
	return cards.pop_front()


func return_card(card: Dictionary):
	cards.push_back(card)
