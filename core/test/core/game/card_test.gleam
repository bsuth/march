import core/game/card
import gleam/list

pub fn can_capture_test() {
  let suit_matchups = [
    #(card.Spades, card.Diamonds),
    #(card.Diamonds, card.Clubs),
    #(card.Clubs, card.Hearts),
    #(card.Hearts, card.Spades),
  ]

  [card.Jack, card.Queen, card.King, card.Ace]
  |> list.combination_pairs()
  |> list.each(fn(card_value_combination_pair) {
    let #(card_value_a, card_value_b) = card_value_combination_pair

    list.each(suit_matchups, fn(suit_matchup) {
      let #(strong_suit, weak_suit) = suit_matchup

      assert card.can_capture(
        card.Card(card_value_a, strong_suit),
        card.Card(card_value_b, weak_suit),
      )

      assert !card.can_capture(
        card.Card(card_value_b, weak_suit),
        card.Card(card_value_a, strong_suit),
      )

      assert card.can_capture(
        card.Card(card_value_b, strong_suit),
        card.Card(card_value_a, weak_suit),
      )

      assert !card.can_capture(
        card.Card(card_value_a, weak_suit),
        card.Card(card_value_b, strong_suit),
      )
    })
  })

  let value_matchups = [
    #(card.Jack, [card.Jack], [card.Queen, card.King, card.Ace]),
    #(card.Queen, [card.Jack, card.Queen], [card.King, card.Ace]),
    #(card.King, [card.Jack, card.Queen, card.King], [card.Ace]),
    #(card.Ace, [card.Jack, card.Queen, card.King, card.Ace], []),
  ]

  [#(card.Spades, card.Clubs), #(card.Diamonds, card.Hearts)]
  |> list.each(fn(same_color_suits) {
    let #(suit_a, suit_b) = same_color_suits

    list.each(value_matchups, fn(value_matchup) {
      let #(card_value, weak_values, strong_values) = value_matchup

      list.each(weak_values, fn(weak_value) {
        assert card.can_capture(
          card.Card(card_value, suit_a),
          card.Card(weak_value, suit_a),
        )

        assert card.can_capture(
          card.Card(card_value, suit_b),
          card.Card(weak_value, suit_b),
        )

        assert card.can_capture(
          card.Card(card_value, suit_a),
          card.Card(weak_value, suit_b),
        )

        assert card.can_capture(
          card.Card(card_value, suit_b),
          card.Card(weak_value, suit_a),
        )
      })

      list.each(strong_values, fn(strong_value) {
        assert !card.can_capture(
          card.Card(card_value, suit_a),
          card.Card(strong_value, suit_a),
        )

        assert !card.can_capture(
          card.Card(card_value, suit_b),
          card.Card(strong_value, suit_b),
        )

        assert !card.can_capture(
          card.Card(card_value, suit_a),
          card.Card(strong_value, suit_b),
        )

        assert !card.can_capture(
          card.Card(card_value, suit_b),
          card.Card(strong_value, suit_a),
        )
      })
    })
  })
}
