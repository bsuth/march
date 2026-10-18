import core/engine/card.{type Card}
import gleam/dynamic/decode
import gleam/json
import gleam/option.{type Option}

pub type Turn {
  Controlled(
    capture: Option(Card),
    lead: Option(#(Int, Int)),
    marches: List(Int),
    deploy: Option(Card),
    draw: Option(Card),
  )
  Observed(
    capture: Option(Card),
    lead: Option(#(Int, Int)),
    marches: List(Int),
    deploy: Option(Card),
    draw: Bool,
  )
}

pub type Request {
  Request(lead: Option(#(Int, Int)), marches: List(Int), deploy: Option(Card))
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(turn: Turn) {
  json.object([
    #("capture", json.nullable(turn.capture, card.json)),
    #(
      "lead",
      json.nullable(turn.lead, fn(lead) {
        json.object([
          #("source", json.int(lead.0)),
          #("dest", json.int(lead.1)),
        ])
      }),
    ),
    #("marches", json.array(turn.marches, json.int)),
    #("deploy", json.nullable(turn.deploy, card.json)),
    #("draw", case turn {
      Controlled(_, _, _, _, draw) -> json.nullable(draw, card.json)
      Observed(_, _, _, _, draw) -> json.bool(draw)
    }),
  ])
}

pub fn decoder() {
  use capture <- decode.field("capture", decode.optional(card.decoder()))

  use lead <- decode.field(
    "lead",
    decode.optional({
      use source <- decode.field("source", decode.int)
      use dest <- decode.field("dest", decode.int)
      decode.success(#(source, dest))
    }),
  )

  use marches <- decode.field("marches", decode.list(decode.int))
  use deploy <- decode.field("deploy", decode.optional(card.decoder()))

  let controlled_decoder = {
    use draw <- decode.field("draw", decode.optional(card.decoder()))
    decode.success(Controlled(capture:, lead:, marches:, deploy:, draw:))
  }

  let observed_decoder = {
    use draw <- decode.field("draw", decode.bool)
    decode.success(Observed(capture:, lead:, marches:, deploy:, draw:))
  }

  decode.one_of(controlled_decoder, [observed_decoder])
}

pub fn request_json(request: Request) {
  json.object([
    #(
      "lead",
      json.nullable(request.lead, fn(lead) {
        json.object([
          #("source", json.int(lead.0)),
          #("dest", json.int(lead.1)),
        ])
      }),
    ),
    #("marches", json.array(request.marches, json.int)),
    #("deploy", json.nullable(request.deploy, card.json)),
  ])
}

pub fn request_decoder() {
  use lead <- decode.field(
    "lead",
    decode.optional({
      use source <- decode.field("source", decode.int)
      use dest <- decode.field("dest", decode.int)
      decode.success(#(source, dest))
    }),
  )

  use marches <- decode.field("marches", decode.list(decode.int))
  use deploy <- decode.field("deploy", decode.optional(card.decoder()))

  decode.success(Request(lead:, marches:, deploy:))
}
