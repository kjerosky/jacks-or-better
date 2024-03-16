class_name GameManager
extends Node

@export var dealer: Dealer

enum GameState {
	WAIT_FOR_START,
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
var clicked_cards_statuses : Array[bool] = [false, false, false, false, false]

func _ready():
	state = GameState.WAIT_FOR_START


func _process(_delta):
	attempt_transition()
	process_state()


func attempt_transition():
	match state:
		GameState.WAIT_FOR_START:
			if Input.is_action_just_pressed("TEMP_action"):
				state = GameState.START_DEALING_HAND


func process_state():
	match state:
		GameState.START_DEALING_HAND:
			state = GameState.DEALING_HAND
			
			for i in clicked_cards_statuses.size():
				clicked_cards_statuses[i] = false
			
			dealer.deal_cards(ALL_CARD_INDICES, func():
				state = GameState.START_FLIPPING_CARDS
			)
		
		GameState.START_FLIPPING_CARDS:
			state = GameState.FLIPPING_CARDS
			dealer.flip_cards(ALL_CARD_INDICES, func():
				state = GameState.PLAYER_IS_CHOOSING_CARDS
			)
		
		GameState.PLAYER_IS_CHOOSING_CARDS:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				state = GameState.DISCARDING_CARDS
				
				var discarded_card_indices : Array[int] = []
				for i in clicked_cards_statuses.size():
					if clicked_cards_statuses[i]:
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
			for i in clicked_cards_statuses.size():
				if clicked_cards_statuses[i]:
					received_card_indices.push_back(i)

			dealer.deal_cards(received_card_indices, func():
				state = GameState.START_REVEALING_REPLACEMENT_CARDS
			)
		
		GameState.START_REVEALING_REPLACEMENT_CARDS:
			state = GameState.REVEALING_REPLACEMENT_CARDS
			
			var received_card_indices : Array[int] = []
			for i in clicked_cards_statuses.size():
				if clicked_cards_statuses[i]:
					received_card_indices.push_back(i)
			
			dealer.flip_cards(received_card_indices, func():
				state = GameState.DISPLAYING_HAND_RESULT
			)



func _on_card_clicked(card_index: int):
	if state != GameState.PLAYER_IS_CHOOSING_CARDS:
		return
	
	clicked_cards_statuses[card_index] = not clicked_cards_statuses[card_index]
