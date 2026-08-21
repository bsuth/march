import gleam/dynamic/decode
import gleam/json

pub type Variant {
  Classic
  Standard
}

pub fn to_string(variant: Variant) {
  case variant {
    Classic -> "classic"
    Standard -> "standard"
  }
}

pub fn from_string(variant_string: String) {
  case variant_string {
    "classic" -> Ok(Classic)
    "standard" -> Ok(Standard)
    _ -> Error(Nil)
  }
}

pub fn json(variant: Variant) {
  variant |> to_string() |> json.string()
}

pub fn decoder() {
  decode.then(decode.string, fn(variant_string) {
    case from_string(variant_string) {
      Ok(variant) -> decode.success(variant)
      Error(_) -> decode.failure(Classic, "variant")
    }
  })
}
