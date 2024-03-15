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
			dealer.deal_cards(ALL_CARD_INDICES, func():
				state = GameState.START_FLIPPING_CARDS
			)
			state = GameState.DEALING_HAND
		
		GameState.START_FLIPPING_CARDS:
			dealer.flip_cards(ALL_CARD_INDICES, func():
				state = GameState.PLAYER_IS_CHOOSING_CARDS
			)
			state = GameState.FLIPPING_CARDS
		
		GameState.PLAYER_IS_CHOOSING_CARDS:
			if Input.is_action_just_pressed("ChooseCard"):
				var mouse_position := get_viewport().get_mouse_position()


func _on_card_clicked(card_index: int):
	if state != GameState.PLAYER_IS_CHOOSING_CARDS:
		return
	
	clicked_cards_statuses[card_index] = not clicked_cards_statuses[card_index]
