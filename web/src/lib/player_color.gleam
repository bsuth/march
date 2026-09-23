import gleam/dynamic/decode
import gleam/json

pub type PlayerColor {
  Black
  White
  Red
  Blue
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn json(player_color: PlayerColor) {
  json.string(case player_color {
    Black -> "black"
    White -> "white"
    Red -> "red"
    Blue -> "blue"
  })
}

pub fn decoder() {
  decode.then(decode.string, fn(player_color_string) {
    case player_color_string {
      "black" -> decode.success(Black)
      "white" -> decode.success(White)
      "red" -> decode.success(Red)
      "blue" -> decode.success(Blue)
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
    1, True -> Red
    2, True -> White
    3, True -> Blue
    _, _ -> Black
  }
}

pub fn to_player_index(player_color: PlayerColor, doubles: Bool) {
  case player_color, doubles {
    White, False -> 1
    Red, True -> 1
    White, True -> 2
    Blue, True -> 3
    _, _ -> 0
  }
}
