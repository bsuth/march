import gleam/dynamic/decode
import gleam/json

pub type Trait {
  Adjacent
  AnyMarch
  Diagonal
  Jump
  Mobius
}

pub fn to_string(trait: Trait) {
  case trait {
    Adjacent -> "adjacent"
    AnyMarch -> "any_march"
    Diagonal -> "diagonal"
    Jump -> "jump"
    Mobius -> "mobius"
  }
}

pub fn from_string(trait_string: String) {
  case trait_string {
    "adjacent" -> Ok(Adjacent)
    "any_march" -> Ok(AnyMarch)
    "diagonal" -> Ok(Diagonal)
    "jump" -> Ok(Jump)
    "mobius" -> Ok(Mobius)
    _ -> Error(Nil)
  }
}

pub fn json(trait: Trait) {
  trait |> to_string() |> json.string()
}

pub fn decoder() {
  decode.then(decode.string, fn(trait_string) {
    case from_string(trait_string) {
      Ok(variant) -> decode.success(variant)
      Error(_) -> decode.failure(Jump, "trait")
    }
  })
}
