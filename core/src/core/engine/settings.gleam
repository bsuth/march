import core/engine/board.{type Board, Board}
import core/engine/mode.{type Mode}
import gleam/dynamic/decode
import gleam/json

pub type Settings {
  Settings(board: Board, doubles: Bool, hand_size: Int, mode: Mode)
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(settings: Settings) {
  json.object([
    #("board", board.json(settings.board)),
    #("doubles", json.bool(settings.doubles)),
    #("hand_size", json.int(settings.hand_size)),
    #("mode", mode.json(settings.mode)),
  ])
}

pub fn decoder() {
  use board <- decode.field("board", board.decoder())
  use doubles <- decode.field("doubles", decode.bool)
  use hand_size <- decode.field("hand_size", decode.int)
  use mode <- decode.field("mode", mode.decoder())
  decode.success(Settings(board:, doubles:, hand_size:, mode:))
}

// -----------------------------------------------------------------------------
// Presets
// -----------------------------------------------------------------------------

pub fn classic() {
  Settings(board: Board(4, 4), doubles: False, hand_size: 4, mode: mode.Classic)
}

pub fn standard() {
  Settings(
    board: Board(4, 4),
    doubles: False,
    hand_size: 4,
    mode: mode.Standard,
  )
}

pub fn doubles() {
  Settings(board: Board(5, 5), doubles: True, hand_size: 4, mode: mode.AnyMarch)
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
