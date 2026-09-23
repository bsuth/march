import engine/board.{type Board}
import engine/face.{type Face}
import engine/trait.{type Trait}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/json

pub type Settings {
  Settings(
    board: Board,
    doubles: Bool,
    hand_size: Int,
    traits: Dict(Face, List(Trait)),
  )
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(settings: Settings) {
  json.object([
    #("board", board.json(settings.board)),
    #("doubles", json.bool(settings.doubles)),
    #("hand_size", json.int(settings.hand_size)),
    #(
      "traits",
      json.dict(settings.traits, face.to_string, json.array(_, trait.json)),
    ),
  ])
}

pub fn decoder() {
  use board <- decode.field("board", board.decoder())
  use doubles <- decode.field("doubles", decode.bool)
  use hand_size <- decode.field("hand_size", decode.int)

  use traits <- decode.field(
    "traits",
    decode.dict(face.decoder(), decode.list(trait.decoder())),
  )

  decode.success(Settings(board:, doubles:, hand_size:, traits:))
}

// -----------------------------------------------------------------------------
// Presets
// -----------------------------------------------------------------------------

pub fn classic() {
  Settings(
    board: board.normal(4, 4),
    doubles: False,
    hand_size: 4,
    traits: dict.new()
      |> dict.insert(face.Jack, [trait.Adjacent])
      |> dict.insert(face.Queen, [trait.Adjacent])
      |> dict.insert(face.King, [trait.Adjacent])
      |> dict.insert(face.Ace, [trait.Adjacent]),
  )
}

pub fn standard() {
  Settings(
    board: board.normal(4, 4),
    doubles: False,
    hand_size: 4,
    traits: dict.new()
      |> dict.insert(face.Jack, [trait.Adjacent, trait.Diagonal])
      |> dict.insert(face.Queen, [trait.Adjacent, trait.Jump])
      |> dict.insert(face.King, [trait.Adjacent, trait.AnyMarch])
      |> dict.insert(face.Ace, [trait.Adjacent]),
  )
}

pub fn doubles() {
  Settings(
    board: board.normal(4, 4),
    doubles: True,
    hand_size: 4,
    traits: dict.new()
      |> dict.insert(face.Jack, [trait.Adjacent, trait.AnyMarch])
      |> dict.insert(face.Queen, [trait.Adjacent, trait.AnyMarch])
      |> dict.insert(face.King, [trait.Adjacent, trait.AnyMarch])
      |> dict.insert(face.Ace, [trait.Adjacent, trait.AnyMarch]),
  )
}

// -----------------------------------------------------------------------------
// Presets
// -----------------------------------------------------------------------------

pub fn get_base_index(settings: Settings, player_index: Int) {
  case settings.doubles, player_index {
    False, 1 -> settings.board.width * settings.board.height - 1
    True, 3 -> settings.board.width * { settings.board.height - 1 }
    True, 2 -> settings.board.width * settings.board.height - 1
    True, 1 -> settings.board.width - 1
    _, _ -> 0
  }
}
