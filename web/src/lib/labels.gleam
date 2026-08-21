import core/user.{type User}
import engine/variant.{type Variant}
import gleam/int

pub fn board(width: Int, height: Int) {
  int.to_string(width) <> " x " <> int.to_string(height)
}

pub fn user(user: User) {
  case user.guest {
    True -> "Guest"
    False -> user.name
  }
}

pub fn variant(variant: Variant) {
  case variant {
    variant.Classic -> "Classic"
    variant.Standard -> "Standard"
  }
}
