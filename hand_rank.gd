class_name HandRank

enum Rank {
	ROYAL_FLUSH,
	STRAIGHT_FLUSH,
	FOUR_OF_A_KIND,
	FULL_HOUSE,
	FLUSH,
	STRAIGHT,
	THREE_OF_A_KIND,
	TWO_PAIR,
	JACKS_OR_BETTER,
	NOTHING,
}

const RANK_TO_NAME_MAP := {
	Rank.ROYAL_FLUSH: "ROYAL FLUSH",
	Rank.STRAIGHT_FLUSH: "STRAIGHT FLUSH",
	Rank.FOUR_OF_A_KIND: "FOUR OF A KIND",
	Rank.FULL_HOUSE: "FULL HOUSE",
	Rank.FLUSH: "FLUSH",
	Rank.STRAIGHT: "STRAIGHT",
	Rank.THREE_OF_A_KIND: "THREE OF A KIND",
	Rank.TWO_PAIR: "TWO PAIR",
	Rank.JACKS_OR_BETTER: "JACKS OR BETTER",
	Rank.NOTHING: "NOTHING",
}

const ACE_INDEX := 0
const JACK_INDEX := 10
const KING_INDEX := 12


static func rank_to_name(rank: Rank):
	return RANK_TO_NAME_MAP[rank]


static func determine_rank(cards: Array[Card]):
	var rank_counts : Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	var suit_counts : Array[int] = [0, 0, 0, 0]
	for card in cards:
		var suit = card.attributes["suit"]
		var rank = card.attributes["rank"]
		suit_counts[suit] += 1
		rank_counts[rank] += 1
	
	var has_flush = 5 in suit_counts
	
	var pairs := 0
	var has_jacks_or_better := false
	var has_three_of_a_kind := false
	var has_four_of_a_kind := false
	var consecutive_ranks := 0
	var highest_consecutive_ranks := 0
	var highest_consecutive_ranks_index := -1
	for i in rank_counts.size():
		var rank_count = rank_counts[i]
		if rank_count == 2:
			pairs += 1
			if i == ACE_INDEX or (i >= JACK_INDEX and i <= KING_INDEX):
				has_jacks_or_better = true
		elif rank_count == 3:
			has_three_of_a_kind = true
		elif rank_count == 4:
			has_four_of_a_kind = true
		
		if rank_count == 1:
			consecutive_ranks += 1
			if consecutive_ranks > highest_consecutive_ranks:
				highest_consecutive_ranks = consecutive_ranks
				highest_consecutive_ranks_index = i
		else:
			consecutive_ranks = 0
	
	var has_straight_ace_high = highest_consecutive_ranks == 4 and highest_consecutive_ranks_index == KING_INDEX and rank_counts[ACE_INDEX] == 1
	var has_straight := has_straight_ace_high or highest_consecutive_ranks == 5
	
	var hand_rank := Rank.NOTHING
	if (has_straight_ace_high and has_flush):
		hand_rank = Rank.ROYAL_FLUSH
	elif (has_straight and has_flush):
		hand_rank = Rank.STRAIGHT_FLUSH
	elif (has_four_of_a_kind):
		hand_rank = Rank.FOUR_OF_A_KIND
	elif (has_three_of_a_kind and pairs == 1):
		hand_rank = Rank.FULL_HOUSE
	elif (has_flush):
		hand_rank = Rank.FLUSH
	elif (has_straight):
		hand_rank = Rank.STRAIGHT
	elif (has_three_of_a_kind):
		hand_rank = Rank.THREE_OF_A_KIND
	elif (pairs == 2):
		hand_rank = Rank.TWO_PAIR
	elif (has_jacks_or_better):
		hand_rank = Rank.JACKS_OR_BETTER
	
	return hand_rank
