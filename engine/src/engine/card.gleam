import engine/card/face.{type Face}
import engine/card/suit.{type Suit}
import engine/color.{type Color}
import engine/trait.{type Trait}
import engine/variant.{type Variant}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import yuzu

pub type Card {
  Card(face: Face, suit: Suit, color: Color, traits: List(Trait))
}

const classic_traits = [trait.Adjacent]

const standard_jack_traits = [trait.Adjacent, trait.Diagonal]

const standard_queen_traits = [trait.Adjacent, trait.Jump]

const standard_king_traits = [trait.Adjacent, trait.AnyMarch]

const standard_ace_traits = [trait.Adjacent]

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(card: Card) {
  json.object([
    #("face", face.json(card.face)),
    #("suit", suit.json(card.suit)),
    #("color", color.json(card.color)),
    #("traits", json.array(card.traits, trait.json)),
  ])
}

pub fn decoder() {
  use face <- decode.field("face", face.decoder())
  use suit <- decode.field("suit", suit.decoder())
  use color <- decode.field("color", color.decoder())
  use traits <- decode.field("traits", decode.list(trait.decoder()))
  decode.success(Card(face:, suit:, color:, traits:))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn deck(variant: Variant, color: Color) {
  case variant {
    variant.Classic -> classic_deck(color)
    variant.Standard -> standard_deck(color)
  }
}

fn classic_deck(color: Color) {
  [
    Card(face: face.Jack, suit: suit.Spades, color:, traits: classic_traits),
    Card(face: face.Queen, suit: suit.Spades, color:, traits: classic_traits),
    Card(face: face.King, suit: suit.Spades, color:, traits: classic_traits),
    Card(face: face.Ace, suit: suit.Spades, color:, traits: classic_traits),
    Card(face: face.Jack, suit: suit.Diamonds, color:, traits: classic_traits),
    Card(face: face.Queen, suit: suit.Diamonds, color:, traits: classic_traits),
    Card(face: face.King, suit: suit.Diamonds, color:, traits: classic_traits),
    Card(face: face.Ace, suit: suit.Diamonds, color:, traits: classic_traits),
    Card(face: face.Jack, suit: suit.Clubs, color:, traits: classic_traits),
    Card(face: face.Queen, suit: suit.Clubs, color:, traits: classic_traits),
    Card(face: face.King, suit: suit.Clubs, color:, traits: classic_traits),
    Card(face: face.Ace, suit: suit.Clubs, color:, traits: classic_traits),
    Card(face: face.Jack, suit: suit.Hearts, color:, traits: classic_traits),
    Card(face: face.Queen, suit: suit.Hearts, color:, traits: classic_traits),
    Card(face: face.King, suit: suit.Hearts, color:, traits: classic_traits),
    Card(face: face.Ace, suit: suit.Hearts, color:, traits: classic_traits),
  ]
}

fn standard_deck(color: Color) {
  [
    standard_deck_jack(suit.Spades, color),
    standard_deck_queen(suit.Spades, color),
    standard_deck_king(suit.Spades, color),
    standard_deck_ace(suit.Spades, color),
    standard_deck_jack(suit.Diamonds, color),
    standard_deck_queen(suit.Diamonds, color),
    standard_deck_king(suit.Diamonds, color),
    standard_deck_ace(suit.Diamonds, color),
    standard_deck_jack(suit.Clubs, color),
    standard_deck_queen(suit.Clubs, color),
    standard_deck_king(suit.Clubs, color),
    standard_deck_ace(suit.Clubs, color),
    standard_deck_jack(suit.Hearts, color),
    standard_deck_queen(suit.Hearts, color),
    standard_deck_king(suit.Hearts, color),
    standard_deck_ace(suit.Hearts, color),
  ]
}

fn standard_deck_jack(suit: Suit, color: Color) {
  Card(face: face.Jack, suit:, color:, traits: standard_jack_traits)
}

fn standard_deck_queen(suit: Suit, color: Color) {
  Card(face: face.Queen, suit:, color:, traits: standard_queen_traits)
}

fn standard_deck_king(suit: Suit, color: Color) {
  Card(face: face.King, suit:, color:, traits: standard_king_traits)
}

fn standard_deck_ace(suit: Suit, color: Color) {
  Card(face: face.Ace, suit:, color:, traits: standard_ace_traits)
}

pub fn deal(variant: Variant, color: Color, hand_size: Int) {
  case variant {
    variant.Classic -> classic_deal(color, hand_size)
    variant.Standard -> standard_deal(color, hand_size)
  }
}

fn classic_deal(color: Color, init_hand_size: Int) {
  classic_deck(color)
  |> list.shuffle()
  |> list.split(init_hand_size)
}

fn standard_deal(color: Color, init_hand_size: Int) {
  standard_deck(color)
  |> list.shuffle()
  |> list.split(init_hand_size)
}

pub fn can_capture(a: Card, b: Card) {
  use <- yuzu.true(a.color != b.color, False)

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
