import core/game/card.{type Card}
import core/game/color.{type Color}
import gleam/dynamic/decode
import gleam/json

pub type Unit {
  Unit(card: Card, color: Color)
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(unit: Unit) {
  json.object([
    #("card", card.json(unit.card)),
    #("color", color.json(unit.color)),
  ])
}

pub fn decoder() {
  use card <- decode.field("card", card.decoder())
  use color <- decode.field("color", color.decoder())
  decode.success(Unit(card:, color:))
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn can_capture(a: Unit, b: Unit) {
  a.color != b.color && card.can_capture(a.card, b.card)
}
