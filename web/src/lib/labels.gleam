import core/user.{type User}
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
