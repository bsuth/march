import gleam/dynamic/decode
import gleam/json

pub type Color {
  Black
  White
}

pub fn json(color: Color) {
  case color {
    Black -> json.string("black")
    White -> json.string("white")
  }
}

pub fn decoder() {
  decode.then(decode.string, fn(value) {
    case value {
      "black" -> decode.success(Black)
      "white" -> decode.success(White)
      _ -> decode.failure(Black, "Color")
    }
  })
}
