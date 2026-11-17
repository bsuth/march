import core/engine/face.{type Face}
import core/engine/trait
import gleam/dynamic/decode
import gleam/json

pub type Mode {
  AnyMarch
  Classic
  Standard
}

// -----------------------------------------------------------------------------
// Encoding / Decoding
// -----------------------------------------------------------------------------

pub fn to_string(mode: Mode) {
  case mode {
    AnyMarch -> "any_march"
    Classic -> "classic"
    Standard -> "standard"
  }
}

pub fn from_string(mode_string: String) {
  case mode_string {
    "any_march" -> Ok(AnyMarch)
    "classic" -> Ok(Classic)
    "standard" -> Ok(Standard)
    _ -> Error(Nil)
  }
}

pub fn json(mode) {
  mode |> to_string() |> json.string()
}

pub fn decoder() {
  decode.then(decode.string, fn(mode_string) {
    case from_string(mode_string) {
      Ok(mode) -> decode.success(mode)
      Error(_) -> decode.failure(Classic, "mode")
    }
  })
}

// -----------------------------------------------------------------------------
// Presets
// -----------------------------------------------------------------------------

pub fn to_traits(mode: Mode, face: Face) {
  case mode, face {
    AnyMarch, _ -> [trait.Adjacent, trait.AnyMarch]
    Classic, _ -> [trait.Adjacent]
    Standard, face.Jack -> [trait.Adjacent, trait.Diagonal]
    Standard, face.Queen -> [trait.Adjacent, trait.Jump]
    Standard, face.King -> [trait.Adjacent, trait.AnyMarch]
    Standard, face.Ace -> [trait.Adjacent]
  }
}
