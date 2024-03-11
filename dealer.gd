class_name Dealer
extends Node3D

@export var card_scene : PackedScene
@export var deck_card : Card

var cards : Array[Card] = []

var cards_exist := false


func _ready():
	deck_card.setup(13, 0)
	
	for i in 5:
		var new_card : Card = card_scene.instantiate()
		#TODO SETUP CORRECTLY!
		new_card.setup(i % 13, i % 4)
		new_card.position = position
		cards.push_back(new_card)


func _process(_delta):
	if not cards_exist:
		cards_exist = true
		for i in cards.size():
			var card := cards[i]
			get_tree().root.add_child(card)


func deal_cards(card_indices: Array[int], last_card_callback: Callable):
	var card_callback := func(): pass
	for card_index in card_indices.size():
		var i := card_indices[card_index]
		var card = cards[i]
		if card_index == card_indices.size() - 1:
			card_callback = last_card_callback
		
		card.toss_to(Vector3(i * 3.25 - 6.5, 0, 3), card_index * 0.3, card_callback)


func flip_cards(card_indices: Array[int], last_card_callback: Callable):
	var card_callback := func(): pass
	for card_index in card_indices.size():
		var i := card_indices[card_index]
		var card = cards[i]
		if card_index == card_indices.size() - 1:
			card_callback = last_card_callback
		
		card.flip(0.1 * card_index, card_callback)
