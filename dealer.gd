class_name Dealer
extends Node3D

@export var card_scene : PackedScene
@export var game_manager : GameManager
@export var deck : Deck
@export var dealt_card_positions: Array[Marker3D]

var cards : Array[Card] = []

var cards_exist := false


func _ready():
	deck.initialize()
	for i in 5:
		var new_card : Card = card_scene.instantiate()
		new_card.setup(i)
		new_card.global_position = global_position
		cards.push_back(new_card)


func _process(_delta):
	if not cards_exist:
		cards_exist = true
		for i in cards.size():
			var card := cards[i]
			card.clicked.connect(game_manager._on_card_clicked)
			get_tree().root.add_child(card)


func deal_cards(card_indices: Array[int], last_card_callback: Callable):
	var card_callback := func(): pass
	for card_index in card_indices.size():
		var i := card_indices[card_index]
		var card = cards[i]
		if card_index == card_indices.size() - 1:
			card_callback = last_card_callback
		
		var card_attributes := deck.draw_card()
		card.set_attributes(card_attributes)
		
		card.global_position.y = global_position.y
		var final_tossed_position = dealt_card_positions[i].position
		card.toss_to(final_tossed_position, card_index * 0.3, card_callback)


func flip_cards(card_indices: Array[int], last_card_callback: Callable):
	var card_callback := func(): pass
	for card_index in card_indices.size():
		var i := card_indices[card_index]
		var card = cards[i]
		if card_index == card_indices.size() - 1:
			card_callback = last_card_callback
		
		card.flip(0.1 * card_index, card_callback)


func return_cards_to_deck(card_indices: Array[int], last_card_callback: Callable):
	var card_callback := func(): pass
	for card_index in card_indices.size():
		var i := card_indices[card_index]
		var card = cards[i]
		if card_index == card_indices.size() - 1:
			card_callback = last_card_callback
		
		card.global_position.y = -0.075
		var destination := Vector3(global_position.x, card.global_position.y, global_position.z)
		card.flip(0.1 * card_index, func():
			card.slide_to(destination, func():
				deck.return_card(card.attributes)
				card.straighten(card_callback)
			)
		)


func determine_hand_rank() -> HandRank.Rank:
	return HandRank.determine_rank(cards)
