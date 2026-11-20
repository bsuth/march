import gleam/dynamic/decode
import gleam/json

pub type CardArt {
  DefaultBlack
  DefaultBlue
  DefaultRed
  DefaultWhite
}

pub fn to_string(art: CardArt) {
  case art {
    DefaultBlack -> "default_black"
    DefaultBlue -> "default_blue"
    DefaultRed -> "default_red"
    DefaultWhite -> "default_white"
  }
}

pub fn from_string(face_string: String) {
  case face_string {
    "default_black" -> Ok(DefaultBlack)
    "default_blue" -> Ok(DefaultBlue)
    "default_red" -> Ok(DefaultRed)
    "default_white" -> Ok(DefaultWhite)
    _ -> Error(Nil)
  }
}

pub fn json(face: CardArt) {
  face |> to_string() |> json.string()
}

pub fn decoder() {
  decode.then(decode.string, fn(face_string) {
    case from_string(face_string) {
      Ok(face) -> decode.success(face)
      Error(_) -> decode.failure(DefaultBlack, "card_art")
    }
  })
}
