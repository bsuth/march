import gleam/dynamic/decode
import gleam/json

pub type Face {
  Jack
  Queen
  King
  Ace
}

pub fn to_string(face: Face) {
  case face {
    Jack -> "jack"
    Queen -> "queen"
    King -> "king"
    Ace -> "ace"
  }
}

pub fn from_string(face_string: String) {
  case face_string {
    "jack" -> Ok(Jack)
    "queen" -> Ok(Queen)
    "king" -> Ok(King)
    "ace" -> Ok(Ace)
    _ -> Error(Nil)
  }
}

pub fn json(face: Face) {
  face |> to_string() |> json.string()
}

pub fn decoder() {
  decode.then(decode.string, fn(face_string) {
    case from_string(face_string) {
      Ok(face) -> decode.success(face)
      Error(_) -> decode.failure(Ace, "face")
    }
  })
}
