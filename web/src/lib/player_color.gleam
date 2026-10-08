import engine/board.{type Board}
import gleam/dynamic/decode
import gleam/json
import yuzu

pub type PlayerColor {
  Black
  White
  LightRed
  DarkRed
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(player_color: PlayerColor) {
  json.string(case player_color {
    Black -> "black"
    White -> "white"
    LightRed -> "light_red"
    DarkRed -> "dark_red"
  })
}

pub fn decoder() {
  decode.then(decode.string, fn(player_color_string) {
    case player_color_string {
      "black" -> decode.success(Black)
      "white" -> decode.success(White)
      "light_red" -> decode.success(LightRed)
      "dark_red" -> decode.success(DarkRed)
      _ -> decode.failure(Black, "card color")
    }
  })
}

// -----------------------------------------------------------------------------
// Lib
// -----------------------------------------------------------------------------

pub fn from_player_index(player_index: Int, doubles: Bool) {
  case player_index, doubles {
    1, False -> White
    1, True -> LightRed
    2, True -> White
    3, True -> DarkRed
    _, _ -> Black
  }
}

pub fn to_player_index(player_color: PlayerColor, doubles: Bool) {
  case player_color, doubles {
    White, False -> 1
    LightRed, True -> 1
    White, True -> 2
    DarkRed, True -> 3
    _, _ -> 0
  }
}

pub fn from_base_index(base_index: Int, board: Board) {
  use <- yuzu.false(base_index == board.width * board.height - 1, White)
  use <- yuzu.false(base_index == board.width - 1, LightRed)
  use <- yuzu.false(base_index == board.width * { board.height - 1 }, DarkRed)
  Black
}

pub fn to_base_index(player_color: PlayerColor, board: Board) {
  case player_color {
    Black -> 0
    White -> board.width * board.height - 1
    LightRed -> board.width - 1
    DarkRed -> board.width * { board.height - 1 }
  }
}
