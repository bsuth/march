import engine/variant.{type Variant}

pub fn variant(variant: Variant) {
  case variant {
    variant.Classic -> "Classic"
    variant.Standard -> "Standard"
  }
}
