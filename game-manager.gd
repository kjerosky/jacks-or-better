class_name GameManager
extends Node

@export var dealer: Dealer
@export var hold_labels: Array[MeshInstance3D]

enum GameState {
	PLACING_BETS,
	START_DEALING_HAND,
	DEALING_HAND,
	START_FLIPPING_CARDS,
	FLIPPING_CARDS,
	PLAYER_IS_CHOOSING_CARDS,
	DISCARDING_CARDS,
	START_RECEIVING_REPLACEMENT_CARDS,
	RECEIVING_REPLACEMENT_CARDS,
	START_REVEALING_REPLACEMENT_CARDS,
	REVEALING_REPLACEMENT_CARDS,
	DISPLAYING_HAND_RESULT,
}
var state: GameState

const ALL_CARD_INDICES : Array[int] = [0, 1, 2, 3, 4]
var card_hold_statuses : Array[bool] = [false, false, false, false, false]

var is_first_round := true


func _ready():
	for hold_label in hold_labels:
		hold_label.visible = false
	
	state = GameState.PLACING_BETS


func _process(_delta):
	attempt_transition()


func attempt_transition():
	match state:
		GameState.PLACING_BETS:
			if Input.is_action_just_pressed("TEMP_action"):
				if is_first_round:
					is_first_round = false
					state = GameState.START_DEALING_HAND
				else:
					dealer.return_cards_to_deck(ALL_CARD_INDICES, func():
						state = GameState.START_DEALING_HAND
					)
		
		GameState.START_DEALING_HAND:
			state = GameState.DEALING_HAND
			
			for i in card_hold_statuses.size():
				card_hold_statuses[i] = false
			
			dealer.shuffle_deck()
			dealer.deal_cards(ALL_CARD_INDICES, func():
				state = GameState.START_FLIPPING_CARDS
			)
		
		GameState.START_FLIPPING_CARDS:
			state = GameState.FLIPPING_CARDS
			dealer.flip_cards(ALL_CARD_INDICES, func():
				print(HandRank.rank_to_name(dealer.determine_hand_rank()))
				state = GameState.PLAYER_IS_CHOOSING_CARDS
			)
		
		GameState.PLAYER_IS_CHOOSING_CARDS:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				state = GameState.DISCARDING_CARDS
				
				for hold_label in hold_labels:
					hold_label.visible = false
				
				var discarded_card_indices : Array[int] = []
				for i in card_hold_statuses.size():
					if not card_hold_statuses[i]:
						discarded_card_indices.push_back(i)
				
				if discarded_card_indices.is_empty():
					state = GameState.DISPLAYING_HAND_RESULT
				else:
					dealer.return_cards_to_deck(discarded_card_indices, func():
						state = GameState.START_RECEIVING_REPLACEMENT_CARDS
					)
		
		GameState.START_RECEIVING_REPLACEMENT_CARDS:
			state = GameState.RECEIVING_REPLACEMENT_CARDS
			
			var received_card_indices : Array[int] = []
			for i in card_hold_statuses.size():
				if not card_hold_statuses[i]:
					received_card_indices.push_back(i)

			dealer.deal_cards(received_card_indices, func():
				state = GameState.START_REVEALING_REPLACEMENT_CARDS
			)
		
		GameState.START_REVEALING_REPLACEMENT_CARDS:
			state = GameState.REVEALING_REPLACEMENT_CARDS
			
			var received_card_indices : Array[int] = []
			for i in card_hold_statuses.size():
				if not card_hold_statuses[i]:
					received_card_indices.push_back(i)
			
			dealer.flip_cards(received_card_indices, func():
				print(HandRank.rank_to_name(dealer.determine_hand_rank()))
				state = GameState.DISPLAYING_HAND_RESULT
			)
		
		GameState.DISPLAYING_HAND_RESULT:
			state = GameState.PLACING_BETS


func _on_card_clicked(card_index: int):
	if state != GameState.PLAYER_IS_CHOOSING_CARDS:
		return
	
	card_hold_statuses[card_index] = not card_hold_statuses[card_index]
	hold_labels[card_index].visible = card_hold_statuses[card_index]
