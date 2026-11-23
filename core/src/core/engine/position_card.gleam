import core/engine/face.{type Face}
import core/engine/suit.{type Suit}
import gleam/dynamic/decode
import gleam/json
import yuzu

pub type PositionCard {
  PositionCard(player_index: Int, face: Face, suit: Suit)
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(position_card: PositionCard) {
  json.object([
    #("player_index", json.int(position_card.player_index)),
    #("face", face.json(position_card.face)),
    #("suit", suit.json(position_card.suit)),
  ])
}

pub fn decoder() {
  use player_index <- decode.field("player_index", decode.int)
  use face <- decode.field("face", face.decoder())
  use suit <- decode.field("suit", suit.decoder())
  decode.success(PositionCard(player_index:, face:, suit:))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn can_capture(a: PositionCard, b: PositionCard) {
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
