import core/user.{type User}

pub fn user(user: User) {
  case user.guest {
    True -> "Guest"
    False -> user.name
  }
}
