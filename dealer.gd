class_name Dealer
extends Node3D

@export var card_scene : PackedScene

var cards : Array[Card] = []

var cards_exist := false


func _ready():
	for i in 5:
		var new_card : Card = card_scene.instantiate()
		new_card.setup(i % 13, i % 4)
		new_card.position = position
		cards.push_back(new_card)


func _process(_delta):
	if not cards_exist:
		cards_exist = true
		for i in cards.size():
			var card := cards[i]
			get_tree().root.add_child(card)
			card.toss_to(Vector3(i * 3.25 - 6.5, 0, 3), i * 0.3, func():
				card.flip((cards.size() - 1 - i) * 0.3 + 0.1 * i, func(): pass)
			)
