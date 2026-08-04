import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option

pub type Card {
  Card(value: Value, suit: Suit)
}

pub type Value {
  Jack
  Queen
  King
  Ace
}

pub type Suit {
  Spades
  Diamonds
  Clubs
  Hearts
}

pub const deck = [
  Card(value: Jack, suit: Spades),
  Card(value: Queen, suit: Spades),
  Card(value: King, suit: Spades),
  Card(value: Ace, suit: Spades),
  Card(value: Jack, suit: Diamonds),
  Card(value: Queen, suit: Diamonds),
  Card(value: King, suit: Diamonds),
  Card(value: Ace, suit: Diamonds),
  Card(value: Jack, suit: Clubs),
  Card(value: Queen, suit: Clubs),
  Card(value: King, suit: Clubs),
  Card(value: Ace, suit: Clubs),
  Card(value: Jack, suit: Hearts),
  Card(value: Queen, suit: Hearts),
  Card(value: King, suit: Hearts),
  Card(value: Ace, suit: Hearts),
]

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(card: Card) {
  let value_json = case card.value {
    Jack -> json.string("jack")
    Queen -> json.string("queen")
    King -> json.string("king")
    Ace -> json.string("ace")
  }

  let suit_json = case card.suit {
    Spades -> json.string("spades")
    Diamonds -> json.string("diamonds")
    Clubs -> json.string("clubs")
    Hearts -> json.string("hearts")
  }

  json.object([
    #("value", value_json),
    #("suit", suit_json),
  ])
}

pub fn decoder() {
  use value_string <- decode.field("value", decode.string)
  use suit_string <- decode.field("value", decode.string)

  let value_option = case value_string {
    "jack" -> option.Some(Jack)
    "queen" -> option.Some(Queen)
    "king" -> option.Some(King)
    "ace" -> option.Some(Ace)
    _ -> option.None
  }

  let suit_option = case suit_string {
    "spades" -> option.Some(Spades)
    "diamonds" -> option.Some(Diamonds)
    "clubs" -> option.Some(Clubs)
    "hearts" -> option.Some(Hearts)
    _ -> option.None
  }

  case value_option, suit_option {
    option.Some(value), option.Some(suit) -> decode.success(Card(value, suit))
    _, _ -> decode.failure(Card(Jack, Spades), "Card")
  }
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn deal(init_hand_size: Int) {
  deck
  |> list.shuffle()
  |> list.split(init_hand_size)
}

pub fn can_capture(a: Card, b: Card) {
  case a.value, b.value, a.suit, b.suit {
    _, _, Spades, Diamonds -> True
    _, _, Spades, Hearts -> False
    _, _, Diamonds, Spades -> False
    _, _, Diamonds, Clubs -> True
    _, _, Clubs, Diamonds -> False
    _, _, Clubs, Hearts -> True
    _, _, Hearts, Spades -> True
    _, _, Hearts, Clubs -> False
    Jack, Jack, _, _ -> True
    Jack, _, _, _ -> False
    Queen, Jack, _, _ -> True
    Queen, Queen, _, _ -> True
    Queen, _, _, _ -> False
    King, Ace, _, _ -> False
    King, _, _, _ -> True
    Ace, _, _, _ -> True
  }
}
