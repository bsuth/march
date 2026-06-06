import gleam/list
import lib/game/card.{type Card}

pub type Player {
  Player(hand: List(Card), deck: List(Card))
}

pub fn new() {
  let #(hand, deck) =
    card.standard_deck
    |> list.shuffle()
    |> list.split(4)

  Player(hand:, deck:)
}
