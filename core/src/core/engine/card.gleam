import core/engine/face.{type Face}
import core/engine/suit.{type Suit}
import gleam/dynamic/decode
import gleam/json

pub type Card {
  Card(face: Face, suit: Suit)
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(card: Card) {
  json.object([
    #("face", face.json(card.face)),
    #("suit", suit.json(card.suit)),
  ])
}

pub fn decoder() {
  use face <- decode.field("face", face.decoder())
  use suit <- decode.field("suit", suit.decoder())
  decode.success(Card(face:, suit:))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn deck() {
  [
    Card(face: face.Jack, suit: suit.Spades),
    Card(face: face.Queen, suit: suit.Spades),
    Card(face: face.King, suit: suit.Spades),
    Card(face: face.Ace, suit: suit.Spades),
    Card(face: face.Jack, suit: suit.Diamonds),
    Card(face: face.Queen, suit: suit.Diamonds),
    Card(face: face.King, suit: suit.Diamonds),
    Card(face: face.Ace, suit: suit.Diamonds),
    Card(face: face.Jack, suit: suit.Clubs),
    Card(face: face.Queen, suit: suit.Clubs),
    Card(face: face.King, suit: suit.Clubs),
    Card(face: face.Ace, suit: suit.Clubs),
    Card(face: face.Jack, suit: suit.Hearts),
    Card(face: face.Queen, suit: suit.Hearts),
    Card(face: face.King, suit: suit.Hearts),
    Card(face: face.Ace, suit: suit.Hearts),
  ]
}
