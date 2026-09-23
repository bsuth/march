import engine/face.{type Face}
import engine/suit.{type Suit}
import gleam/dynamic/decode
import gleam/json
import yuzu

pub type Card {
  Card(player_index: Int, face: Face, suit: Suit)
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(card: Card) {
  json.object([
    #("player_index", json.int(card.player_index)),
    #("face", face.json(card.face)),
    #("suit", suit.json(card.suit)),
  ])
}

pub fn decoder() {
  use player_index <- decode.field("player_index", decode.int)
  use face <- decode.field("face", face.decoder())
  use suit <- decode.field("suit", suit.decoder())
  decode.success(Card(player_index:, face:, suit:))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn deck(player_index: Int) {
  [
    Card(player_index:, face: face.Jack, suit: suit.Spades),
    Card(player_index:, face: face.Queen, suit: suit.Spades),
    Card(player_index:, face: face.King, suit: suit.Spades),
    Card(player_index:, face: face.Ace, suit: suit.Spades),
    Card(player_index:, face: face.Jack, suit: suit.Diamonds),
    Card(player_index:, face: face.Queen, suit: suit.Diamonds),
    Card(player_index:, face: face.King, suit: suit.Diamonds),
    Card(player_index:, face: face.Ace, suit: suit.Diamonds),
    Card(player_index:, face: face.Jack, suit: suit.Clubs),
    Card(player_index:, face: face.Queen, suit: suit.Clubs),
    Card(player_index:, face: face.King, suit: suit.Clubs),
    Card(player_index:, face: face.Ace, suit: suit.Clubs),
    Card(player_index:, face: face.Jack, suit: suit.Hearts),
    Card(player_index:, face: face.Queen, suit: suit.Hearts),
    Card(player_index:, face: face.King, suit: suit.Hearts),
    Card(player_index:, face: face.Ace, suit: suit.Hearts),
  ]
}

pub fn can_capture(a: Card, b: Card) {
  use <- yuzu.true_(a.player_index % 2 != b.player_index % 2)

  case a.face, b.face, a.suit, b.suit {
    _, _, suit.Spades, suit.Diamonds -> True
    _, _, suit.Spades, suit.Hearts -> False
    _, _, suit.Diamonds, suit.Spades -> False
    _, _, suit.Diamonds, suit.Clubs -> True
    _, _, suit.Clubs, suit.Diamonds -> False
    _, _, suit.Clubs, suit.Hearts -> True
    _, _, suit.Hearts, suit.Spades -> True
    _, _, suit.Hearts, suit.Clubs -> False
    face.Jack, face.Jack, _, _ -> True
    face.Jack, _, _, _ -> False
    face.Queen, face.Jack, _, _ -> True
    face.Queen, face.Queen, _, _ -> True
    face.Queen, _, _, _ -> False
    face.King, face.Ace, _, _ -> False
    face.King, _, _, _ -> True
    face.Ace, _, _, _ -> True
  }
}
